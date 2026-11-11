# MediTrack – Final Walkthrough Presentation
**Hospital Patient Records & Appointment System**  
Capstone Build Sprint – Complete Lifecycle

---

## 1. Project Overview

**Name:** MediTrack  
**Domain:** Hospital Management (Patient Records + Appointments)  
**Goal:** A clean, secure, well-documented system that covers the full database lifecycle.

**Scope chosen:** Focused and defensible  
- Patient registration & demographics  
- Appointment scheduling & status tracking  
- Medical visit notes + prescriptions  
- Role-based access + audit trail  
- Caching layer for hot data  
- Backup & restore  

Out of scope (intentionally): billing, pharmacy inventory, full EHR, patient mobile app.

---

## 2. Architecture at a Glance

```
┌─────────────────────┐
│   Application Layer │
│  (Reception / Clinical)
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
┌────▼────┐ ┌────▼────┐
│PostgreSQL│ │  Redis  │
│(System of│ │ (Cache  │
│ Record)  │ │  + Lock)│
└──────────┘ └─────────┘
```

- **PostgreSQL** → durable data, complex queries, audit, security
- **Redis** → today’s appointments board, doctor schedule cache, temporary booking locks

---

## 3. Design Decisions (and why)

| Decision | Rationale |
|----------|-----------|
| Single `staff` table with `role` column | Simple, easy to understand, sufficient for school project |
| Appointments as central entity | Natural hub between patients, doctors, and medical records |
| Medical records optional link to appointment | Supports both walk-in and scheduled visits |
| Redis only for cache/locks | Keeps architecture simple and easy to defend |
| Flyway migrations | Repeatable, ordered, professional schema management |
| RLS + least-privilege roles | Demonstrates real security thinking |

---

## 4. Day-by-Day Delivery

### Day 1 – Requirements & ER Diagram
- Clear 1-page requirements summary
- Complete ER diagram (dbdiagram.io format provided)
- Entities, attributes, relationships, cardinalities defined

### Day 2 – Schema as Migrations
```
V1__core_tables.sql
V2__indexes.sql
V3__audit_and_triggers.sql
V4__row_level_security.sql
V5__seed_demo_data.sql
```
`flyway clean migrate` succeeds from empty database → version 5.

### Day 3 – NoSQL (Redis)
Justified use cases:
- Cache today’s appointment board
- Cache doctor schedules
- Temporary slot locks (SET NX EX)
- Hot patient phone lookup

PostgreSQL remains the system of record.

### Day 4 – Query Optimization
Three analytical queries optimized with before/after evidence:

1. Doctor workload (last 30 days)  
2. Frequent patients (≥2 completed visits)  
3. Daily volume + no-show rate  

All moved from Sequential Scan → Bitmap Index Scan.  
Evidence files included in `outputs/`.

### Day 5 – Backup, Security & Hardening
- Backup script using `pg_dump -Fc`
- Successful test restore verified
- Full security checklist passed

---

## 5. Security Highlights

- No application superuser
- Four purpose-built roles
- RLS enabled on sensitive tables
- Passwords stored with `pgcrypto` (bcrypt)
- Audit triggers on critical tables
- Parameterized queries only
- Backup + proven restore

---

## 6. Key Artifacts

```
meditrack/
├── docs/
│   ├── 01_requirements_summary.md
│   ├── 02_er_diagram.dbml
│   ├── 03_nosql_redis_integration.md
│   ├── 04_query_optimization.md
│   ├── 05_security_checklist.md
│   └── 06_walkthrough_presentation.md   ← this file
├── migrations/          (V1–V5)
├── scripts/
│   ├── backup.sh
│   └── redis_cache_demo.py
├── backups/
│   └── capstone_YYYY-MM-DD.dump
└── outputs/             (EXPLAIN plans, restore proof, security checks)
```

---

## 7. Lessons Learned

- Plan the data model carefully before writing SQL
- Migrations make schema changes safe and repeatable
- Measure performance with `EXPLAIN ANALYZE` — never guess
- Use the right tool for the job (Redis for cache, PostgreSQL for truth)
- Security and backups are not optional extras

---

## 8. Closing

MediTrack demonstrates the full lifecycle of a professional database project:

**Requirements → Design → Migrations → NoSQL integration → Optimization → Security → Backup → Documentation**

All deliverables are present, measured, and ready for review.
