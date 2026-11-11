-- ============================================================
-- V2__indexes.sql
-- Performance indexes for common access patterns
-- ============================================================

-- Staff lookups
CREATE INDEX idx_staff_department_id ON staff(department_id);
CREATE INDEX idx_staff_role ON staff(role);
CREATE INDEX idx_staff_email ON staff(email);

-- Patient searches
CREATE INDEX idx_patients_last_name ON patients(last_name);
CREATE INDEX idx_patients_phone ON patients(phone);
CREATE INDEX idx_patients_email ON patients(email);

-- Appointment queries (very common)
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_doctor_id ON appointments(doctor_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_doctor_date ON appointments(doctor_id, appointment_date);
CREATE INDEX idx_appointments_date_status ON appointments(appointment_date, status);

-- Medical records
CREATE INDEX idx_medical_records_patient_id ON medical_records(patient_id);
CREATE INDEX idx_medical_records_doctor_id ON medical_records(doctor_id);
CREATE INDEX idx_medical_records_visit_date ON medical_records(visit_date);
CREATE INDEX idx_medical_records_appointment_id ON medical_records(appointment_id);

-- Prescriptions
CREATE INDEX idx_prescriptions_medical_record_id ON prescriptions(medical_record_id);
