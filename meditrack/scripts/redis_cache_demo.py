#!/usr/bin/env python3
"""
MediTrack – Redis Cache Demo (Day 3)
Demonstrates cache-aside pattern and temporary slot locking.
Works with a real Redis instance. If Redis is unavailable,
it falls back to PostgreSQL-only mode and prints a clear note.
"""

import json
import sys
from datetime import date

try:
    import redis
    REDIS_AVAILABLE = True
except ImportError:
    REDIS_AVAILABLE = False

try:
    import psycopg2
    import psycopg2.extras
except ImportError:
    print("psycopg2 is required. Install with: pip install psycopg2-binary")
    sys.exit(1)


def get_redis():
    if not REDIS_AVAILABLE:
        return None
    try:
        r = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)
        r.ping()
        return r
    except Exception:
        return None


def get_todays_appointments(r):
    """Cache-aside pattern for today's appointments"""
    cache_key = "meditrack:appointments:today"

    if r:
        cached = r.get(cache_key)
        if cached:
            print("[REDIS HIT] Returning today's appointments from cache")
            return json.loads(cached)
        print("[REDIS MISS] Querying PostgreSQL...")

    conn = psycopg2.connect(
        host="localhost",
        dbname="capstone",
        user="postgres",
        password="postgres"
    )
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute("""
        SELECT a.id,
               p.first_name || ' ' || p.last_name AS patient,
               s.first_name || ' ' || s.last_name AS doctor,
               a.start_time::text,
               a.status,
               a.reason
        FROM appointments a
        JOIN patients p ON p.id = a.patient_id
        JOIN staff s ON s.id = a.doctor_id
        WHERE a.appointment_date = CURRENT_DATE
        ORDER BY a.start_time
    """)
    rows = cur.fetchall()
    conn.close()

    result = [dict(row) for row in rows]

    if r:
        r.setex(cache_key, 120, json.dumps(result, default=str))
        print("[REDIS] Cached today's appointments for 120 seconds")

    return result


def try_lock_slot(r, doctor_id, appt_date, start_time):
    """Temporary lock to reduce double-booking risk"""
    if not r:
        print("[LOCK] Redis unavailable – skipping distributed lock")
        return True

    key = f"meditrack:lock:slot:{doctor_id}:{appt_date}:{start_time}"
    acquired = r.set(key, "1", nx=True, ex=30)
    if acquired:
        print(f"[LOCK] Acquired lock for doctor {doctor_id} at {appt_date} {start_time}")
        return True
    else:
        print(f"[LOCK] Slot already locked for doctor {doctor_id} at {appt_date} {start_time}")
        return False


def main():
    print("=" * 60)
    print("MediTrack Redis Integration Demo")
    print("=" * 60)

    r = get_redis()
    if r:
        print("Redis: CONNECTED")
    else:
        print("Redis: NOT AVAILABLE (running in PostgreSQL-only fallback mode)")
        print("       Start Redis and install redis-py to see cache hits.")

    print("\n--- Today's Appointments ---")
    appts = get_todays_appointments(r)
    if not appts:
        print("No appointments scheduled for today.")
    else:
        for a in appts:
            print(f"  #{a['id']:2}  {a['start_time']}  {a['patient']:20}  Dr. {a['doctor']:15}  [{a['status']}]")

    print("\n--- Slot Lock Demo ---")
    today = date.today().isoformat()
    try_lock_slot(r, doctor_id=1, appt_date=today, start_time="09:00")
    try_lock_slot(r, doctor_id=1, appt_date=today, start_time="09:00")  # should fail if Redis is up

    print("\nDemo complete.")


if __name__ == "__main__":
    main()
