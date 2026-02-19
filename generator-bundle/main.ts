import type { ExistingMatch, Match, Player, PlayerComboCounter, PlayerCounter } from "./types.ts";
import { arrayClone, arraysEqual, combinations } from "./utils.ts";
import { Convert as InputConvert } from "./inputSchema.g.ts";
import { Convert as OutputConvert, type OutputSchema } from "./outputSchema.g.ts";

/**
 * Generator is a class which accepts a list of players and number of courts and exposes methods to generate game combinations.
 *
 * How it works for doubles matches:
 * - Set up
 *    - Add game counts to each player
 *    - Create an array of all possible combinations of players, and associate a game count
 * - Calculating a team
 *    - Sort players least to most games played, pick the least played
 *    - Calculate "weights" for all player combinations containing this player, picking the lowest weight
 *        - `Weight = player A's game count + player B's game count + the combinations game count`
 *    - Repeat for opposing team
 *    - Increment the game counts of each selected player and combination
 * - Repeat team calculation if required to fill desired number of courts
 *
 * Singles matches are calculated in the same way. However, only one team is generated per court,
 * and split in half to get both players, instead of generating another pair of players.
 */
class Generator {
  // Players and their game count
  private _players: PlayerCounter[] = [];

  // Combos of players (in `a-b` form) and their game count
  private _playerCombos: PlayerComboCounter[] = [];

  private numOfCourts: number;

  private teamSize: number;

  /****For testing only, don't use this in general usage.***/
  public get players(): PlayerCounter[] {
    return this._players;
  }

  /****For testing only, don't use this in general usage.***/
  public get playerCombos(): PlayerComboCounter[] {
    return this._playerCombos;
  }

  constructor(players: Player[], numOfCourts = 1, teamSize = 2, existingMatches: ExistingMatch[] = []) {
    this.numOfCourts = numOfCourts;
    this.teamSize = teamSize;

    this.populatePlayerMap(players);
    this.populateComboMap(players);
    this.prePopulateExistingMatches(players, existingMatches);
  }

  private populatePlayerMap(players: Player[]) {
    for (const player of players) {
      if (this.players.some((x) => x.player === player)) {
        throw new Error(`Duplicate player: ${player}`);
      }

      this.players.push({ player, gamesPlayed: 0 });
    }
  }

  private populateComboMap(players: Player[]) {
    const playerCombos = combinations(players);

    for (const combo of playerCombos) {
      if (this.playerCombos.some((x) => arraysEqual(x.combo, combo))) {
        throw new Error(`Duplicate player combo: ${combo.toString()}`);
      }

      this.playerCombos.push({ combo, gamesPlayed: 0 });
    }
  }

  private prePopulateExistingMatches(players: Player[], existingMatches?: ExistingMatch[]) {
    if (!existingMatches) {
      return;
    }

    for (const match of existingMatches) {
      // biome-ignore lint/style/noNonNullAssertion: player must be in players array to be in a match
      const playersA = match.teamA.map((x) => players.find((y) => y === x)!);
      // biome-ignore lint/style/noNonNullAssertion: player must be in players array to be in a match
      const playersB = match.teamB.map((x) => players.find((y) => y === x)!);

      if (this.teamSize === 1) {
        this.incrementPlayerGamesPlayed([...playersA, ...playersB]);
      } else {
        this.incrementPlayerGamesPlayed(playersA);
        this.incrementPlayerGamesPlayed(playersB);
      }
    }
  }

  private getNextPlayer(excludeList?: Player[]): Player {
    let localPlayers: PlayerCounter[] = arrayClone(this.players);

    if (excludeList) {
      localPlayers = localPlayers.filter((x) => !excludeList.includes(x.player));
    }

    localPlayers.sort((a, b) => {
      return a.gamesPlayed - b.gamesPlayed;
    });

    return localPlayers[0].player;
  }

