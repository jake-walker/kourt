var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if ((from && typeof from === "object") || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, {
          get: () => from[key],
          enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable,
        });
  }
  return to;
};
var __toCommonJS = (mod) =>
  __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// utils.ts
function combinations(arr) {
  return arr.flatMap((v, i) =>
    arr.slice(i + 1).map((w) => {
      const pair = [v, w];
      pair.sort();
      return pair;
    }),
  );
}
function arraysEqual(a3, b) {
  if (a3 == null || b == null) return false;
  if (a3.length !== b.length) return false;
  return (
    a3.every((item) => b.includes(item)) && b.every((item) => a3.includes(item))
  );
}
function arrayClone(arr) {
  return arr.map((item) => Object.assign({}, item));
}

// inputSchema.g.ts
var Convert = class {
  static toInputSchema(json) {
    return cast(JSON.parse(json), r("InputSchema"));
  }
  static inputSchemaToJson(value) {
    return JSON.stringify(uncast(value, r("InputSchema")), null, 2);
  }
};
function invalidValue(typ, val, key, parent = "") {
  const prettyTyp = prettyTypeName(typ);
  const parentText = parent ? ` on ${parent}` : "";
  const keyText = key ? ` for key "${key}"` : "";
  throw Error(
    `Invalid value${keyText}${parentText}. Expected ${prettyTyp} but got ${JSON.stringify(val)}`,
  );
}
function prettyTypeName(typ) {
  if (Array.isArray(typ)) {
    if (typ.length === 2 && typ[0] === void 0) {
      return `an optional ${prettyTypeName(typ[1])}`;
    } else {
      return `one of [${typ
        .map((a3) => {
          return prettyTypeName(a3);
        })
        .join(", ")}]`;
    }
  } else if (typeof typ === "object" && typ.literal !== void 0) {
    return typ.literal;
  } else {
    return typeof typ;
  }
}
function jsonToJSProps(typ) {
  if (typ.jsonToJS === void 0) {
    const map = {};
    typ.props.forEach(
      (p) =>
        (map[p.json] = {
          key: p.js,
          typ: p.typ,
        }),
    );
    typ.jsonToJS = map;
  }
  return typ.jsonToJS;
}
function jsToJSONProps(typ) {
  if (typ.jsToJSON === void 0) {
    const map = {};
    typ.props.forEach(
      (p) =>
        (map[p.js] = {
          key: p.json,
          typ: p.typ,
        }),
    );
    typ.jsToJSON = map;
  }
  return typ.jsToJSON;
}
function transform(val, typ, getProps, key = "", parent = "") {
  function transformPrimitive(typ2, val2) {
    if (typeof typ2 === typeof val2) return val2;
    return invalidValue(typ2, val2, key, parent);
  }
  function transformUnion(typs, val2) {
    const l3 = typs.length;
    for (let i = 0; i < l3; i++) {
      const typ2 = typs[i];
      try {
        return transform(val2, typ2, getProps);
      } catch (_) {}
    }
    return invalidValue(typs, val2, key, parent);
  }
  function transformEnum(cases, val2) {
    if (cases.indexOf(val2) !== -1) return val2;
    return invalidValue(
      cases.map((a3) => {
        return l(a3);
      }),
      val2,
      key,
      parent,
    );
  }
  function transformArray(typ2, val2) {
    if (!Array.isArray(val2))
      return invalidValue(l("array"), val2, key, parent);
    return val2.map((el) => transform(el, typ2, getProps));
  }
  function transformDate(val2) {
    if (val2 === null) {
      return null;
    }
    const d = new Date(val2);
    if (isNaN(d.valueOf())) {
      return invalidValue(l("Date"), val2, key, parent);
    }
    return d;
  }
  function transformObject(props, additional, val2) {
    if (val2 === null || typeof val2 !== "object" || Array.isArray(val2)) {
      return invalidValue(l(ref || "object"), val2, key, parent);
    }
    const result = {};
    Object.getOwnPropertyNames(props).forEach((key2) => {
      const prop = props[key2];
      const v = Object.prototype.hasOwnProperty.call(val2, key2)
        ? val2[key2]
        : void 0;
      result[prop.key] = transform(v, prop.typ, getProps, key2, ref);
    });
    Object.getOwnPropertyNames(val2).forEach((key2) => {
      if (!Object.prototype.hasOwnProperty.call(props, key2)) {
        result[key2] = transform(val2[key2], additional, getProps, key2, ref);
      }
    });
    return result;
  }
  if (typ === "any") return val;
  if (typ === null) {
    if (val === null) return val;
    return invalidValue(typ, val, key, parent);
  }
  if (typ === false) return invalidValue(typ, val, key, parent);
  let ref = void 0;
  while (typeof typ === "object" && typ.ref !== void 0) {
    ref = typ.ref;
    typ = typeMap[typ.ref];
  }
  if (Array.isArray(typ)) return transformEnum(typ, val);
  if (typeof typ === "object") {
    return typ.hasOwnProperty("unionMembers")
      ? transformUnion(typ.unionMembers, val)
      : typ.hasOwnProperty("arrayItems")
        ? transformArray(typ.arrayItems, val)
        : typ.hasOwnProperty("props")
          ? transformObject(getProps(typ), typ.additional, val)
          : invalidValue(typ, val, key, parent);
  }
  if (typ === Date && typeof val !== "number") return transformDate(val);
  return transformPrimitive(typ, val);
}
function cast(val, typ) {
  return transform(val, typ, jsonToJSProps);
}
function uncast(val, typ) {
  return transform(val, typ, jsToJSONProps);
}
function l(typ) {
  return {
    literal: typ,
  };
}
function a(typ) {
  return {
    arrayItems: typ,
  };
}
function o(props, additional) {
  return {
    props,
    additional,
  };
}
function r(name) {
  return {
    ref: name,
  };
}
var typeMap = {
  InputSchema: o(
    [
      {
        json: "count",
        js: "count",
        typ: 0,
      },
      {
        json: "courtCount",
        js: "courtCount",
        typ: 0,
      },
      {
        json: "players",
        js: "players",
        typ: a(""),
      },
      {
        json: "teamSize",
        js: "teamSize",
        typ: 0,
      },
    ],
    "any",
  ),
};

