# MediTrack – Hospital Patient Records & Appointment System

**Capstone Build Sprint**  
Complete end-to-end database project covering design, migrations, NoSQL integration, query optimization, security, and backup.

## Quick Status

| Day | Deliverable | Status |
|-----|-------------|--------|
| 1 | Requirements summary + ER diagram | ✅ |
| 2 | Versioned Flyway migrations (V1–V5) | ✅ |
| 3 | Redis integration (justified) | ✅ |
| 4 | Query optimization with before/after evidence | ✅ |
| 5 | Backup + restore + security checklist + walkthrough | ✅ |

## Project Structure

```
meditrack/
├── README.md
├── docs/
│   ├── 01_requirements_summary.md
│   ├── 02_er_diagram.dbml              ← paste into dbdiagram.io
│   ├── 03_nosql_redis_integration.md
│   ├── 03_redis_key_design.txt
│   ├── 04_query_optimization.md
│   ├── 05_security_checklist.md
│   └── 06_walkthrough_presentation.md  ← main presentation
├── migrations/
│   ├── V1__core_tables.sql
│   ├── V2__indexes.sql
│   ├── V3__audit_and_triggers.sql
│   ├── V4__row_level_security.sql
│   └── V5__seed_demo_data.sql
├── scripts/
│   ├── backup.sh
│   └── redis_cache_demo.py
├── backups/
│   └── capstone_YYYY-MM-DD.dump
└── outputs/                            ← evidence files
```

## How to Rebuild from Scratch

```bash
# 1. Create database
createdb capstone

# 2. Run migrations
flyway -url=jdbc:postgresql://localhost:5432/capstone \
       -user=postgres -password=<password> \
       -locations=filesystem:./migrations \
       -cleanDisabled=false \
       clean migrate

# 3. (Optional) Take backup
./scripts/backup.sh
```

## Security Checklist (All Passed)

- [x] Least-privilege roles (no app superuser)
- [x] RLS on sensitive tables
- [x] Sensitive fields hashed (pgcrypto)
- [x] Audit log on critical tables
- [x] Parameterized queries only
- [x] Backup taken **and** test restore performed

## Presentation

See **`docs/06_walkthrough_presentation.md`** for the complete architecture and decision walkthrough.
