export type Player = string;

export type Match = {
  teamA: Player[];
  teamB: Player[];
  court: number;
};

export type MatchGroup = Match[];

export type ExistingMatch = {
  teamA: Player[];
  teamB: Player[];
  court: number;
};

export type PlayerCounter = {
  player: Player;
  gamesPlayed: number;
};

export type PlayerComboCounter = {
  combo: Player[];
  gamesPlayed: number;
};
