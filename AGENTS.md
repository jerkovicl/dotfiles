# AGENTS Guidelines

This repository follows these guidelines for contributions by AI agents or humans:
This repository contains a monorepo managed with NX and npm. 

## Development Setup
1. Install dependencies with `npm install`.
2. Start the dev server with `npm run start`. The command runs development server in hot reload. Development works best on Node 22 (see README).


## Common Scripts
The root `package.json` defines the main scripts:
- **`npm run build`** – Start development server with hot reload.
- **`npm run lint`** – Runs Eslint and Prettier to lint/format the codebase.
- **`npm run test`** – Runs unit tests via Jest.
- **`npm run cy-test`** - Runs E2E tests via Cypress

These scripts should be executed from the repository root.

## Code Style
- Formatting and linting are handled by **Eslint**. Important settings are
  two‑space indentation, single quotes, trailing commas (`all`) and
  semicolons always.
- Import order and unused code rules are enforced. If a rule must be
  bypassed, use `// eslint-ignore` comments.
- Source code is written in TypeScript.
- Export types and values explicitly (e.g. `export { Foo }` and
  `export type { Bar }`).
- Prefer static imports. Use dynamic `import()` only when strictly necessary
  and document why it's required.

### TypeScript
- Strict mode enabled
- PascalCase for interfaces and types
- camelCase for variables and functions
- Explicit return types for exported functions

## Testing
- Run `npm run test` to execute the test suite.
- Always run the tests before committing changes.
- Focus tests on application behavior and accessibility. Avoid checking Tailwind classes, CSS, or which specific HTML tag is rendered. Prefer queries based on roles or other a11y attributes.
- Do your best to test the exposed API, its inputs and outputs rather than implementation details.
- Group tests with a single `describe` block per subject (e.g. per public function or component). Use the name of the subject as the param for `describe`. Avoid catch‑all labels like “additional tests”.
- Prefer expressive matchers such as `toContain`, `toContainEqual`, or `containSubset` instead of manual array scans with `.some`.
- When validating failure cases, assert on the specific error (name or class) rather than only checking `result.success === false`.
- Don’t export internal helpers purely for test coverage.
- Use descriptive names for both `describe` and `it` blocks to make code folding and navigation easier.
- Do not test Zod schemas.

## Public API
The public API is defined by `index.ts`. 
Whenever you modify this file or the modules it re-exports:

- Ensure every exported value or type has a TSDoc comment in its source file.
- Follow the existing style seen in the codebase: multi-line `/** ... */`
  blocks with a short description, `@param`/`@returns` tags and `@example`
  sections when relevant.
- Keep `index.ts` in sync with the actual exports so consumers see an
  up‑to‑date public API.

## Commit Messages 
Use [Conventional Commits](https://www.conventionalcommits.org/) format. Examples include:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `test:` for test-related changes
   - `chore:` for maintenance tasks
     
## Before Sending a Pull Request
Run the following commands and make a best effort to ensure they succeed:

```bash
npm run lint-fix
npm run lint
npm run test
npm run cy-test
```

Tests may take a while because Cypress launches browsers. If they fail
due to missing executables, run `npx cypress install` first.

## Fixing Bugs
When addressing a bug, follow a test-driven development approach:
1. **Red** – Write a test that reproduces the issue and fails.
2. **Green** – Implement the minimal fix so the new test passes.
3. **Refactor** – Clean up the solution while keeping all tests green.

## Definition of Done

- A task is not done unless `npm run lint` and `npm run test` are all passing.
- A task is not done if it has new behavior without tests to ensure the new behavior.
