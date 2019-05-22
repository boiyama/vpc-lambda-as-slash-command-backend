import commonjs from "rollup-plugin-commonjs";
import json from "rollup-plugin-json";
import typescript from "rollup-plugin-typescript";
import resolve from "rollup-plugin-node-resolve";

export default {
  input: "./src/main.ts",
  output: {
    file: "./dist/main.js",
    format: "cjs"
  },
  plugins: [commonjs(), json(), typescript(), resolve()]
};
