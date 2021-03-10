module.exports = {
  root: true,
  env: {
    browser: true,
    es2021: true,
  },
  extends: [
    "eslint:recommended",
    "airbnb-base",
    "plugin:import/errors",
    "plugin:import/warnings",
    "prettier",
  ],
  parserOptions: {
    ecmaVersion: 12,
    sourceType: "module",
  },
  rules: {
    "import/no-commonjs": ["error"],
    "no-only-tests/no-only-tests": "error",
  },
  plugins: ["no-only-tests"],
};
