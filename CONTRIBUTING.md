# Contributing

This repository follows a three-branch strategy and a strict issue → branch → PR → merge workflow.

## Branches

| Branch | Role | Receives changes via |
|--------|------|----------------------|
| `dev`  | Default / integration trunk. All work merges here first. | Pull Request only |
| `prod` | Production releases. | PR from `dev` |
| `main` | Stable mirror / source of truth. | PR from `dev` (or `prod`) |

`dev` is the **default branch** and is **protected**: direct pushes are blocked. Force-pushes and deletion are blocked. Every change enters `dev` through a Pull Request.

## Workflow (official GitHub flow)

1. **Open an Issue** describing the bug or feature.
2. **Create a branch from the issue** (issue page → *Create a branch*). This links the branch to the issue. Branch off `dev`.
   - Naming: `feature/<short-desc>` or `bugfix/<short-desc>`.
3. **Develop** and commit on that branch.
4. **Open a Pull Request** with base `dev`. In the description, link the issue with a closing keyword:
   ```
   Closes #<issue-number>
   ```
5. **Review + merge.** On merge into `dev` (the default branch), the linked issue **auto-closes**.

> Closing keywords (`Closes`, `Fixes`, `Resolves`) only auto-close the issue when the PR merges into the repository's **default branch**. That is why `dev` is set as default.

## Promoting to prod / main

Open a PR from `dev` → `prod` (and `dev`/`prod` → `main`) when releasing.

## Commit messages

Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, etc.
