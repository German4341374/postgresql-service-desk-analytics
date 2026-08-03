## Summary

Describe the change and its Service Desk use case.

## Verification

- [ ] `bash -n scripts/*.sh`
- [ ] `make test`
- [ ] Migration is forward-only and rerunnable through the migration runner
- [ ] Query-plan claims are backed by attached raw output
- [ ] Documentation is updated
- [ ] No credentials, production data, dumps, or Terraform-style state files are included

## Database impact

Describe locks, disk growth, rollback or recovery steps, and expected query-plan changes.
