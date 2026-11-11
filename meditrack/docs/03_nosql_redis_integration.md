# Day 3 – NoSQL Layer: Redis Integration

## Why Redis?

PostgreSQL is excellent for durable, relational data (patients, appointments, medical records).  
However, several access patterns in a hospital system are **high-read, short-lived, or temporary**. These are better served by Redis.

### Problems Redis Solves Better Than PostgreSQL

| Use Case | Why PostgreSQL is not ideal | Why Redis is better |
|----------|-----------------------------|---------------------|
| **Today's appointments board** | Repeated full-table or date-filtered queries under load | Extremely fast in-memory reads; can expire automatically at end of day |
| **Doctor availability / schedule cache** | Hitting the appointments table on every booking check | Pre-computed slots cached for seconds/minutes |
| **Double-booking prevention (temporary lock)** | Requires careful transaction + row locking | Simple `SET key NX EX 30` distributed lock |
| **Hot patient lookup by phone** | Index scan is fine but still disk-based under heavy load | Sub-millisecond cache for reception desk |
| **Session / auth tokens** | Possible but heavier | Native TTL support, built for this |

We deliberately **do not** put core patient medical records or long-term appointment history into Redis. Those stay in PostgreSQL (source of truth).

---

## Redis Key Design

```
# Today's appointments for the whole hospital
meditrack:appointments:today          → List or Hash of appointment summaries

# Appointments for a specific doctor on a date
meditrack:doctor:{doctor_id}:schedule:{date}   → List of time slots

# Temporary lock while booking a slot
meditrack:lock:slot:{doctor_id}:{date}:{time}  → "1" (with 30s TTL)

# Cached patient by phone (hot lookup)
meditrack:patient:phone:{phone}       → JSON patient summary (TTL 10 min)

# Simple session
meditrack:session:{token}             → staff_id + role (TTL 8 hours)
```

---

## Integration Approach

1. **Write path (PostgreSQL is source of truth)**  
   - When an appointment is created/updated/cancelled → update PostgreSQL  
   - Then invalidate or refresh the relevant Redis keys

2. **Read path (cache-aside pattern)**  
   - Check Redis first for today’s board or doctor schedule  
   - On miss → query PostgreSQL → populate Redis with short TTL

3. **Booking flow with lock**  
   ```
   1. SET meditrack:lock:slot:3:2026-11-09:10:00 NX EX 30
   2. If OK → check PostgreSQL for real conflicts → insert appointment
   3. Delete the lock key
   4. Refresh the doctor’s schedule cache
   ```

---

## Example Code (Python + redis-py)

```python
import redis
import json
import psycopg2
from datetime import date

r = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)

def get_todays_appointments():
    """Cache-aside: today's appointment board"""
    cache_key = "meditrack:appointments:today"
    cached = r.get(cache_key)
    if cached:
        return json.loads(cached)

    # Cache miss → PostgreSQL
    conn = psycopg2.connect("dbname=capstone user=meditrack_clinical")
    cur = conn.cursor()
    cur.execute("""
        SELECT a.id, p.first_name || ' ' || p.last_name AS patient,
               s.first_name || ' ' || s.last_name AS doctor,
               a.start_time, a.status, a.reason
        FROM appointments a
        JOIN patients p ON p.id = a.patient_id
        JOIN staff s ON s.id = a.doctor_id
        WHERE a.appointment_date = CURRENT_DATE
        ORDER BY a.start_time
    """)
    rows = [dict(zip([d[0] for d in cur.description], row)) for row in cur.fetchall()]
    conn.close()

    # Store in Redis with 2-minute TTL
    r.setex(cache_key, 120, json.dumps(rows, default=str))
    return rows


def try_lock_slot(doctor_id: int, appt_date: str, start_time: str) -> bool:
    """Prevent double-booking with a short-lived lock"""
    key = f"meditrack:lock:slot:{doctor_id}:{appt_date}:{start_time}"
    # NX = only set if not exists, EX = expire after 30 seconds
    return r.set(key, "1", nx=True, ex=30) is True


def invalidate_today_cache():
    r.delete("meditrack:appointments:today")
```

---

## Justification Summary (for presentation)

- **PostgreSQL** remains the system of record for all durable patient and clinical data.
- **Redis** is used only for:
  - High-frequency read caches (today’s board, doctor schedules)
  - Short-lived coordination (booking locks)
  - Session data
- This keeps the architecture simple, easy to explain, and aligned with real hospital systems that use Redis (or similar) in front of their relational database.

---

## What was deliberately left in PostgreSQL
- Patient demographics and history
- Full appointment history
- Medical records and prescriptions
- Audit log
- Staff and department master data

These require strong consistency, complex queries, and long-term durability — all strengths of PostgreSQL.