  private getPlayersNextCombo(player: Player, excludeList?: Player[]): Player {
    let localPlayerCombos: PlayerComboCounter[] = arrayClone(this.playerCombos);

    if (excludeList) {
      localPlayerCombos = localPlayerCombos.filter(
        (x) => !excludeList.includes(x.combo[0]) && !excludeList.includes(x.combo[1]),
      );
    }

    localPlayerCombos.map((combo) => {
      combo.gamesPlayed = this.getComboWeight(combo);
      return combo;
    });

    // Filter to only combos containing player and sort by games played
    localPlayerCombos = localPlayerCombos.filter((x) => x.combo.includes(player));

    localPlayerCombos.sort((a, b) => {
      return this.getComboWeight(a) - this.getComboWeight(b);
    });

    // Return the other player from the lowest game count combo
    return localPlayerCombos[0].combo.filter((x) => x !== player)[0];
  }

  /**
   * Calculate the weight of a given combo.
   *
   * Weight is the sum of the games played by the combo and the players in the combo.
   */
  private getComboWeight(playerCombo: PlayerComboCounter): number {
    let weight = 0;

    weight += playerCombo.gamesPlayed;
    weight += this.players.find((x) => x.player === playerCombo.combo[0])?.gamesPlayed || 0;
    weight += this.players.find((x) => x.player === playerCombo.combo[1])?.gamesPlayed || 0;

    return weight;
  }

  private getNextTeam(excludeList?: Player[]): Player[] {
    const player1 = this.getNextPlayer(excludeList);
    const player2 = this.getPlayersNextCombo(player1, excludeList);

    const team = [player1, player2];

    this.incrementPlayerGamesPlayed(team);

    return team;
  }

  public getNextDoublesMatch(court: number, excludeList?: Player[]): Match {
    const teamA = this.getNextTeam(excludeList);
    const teamB = this.getNextTeam([...(excludeList ?? []), ...teamA]);

    if (teamA.includes(teamB[0]) || teamA.includes(teamB[1])) {
      throw new Error(`Player is in both teams. TeamA: ${teamA}, TeamB: ${teamB}`);
    }

    if (teamB.includes(teamA[0]) || teamB.includes(teamA[1])) {
      throw new Error(`Player is in both teams. TeamA: ${teamA}, TeamB: ${teamB}`);
    }

    return {
      teamA: teamA,
      teamB: teamB,
      court,
    };
  }

  public getNextSinglesMatch(court: number, excludeList?: Player[]): Match {
    const players = this.getNextTeam(excludeList);

    return {
      teamA: [players[0]],
      teamB: [players[1]],
      court,
    };
  }

  public getNextMatches(): Match[] {
    const matches: Match[] = [];
    const usedPlayers: Player[] = [];

    for (let i = 0; i < this.numOfCourts; i++) {
      const match =
        this.teamSize === 1 ? this.getNextSinglesMatch(i, usedPlayers) : this.getNextDoublesMatch(i, usedPlayers);

      usedPlayers.push(...match.teamA, ...match.teamB);

      matches.push(match);
    }

    return matches;
  }

  private incrementPlayerGamesPlayed(playerCombo: Player[]) {
    // Players
    for (const player of playerCombo) {
      const playerIndex = this.players.findIndex((x) => x.player === player);

      if (playerIndex === -1) {
        throw new Error(`Player not found: ${player.toString()}`);
      }

      this.players[playerIndex].gamesPlayed += 1;
    }

    // PlayerCombos
    const playerComboIndex = this.playerCombos.findIndex((x) => arraysEqual(x.combo, playerCombo));

    if (playerComboIndex === -1) {
      throw new Error(`Player combo not found: ${playerCombo.toString()}`);
    }

    this.playerCombos[playerComboIndex].gamesPlayed += 1;
  }
}

export function generateMatches(input: string): string {
  const { count, players, courtCount, teamSize } = InputConvert.toInputSchema(input);

  const g = new Generator(players, courtCount, teamSize, []);

  const output: OutputSchema[][] = [];

  for (let i = 0; i < count; i++) {
    output.push(g.getNextMatches());
  }

  return OutputConvert.outputSchemaToJson(output);
}