// outputSchema.g.ts
var Convert2 = class {
  static toOutputSchema(json) {
    return cast2(JSON.parse(json), a2(a2(r2("OutputSchema"))));
  }
  static outputSchemaToJson(value) {
    return JSON.stringify(uncast2(value, a2(a2(r2("OutputSchema")))), null, 2);
  }
};
function invalidValue2(typ, val, key, parent = "") {
  const prettyTyp = prettyTypeName2(typ);
  const parentText = parent ? ` on ${parent}` : "";
  const keyText = key ? ` for key "${key}"` : "";
  throw Error(
    `Invalid value${keyText}${parentText}. Expected ${prettyTyp} but got ${JSON.stringify(val)}`,
  );
}
function prettyTypeName2(typ) {
  if (Array.isArray(typ)) {
    if (typ.length === 2 && typ[0] === void 0) {
      return `an optional ${prettyTypeName2(typ[1])}`;
    } else {
      return `one of [${typ
        .map((a3) => {
          return prettyTypeName2(a3);
        })
        .join(", ")}]`;
    }
  } else if (typeof typ === "object" && typ.literal !== void 0) {
    return typ.literal;
  } else {
    return typeof typ;
  }
}
function jsonToJSProps2(typ) {
  if (typ.jsonToJS === void 0) {
    const map = {};
    typ.props.forEach(
      (p) =>
        (map[p.json] = {
          key: p.js,
          typ: p.typ,
        }),
    );
    typ.jsonToJS = map;
  }
  return typ.jsonToJS;
}
function jsToJSONProps2(typ) {
  if (typ.jsToJSON === void 0) {
    const map = {};
    typ.props.forEach(
      (p) =>
        (map[p.js] = {
          key: p.json,
          typ: p.typ,
        }),
    );
    typ.jsToJSON = map;
  }
  return typ.jsToJSON;
}
function transform2(val, typ, getProps, key = "", parent = "") {
  function transformPrimitive(typ2, val2) {
    if (typeof typ2 === typeof val2) return val2;
    return invalidValue2(typ2, val2, key, parent);
  }
  function transformUnion(typs, val2) {
    const l3 = typs.length;
    for (let i = 0; i < l3; i++) {
      const typ2 = typs[i];
      try {
        return transform2(val2, typ2, getProps);
      } catch (_) {}
    }
    return invalidValue2(typs, val2, key, parent);
  }
  function transformEnum(cases, val2) {
    if (cases.indexOf(val2) !== -1) return val2;
    return invalidValue2(
      cases.map((a3) => {
        return l2(a3);
      }),
      val2,
      key,
      parent,
    );
  }
  function transformArray(typ2, val2) {
    if (!Array.isArray(val2))
      return invalidValue2(l2("array"), val2, key, parent);
    return val2.map((el) => transform2(el, typ2, getProps));
  }
  function transformDate(val2) {
    if (val2 === null) {
      return null;
    }
    const d = new Date(val2);
    if (isNaN(d.valueOf())) {
      return invalidValue2(l2("Date"), val2, key, parent);
    }
    return d;
  }
  function transformObject(props, additional, val2) {
    if (val2 === null || typeof val2 !== "object" || Array.isArray(val2)) {
      return invalidValue2(l2(ref || "object"), val2, key, parent);
    }
    const result = {};
    Object.getOwnPropertyNames(props).forEach((key2) => {
      const prop = props[key2];
      const v = Object.prototype.hasOwnProperty.call(val2, key2)
        ? val2[key2]
        : void 0;
      result[prop.key] = transform2(v, prop.typ, getProps, key2, ref);
    });
    Object.getOwnPropertyNames(val2).forEach((key2) => {
      if (!Object.prototype.hasOwnProperty.call(props, key2)) {
        result[key2] = transform2(val2[key2], additional, getProps, key2, ref);
      }
    });
    return result;
  }
  if (typ === "any") return val;
  if (typ === null) {
    if (val === null) return val;
    return invalidValue2(typ, val, key, parent);
  }
  if (typ === false) return invalidValue2(typ, val, key, parent);
  let ref = void 0;
  while (typeof typ === "object" && typ.ref !== void 0) {
    ref = typ.ref;
    typ = typeMap2[typ.ref];
  }
  if (Array.isArray(typ)) return transformEnum(typ, val);
  if (typeof typ === "object") {
    return typ.hasOwnProperty("unionMembers")
      ? transformUnion(typ.unionMembers, val)
      : typ.hasOwnProperty("arrayItems")
        ? transformArray(typ.arrayItems, val)
        : typ.hasOwnProperty("props")
          ? transformObject(getProps(typ), typ.additional, val)
          : invalidValue2(typ, val, key, parent);
  }
  if (typ === Date && typeof val !== "number") return transformDate(val);
  return transformPrimitive(typ, val);
}
function cast2(val, typ) {
  return transform2(val, typ, jsonToJSProps2);
}
function uncast2(val, typ) {
  return transform2(val, typ, jsToJSONProps2);
}
function l2(typ) {
  return {
    literal: typ,
  };
}
function a2(typ) {
  return {
    arrayItems: typ,
  };
}
function o2(props, additional) {
  return {
    props,
    additional,
  };
}
function r2(name) {
  return {
    ref: name,
  };
}
var typeMap2 = {
  OutputSchema: o2(
    [
      {
        json: "court",
        js: "court",
        typ: 0,
      },
      {
        json: "teamA",
        js: "teamA",
        typ: a2(""),
      },
      {
        json: "teamB",
        js: "teamB",
        typ: a2(""),
      },
    ],
    "any",
  ),
};

