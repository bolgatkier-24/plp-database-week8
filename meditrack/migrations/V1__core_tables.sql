-- ============================================================
-- V1__core_tables.sql
-- MediTrack – Core schema for Hospital Patient Records & Appointments
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Departments
CREATE TABLE departments (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL UNIQUE,
    description     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Staff (doctors, nurses, receptionists, admins)
CREATE TABLE staff (
    id              SERIAL PRIMARY KEY,
    department_id   INT REFERENCES departments(id),
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    role            VARCHAR(20) NOT NULL CHECK (role IN ('doctor', 'nurse', 'receptionist', 'admin')),
    phone           VARCHAR(20),
    password_hash   TEXT,                          -- for application login (hashed)
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Patients
CREATE TABLE patients (
    id                      SERIAL PRIMARY KEY,
    first_name              VARCHAR(50) NOT NULL,
    last_name               VARCHAR(50) NOT NULL,
    date_of_birth           DATE NOT NULL,
    gender                  VARCHAR(10),
    phone                   VARCHAR(20),
    email                   VARCHAR(100),
    address                 TEXT,
    blood_group             VARCHAR(5),
    emergency_contact_name  VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Appointments
CREATE TABLE appointments (
    id                  SERIAL PRIMARY KEY,
    patient_id          INT NOT NULL REFERENCES patients(id),
    doctor_id           INT NOT NULL REFERENCES staff(id),
    department_id       INT REFERENCES departments(id),
    appointment_date    DATE NOT NULL,
    start_time          TIME NOT NULL,
    end_time            TIME,
    status              VARCHAR(20) NOT NULL DEFAULT 'scheduled'
                        CHECK (status IN ('scheduled', 'completed', 'cancelled', 'no_show')),
    reason              TEXT,
    notes               TEXT,
    created_by          INT REFERENCES staff(id),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Medical Records (visit notes)
CREATE TABLE medical_records (
    id              SERIAL PRIMARY KEY,
    patient_id      INT NOT NULL REFERENCES patients(id),
    appointment_id  INT REFERENCES appointments(id),
    doctor_id       INT NOT NULL REFERENCES staff(id),
    visit_date      DATE NOT NULL,
    diagnosis       TEXT,
    treatment_plan  TEXT,
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Prescriptions
CREATE TABLE prescriptions (
    id                  SERIAL PRIMARY KEY,
    medical_record_id   INT NOT NULL REFERENCES medical_records(id) ON DELETE CASCADE,
    medication_name     VARCHAR(100) NOT NULL,
    dosage              VARCHAR(50),
    frequency           VARCHAR(50),
    duration_days       INT,
    instructions        TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Simple updated_at trigger helper
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_patients_updated_at
    BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
