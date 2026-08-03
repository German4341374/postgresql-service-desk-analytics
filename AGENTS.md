# Repository guidance

- Use English for source, comments, documentation, and commit messages.
- Keep the project SQL-first; Bash should orchestrate PostgreSQL and Docker only.
- Never commit `.env`, database data, dumps, credentials, or generated benchmark output.
- Never invent performance figures. A documented timing must link to raw output from a successful run.
- Do not edit an applied migration. Add a new monotonically numbered migration.
- Keep generated data deterministic and restricted to fictional `.invalid` identities.
- Preserve compatibility with Bash on Linux and Windows WSL2.
- Run the fast test suite before committing. Treat the full-scale benchmark as an explicit, resource-intensive action.
- Use Conventional Commits.
