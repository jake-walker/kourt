export function countOccurrences<T>(arr: Array<T>): Map<string, number> {
  const occurrences = new Map<string, number>();

  for (const item of arr) {
    const key = JSON.stringify(item);
    occurrences.set(key, (occurrences.get(key) || 0) + 1);
  }

  return occurrences;
}

export function combinations<T>(arr: Array<T>): Array<Array<T>> {
  return arr.flatMap((v, i) =>
    arr.slice(i + 1).map((w) => {
      const pair = [v, w];
      pair.sort();
      return pair;
    }),
  );
}

export function arraysEqual<T>(a: Array<T>, b: Array<T>): boolean {
  if (a == null || b == null) return false;
  if (a.length !== b.length) return false;

  return a.every((item) => b.includes(item)) && b.every((item) => a.includes(item));
}

export function arrayClone<T>(arr: Array<T>): Array<T> {
  return arr.map((item) => Object.assign({}, item));
}
