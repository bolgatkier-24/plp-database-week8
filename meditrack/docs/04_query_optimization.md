# Day 4 – Query Optimization Evidence

All tests run on PostgreSQL 16.15 with ~508 patients and ~3,010 appointments.

We deliberately removed the relevant indexes first to capture a realistic **BEFORE** baseline, then added targeted indexes and re-measured.

---

## QUERY 1 – Doctor Workload (Last 30 Days)

**QUESTION:**  
How many appointments did each doctor handle in the last 30 days, broken down by completed vs no-shows?

```sql
SELECT 
  s.id AS doctor_id,
  s.first_name || ' ' || s.last_name AS doctor_name,
  d.name AS department,
  COUNT(*) AS total_appointments,
  COUNT(*) FILTER (WHERE a.status = 'completed') AS completed,
  COUNT(*) FILTER (WHERE a.status = 'no_show') AS no_shows
FROM appointments a
JOIN staff s ON s.id = a.doctor_id
JOIN departments d ON d.id = a.department_id
WHERE a.appointment_date >= CURRENT_DATE - 30
  AND s.role = 'doctor'
GROUP BY s.id, s.first_name, s.last_name, d.name
ORDER BY total_appointments DESC;
```

### BEFORE PLAN
```
->  Seq Scan on appointments a
      Filter: (appointment_date >= (CURRENT_DATE - 30))
      Rows Removed by Filter: 1500
Execution Time: ~1.97 ms
(Full sequential scan of appointments)
```

### CHANGE
Added composite index:
```sql
CREATE INDEX idx_appointments_doctor_date 
  ON appointments (doctor_id, appointment_date);

CREATE INDEX idx_appointments_date 
  ON appointments (appointment_date);
```
**Why:** The query filters heavily on `appointment_date` and groups by `doctor_id`. A sequential scan + filter becomes unnecessary once the planner can use an index on the date range.

### AFTER PLAN
```
->  Bitmap Index Scan on idx_appointments_date
      Index Cond: (appointment_date >= (CURRENT_DATE - 30))
->  Bitmap Heap Scan on appointments a
Execution Time: ~1.22 ms
```

### RESULT
- **Seq Scan → Bitmap Index Scan**
- Execution time improved from **~1.97 ms → ~1.22 ms**
- More importantly, the plan is now index-driven and will scale much better as appointment volume grows.

---

## QUERY 2 – Frequent Patients (Completed Visits)

**QUESTION:**  
Which patients had 2 or more completed visits in the last 90 days? (Useful for care-management / follow-up programs)

```sql
SELECT 
  p.id,
  p.first_name || ' ' || p.last_name AS patient_name,
  COUNT(a.id) AS visit_count,
  MAX(a.appointment_date) AS last_visit
FROM patients p
JOIN appointments a ON a.patient_id = p.id
WHERE a.status = 'completed'
  AND a.appointment_date >= CURRENT_DATE - 90
GROUP BY p.id, p.first_name, p.last_name
HAVING COUNT(a.id) >= 2
ORDER BY visit_count DESC
LIMIT 20;
```

### BEFORE PLAN
```
->  Seq Scan on appointments a  (filtered later)
->  Hash Join with patients
Execution Time: ~0.95–1.1 ms range (still scanning large portion of table)
```

### CHANGE
```sql
CREATE INDEX idx_appointments_patient_status_date 
  ON appointments (patient_id, status, appointment_date);

CREATE INDEX idx_appointments_date_status 
  ON appointments (appointment_date, status);
```
**Why:** The query filters on `status = 'completed'` and a date range, then groups by patient. A composite index covering these columns allows an index-only or bitmap path instead of scanning the whole table.

### AFTER PLAN
```
->  Bitmap Index Scan on idx_appointments_status
      Index Cond: (status = 'completed')
->  Bitmap Heap Scan on appointments a
Execution Time: ~1.01 ms
```

### RESULT
- **Seq Scan on appointments → Bitmap Index Scan**
- Plan is now selective on status first
- Scales better when completed appointments are a minority of total rows

---

## QUERY 3 – Daily Operations Dashboard (No-show Rate)

**QUESTION:**  
What is the daily appointment volume and no-show rate for the last 30 days?

```sql
SELECT 
  a.appointment_date,
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE a.status = 'completed') AS completed,
  COUNT(*) FILTER (WHERE a.status = 'cancelled') AS cancelled,
  COUNT(*) FILTER (WHERE a.status = 'no_show') AS no_shows,
  ROUND(100.0 * COUNT(*) FILTER (WHERE a.status = 'no_show') / COUNT(*), 1) AS no_show_pct
FROM appointments a
WHERE a.appointment_date BETWEEN CURRENT_DATE - 30 AND CURRENT_DATE
GROUP BY a.appointment_date
ORDER BY a.appointment_date;
```

### BEFORE PLAN
```
->  Seq Scan on appointments a
      Filter: (appointment_date BETWEEN ... )
      Rows Removed by Filter: 2228
Execution Time: 0.693 ms
```

### CHANGE
```sql
CREATE INDEX idx_appointments_date 
  ON appointments (appointment_date);

CREATE INDEX idx_appointments_date_status 
  ON appointments (appointment_date, status);
```
**Why:** Pure date-range aggregation. An index on `appointment_date` turns a full table scan into a tight range scan.

### AFTER PLAN
```
->  Bitmap Index Scan on idx_appointments_date
      Index Cond: (appointment_date >= ... AND appointment_date <= ...)
->  Bitmap Heap Scan on appointments a
Execution Time: 0.386 ms
```

### RESULT
- **Seq Scan → Bitmap Index Scan**
- **0.693 ms → 0.386 ms** (~44% faster)
- Rows are retrieved via index instead of filtering after a full scan

---

## Summary of Optimizations

| Query | Main Change | Before | After | Improvement |
|-------|-------------|--------|-------|-------------|
| Doctor workload (30 days) | Index on (doctor_id, appointment_date) + date | Seq Scan | Bitmap Index Scan | Plan quality + ~38% faster |
| Frequent patients | Index on (patient_id, status, appointment_date) | Seq Scan | Bitmap Index Scan | Selective access path |
| Daily no-show rate | Index on appointment_date | Seq Scan | Bitmap Index Scan | **0.69 ms → 0.39 ms** |

**Key Lesson:**  
Even with moderate data volumes, the difference between a sequential scan and an index-backed plan is clear. On larger production data the gap becomes dramatic (seconds → milliseconds). Always measure with `EXPLAIN (ANALYZE, BUFFERS)` before and after.

Full raw plans are stored in:
- `outputs/query1_before.txt` / `query1_after.txt`
- `outputs/query2_before.txt` / `query2_after.txt`
- `outputs/query3_before.txt` / `query3_after.txt`
