# MediTrack – Project Documentation
**Hospital Patient Records & Appointment System**  
Capstone Build Sprint | Full Database Lifecycle

---

## 1. Executive Summary

MediTrack is a focused hospital management system designed to handle patient records and appointment scheduling. The project demonstrates professional database engineering practices across the full lifecycle:

- Requirements analysis and data modeling
- Versioned schema migrations
- Integration of a NoSQL caching layer (Redis)
- Query performance measurement and optimization
- Security hardening and backup/restore procedures

The system prioritizes clarity, security, and maintainability over feature breadth, making it suitable for academic evaluation while reflecting real-world practices.

---

## 2. Problem Statement

Hospitals require a reliable way to:
- Maintain accurate patient demographic and clinical information
- Schedule and track appointments efficiently
- Support different staff roles with appropriate data access
- Retain an immutable history of critical changes
- Recover quickly from failures

MediTrack addresses these needs with a clean relational core, targeted caching, and strong operational controls.

---

## 3. Scope

### In Scope
- Patient registration and profile management
- Appointment booking, status tracking, and history
- Medical visit notes linked to appointments
- Prescription recording
- Department and staff management
- Role-based access control
- Audit logging of critical changes
- Caching of high-read operational data
- Backup and restore capability

### Out of Scope
- Billing and invoicing
- Pharmacy inventory management
- Laboratory results and imaging
- Patient-facing mobile or web portal
- Multi-hospital / multi-tenant architecture

---

## 4. System Architecture

```
┌──────────────────────────────────────────┐
│            Application Layer             │
│   (Reception Desk / Clinical Staff UI)   │
└───────────────────┬──────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
┌───────▼────────┐     ┌────────▼────────┐
│   PostgreSQL   │     │     Redis       │
│                │     │                 │
│ • Source of    │     │ • Today’s board │
│   truth        │     │ • Doctor        │
│ • Complex      │     │   schedules     │
│   queries      │     │ • Booking locks │
│ • Audit log    │     │ • Hot lookups   │
│ • RLS & roles  │     │                 │
└────────────────┘     └─────────────────┘
```

**Design Principle:**  
PostgreSQL is the system of record. Redis is used only where its strengths (speed, TTL, simple coordination) clearly outperform a relational approach.

---

## 5. Data Model

### Core Entities

| Entity | Purpose |
|--------|---------|
| `departments` | Hospital departments (Cardiology, Pediatrics, etc.) |
| `staff` | Doctors, nurses, receptionists, and admins |
| `patients` | Patient demographics and emergency contacts |
| `appointments` | Scheduled encounters between patients and doctors |
| `medical_records` | Clinical notes from visits |
| `prescriptions` | Medications linked to a medical record |
| `audit_log` | Immutable change history (JSONB) |

### Key Relationships
- One Department → Many Staff
- One Patient → Many Appointments
- One Doctor (Staff) → Many Appointments
- One Appointment → Zero or One Medical Record
- One Medical Record → Many Prescriptions

