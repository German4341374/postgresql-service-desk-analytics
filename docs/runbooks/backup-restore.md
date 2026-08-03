# Backup and restore runbook

## Create a logical backup

```bash
make backup
```

The command writes a timestamped custom-format dump beneath `backups/`. Record the PostgreSQL version, checksum the file, copy it to encrypted off-host storage, and restrict read access in any real environment.

## Verify automatically

```bash
bash scripts/backup-restore-demo.sh
```

The script creates an isolated temporary database in the same cluster, restores with `--clean --if-exists`, verifies the incident count against the source, and removes the database.

## Restore manually

Stop writers, create an empty target database, and restore to the target rather than overwriting the only usable copy:

```bash
BACKUP_FILE=backups/service_desk_YYYYMMDDTHHMMSSZ.dump \
TARGET_DB=service_desk_recovery \
bash scripts/restore.sh "$BACKUP_FILE"
```

Verify migrations, relation counts, constraints, representative queries, ownership, privileges, RLS behavior, and application compatibility before redirecting traffic. Keep the previous database intact until sign-off.

## Failure handling

- If the dump is truncated or `pg_restore --list` fails, do not retry from the same artifact; locate a verified copy.
- If extensions or roles are missing, create the reviewed prerequisites before restoring.
- If restore fails partway, drop the isolated target and restart into a new empty database.
- Never test a first restore over the production database.