// main.ts
var Generator = class {
  // Players and their game count
  _players = [];
  // Combos of players (in `a-b` form) and their game count
  _playerCombos = [];
  numOfCourts;
  teamSize;
  /****For testing only, don't use this in general usage.***/
  get players() {
    return this._players;
  }
  /****For testing only, don't use this in general usage.***/
  get playerCombos() {
    return this._playerCombos;
  }
  constructor(players, numOfCourts = 1, teamSize = 2, existingMatches = []) {
    this.numOfCourts = numOfCourts;
    this.teamSize = teamSize;
    this.populatePlayerMap(players);
    this.populateComboMap(players);
    this.prePopulateExistingMatches(players, existingMatches);
  }
  populatePlayerMap(players) {
    for (const player of players) {
      if (this.players.some((x) => x.player === player)) {
        throw new Error(`Duplicate player: ${player}`);
      }
      this.players.push({
        player,
        gamesPlayed: 0,
      });
    }
  }
  populateComboMap(players) {
    const playerCombos = combinations(players);
    for (const combo of playerCombos) {
      if (this.playerCombos.some((x) => arraysEqual(x.combo, combo))) {
        throw new Error(`Duplicate player combo: ${combo.toString()}`);
      }
      this.playerCombos.push({
        combo,
        gamesPlayed: 0,
      });
    }
  }
  prePopulateExistingMatches(players, existingMatches) {
    if (!existingMatches) {
      return;
    }
    for (const match of existingMatches) {
      const playersA = match.teamA.map((x) => players.find((y) => y === x));
      const playersB = match.teamB.map((x) => players.find((y) => y === x));
      if (this.teamSize === 1) {
        this.incrementPlayerGamesPlayed([...playersA, ...playersB]);
      } else {
        this.incrementPlayerGamesPlayed(playersA);
        this.incrementPlayerGamesPlayed(playersB);
      }
    }
  }
  getNextPlayer(excludeList) {
    let localPlayers = arrayClone(this.players);
    if (excludeList) {
      localPlayers = localPlayers.filter(
        (x) => !excludeList.includes(x.player),
      );
    }
    localPlayers.sort((a3, b) => {
      return a3.gamesPlayed - b.gamesPlayed;
    });
    return localPlayers[0].player;
  }
  getPlayersNextCombo(player, excludeList) {
    let localPlayerCombos = arrayClone(this.playerCombos);
    if (excludeList) {
      localPlayerCombos = localPlayerCombos.filter(
        (x) =>
          !excludeList.includes(x.combo[0]) &&
          !excludeList.includes(x.combo[1]),
      );
    }
    localPlayerCombos.map((combo) => {
      combo.gamesPlayed = this.getComboWeight(combo);
      return combo;
    });
    localPlayerCombos = localPlayerCombos.filter((x) =>
      x.combo.includes(player),
    );
    localPlayerCombos.sort((a3, b) => {
      return this.getComboWeight(a3) - this.getComboWeight(b);
    });
    return localPlayerCombos[0].combo.filter((x) => x !== player)[0];
  }
  /**
   * Calculate the weight of a given combo.
   *
   * Weight is the sum of the games played by the combo and the players in the combo.
   */
  getComboWeight(playerCombo) {
    let weight = 0;
    weight += playerCombo.gamesPlayed;
    weight +=
      this.players.find((x) => x.player === playerCombo.combo[0])
        ?.gamesPlayed || 0;
    weight +=
      this.players.find((x) => x.player === playerCombo.combo[1])
        ?.gamesPlayed || 0;
    return weight;
  }
  getNextTeam(excludeList) {
    const player1 = this.getNextPlayer(excludeList);
    const player2 = this.getPlayersNextCombo(player1, excludeList);
    const team = [player1, player2];
    this.incrementPlayerGamesPlayed(team);
    return team;
  }
  getNextDoublesMatch(court, excludeList) {
    const teamA = this.getNextTeam(excludeList);
    const teamB = this.getNextTeam([...(excludeList ?? []), ...teamA]);
    if (teamA.includes(teamB[0]) || teamA.includes(teamB[1])) {
      throw new Error(
        `Player is in both teams. TeamA: ${teamA}, TeamB: ${teamB}`,
      );
    }
    if (teamB.includes(teamA[0]) || teamB.includes(teamA[1])) {
      throw new Error(
        `Player is in both teams. TeamA: ${teamA}, TeamB: ${teamB}`,
      );
    }
    return {
      teamA,
      teamB,
      court,
    };
  }
  getNextSinglesMatch(court, excludeList) {
    const players = this.getNextTeam(excludeList);
    return {
      teamA: [players[0]],
      teamB: [players[1]],
      court,
    };
  }
  getNextMatches() {
    const matches = [];
    const usedPlayers = [];
    for (let i = 0; i < this.numOfCourts; i++) {
      const match =
        this.teamSize === 1
          ? this.getNextSinglesMatch(i, usedPlayers)
          : this.getNextDoublesMatch(i, usedPlayers);
      usedPlayers.push(...match.teamA, ...match.teamB);
      matches.push(match);
    }
    return matches;
  }
  incrementPlayerGamesPlayed(playerCombo) {
    for (const player of playerCombo) {
      const playerIndex = this.players.findIndex((x) => x.player === player);
      if (playerIndex === -1) {
        throw new Error(`Player not found: ${player.toString()}`);
      }
      this.players[playerIndex].gamesPlayed += 1;
    }
    const playerComboIndex = this.playerCombos.findIndex((x) =>
      arraysEqual(x.combo, playerCombo),
    );
    if (playerComboIndex === -1) {
      throw new Error(`Player combo not found: ${playerCombo.toString()}`);
    }
    this.playerCombos[playerComboIndex].gamesPlayed += 1;
  }
};
function generateMatches(input) {
  const { count, players, courtCount, teamSize } = Convert.toInputSchema(input);
  const g = new Generator(players, courtCount, teamSize, []);
  const output = [];
  for (let i = 0; i < count; i++) {
    output.push(g.getNextMatches());
  }
  return Convert2.outputSchemaToJson(output);
}