### ER Diagram
The complete ER diagram is available in `docs/02_er_diagram.dbml` and can be rendered at [dbdiagram.io](https://dbdiagram.io).

---

## 6. Schema Management (Migrations)

All schema changes are managed through ordered Flyway migrations:

| Version | File | Description |
|---------|------|-------------|
| V1 | `V1__core_tables.sql` | Tables, constraints, updated_at triggers, pgcrypto |
| V2 | `V2__indexes.sql` | Performance indexes for common access paths |
| V3 | `V3__audit_and_triggers.sql` | Reusable audit_log + triggers on critical tables |
| V4 | `V4__row_level_security.sql` | Roles, privileges, and RLS policies |
| V5 | `V5__seed_demo_data.sql` | Realistic demo data |

**Command used:**
```bash
flyway -cleanDisabled=false clean migrate
```
This command succeeds from an empty database and produces a schema at version 5.

---

## 7. NoSQL Integration – Redis

### Why Redis?
Certain operational patterns are high-read and short-lived:
- Displaying today’s appointment board
- Checking a doctor’s free slots while booking
- Preventing double-booking with a short-lived lock
- Fast patient lookup by phone at reception

These patterns benefit from Redis’s in-memory speed and native TTL support.

### What stays in PostgreSQL
- Patient history
- Full appointment history
- Medical records and prescriptions
- Audit log
- Staff and department master data

### Key Design
```
meditrack:appointments:today
meditrack:doctor:{id}:schedule:{date}
meditrack:lock:slot:{doctor_id}:{date}:{time}
meditrack:patient:phone:{phone}
meditrack:session:{token}
```

Full justification and example code are in `docs/03_nosql_redis_integration.md`.

---

## 8. Query Optimization

Three analytical queries were measured before and after targeted indexing:

1. **Doctor Workload (last 30 days)**  
   Seq Scan → Bitmap Index Scan

2. **Frequent Patients (≥2 completed visits in 90 days)**  
   Seq Scan → Bitmap Index Scan

3. **Daily Volume & No-show Rate**  
   0.69 ms → 0.39 ms (Seq Scan → Index Scan)

Detailed before/after `EXPLAIN ANALYZE` output is available in:
- `docs/04_query_optimization.md`
- `outputs/query1_before.txt` / `query1_after.txt`
- `outputs/query2_before.txt` / `query2_after.txt`
- `outputs/query3_before.txt` / `query3_after.txt`

---

## 9. Security

### Roles (Least Privilege)
| Role | Purpose |
|------|---------|
| `app_readonly` | Reporting / read-only access |
| `app_receptionist` | Patient registration & appointment booking |
| `app_clinical` | Doctors and nurses – clinical data access |
| `app_admin` | Full administrative access |

Application users (`meditrack_*`) inherit these roles. **No application user is a superuser.**

### Controls Implemented
- Row Level Security enabled on sensitive tables
- Passwords stored using `pgcrypto` (bcrypt)
- Audit triggers on patients, appointments, medical records, and staff
- Parameterized queries only (no string concatenation of user input)

Full checklist: `docs/05_security_checklist.md`

---

## 10. Backup & Recovery

**Backup command:**
```bash
pg_dump -Fc -f backups/capstone_$(date +%F).dump capstone
```

**Script:** `scripts/backup.sh`

**Test Restore:**  
A full restore into a separate database (`capstone_restore_test`) was performed successfully. Row counts matched the source (508 patients, 3,010 appointments). Evidence: `outputs/restore_test.txt`.

---

## 11. Project Structure

```
meditrack/
├── README.md
├── docs/
│   ├── 00_PROJECT_DOCUMENTATION.md      ← this file
│   ├── 01_requirements_summary.md
│   ├── 02_er_diagram.dbml
│   ├── 03_nosql_redis_integration.md
│   ├── 03_redis_key_design.txt
│   ├── 04_query_optimization.md
│   ├── 05_security_checklist.md
│   └── 06_walkthrough_presentation.md
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
└── outputs/                             ← evidence files
```

---

## 12. How to Reproduce

```bash
# Create database
createdb capstone

# Apply all migrations
flyway -url=jdbc:postgresql://localhost:5432/capstone \
       -user=postgres -password=<password> \
       -locations=filesystem:./migrations \
       -cleanDisabled=false \
       clean migrate

# Optional: run backup
./scripts/backup.sh
```

---

## 13. Conclusion

MediTrack demonstrates a complete, professional approach to database development:

- Clear requirements and a well-structured data model
- Repeatable schema management with Flyway
- Thoughtful use of Redis where it adds real value
- Measured performance improvements
- Strong security posture and proven backup/restore

All assignment requirements have been met and documented with supporting evidence.

---

*Prepared as part of the Capstone Build Sprint.*
