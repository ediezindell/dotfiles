import { readLines } from "https://deno.land/std/io/mod.ts";

const root = 16;
const p = /(.*font-size: )([\d]+)px(.*)/;

const conv = (s: string) => {
  return s.split("\n").map((l) => {
    const m = l.match(p);
    return m ? [m[1], +m[2] / root, "rem", m[3]].join("") : l;
  }).join("\n");
};

for await (const line of readLines(Deno.stdin)) {
  console.log(conv(line));
}
