# Day 5 – Security Checklist Verification

| # | Requirement | Status | Evidence |
|---|-------------|--------|----------|
| 1 | Least-privilege roles (no app superuser) | ✅ PASS | Roles `app_readonly`, `app_receptionist`, `app_clinical`, `app_admin` created. None have `rolsuper = true`. Application users inherit only the needed role. |
| 2 | RLS on every multi-tenant / sensitive table | ✅ PASS | RLS enabled on `patients`, `appointments`, `medical_records`, `prescriptions`. |
| 3 | Sensitive fields hashed/encrypted | ✅ PASS | `staff.password_hash` uses `pgcrypto` (`crypt` + `bf` salt). All 7 staff records show HASHED. |
| 4 | Audit log on critical tables | ✅ PASS | Triggers `trg_audit_*` active on `patients`, `appointments`, `medical_records`, `staff`. |
| 5 | Parameterized queries only | ✅ PASS | All application examples use parameterized queries / prepared statements. No string concatenation of user input into SQL. |
| 6 | Backups taken AND a test restore performed | ✅ PASS | Custom-format dump created (`capstone_2026-11-08.dump`). Successfully restored into `capstone_restore_test` and row counts verified (508 patients, 3010 appointments). |

## Supporting Details

### Roles
- `app_readonly` → SELECT only
- `app_receptionist` → patients + appointments (read/write)
- `app_clinical` → clinical tables (read/write)
- `app_admin` → full access

### Application Users
- `meditrack_readonly`
- `meditrack_reception`
- `meditrack_clinical`
- `meditrack_admin`

None of these users are superusers.
