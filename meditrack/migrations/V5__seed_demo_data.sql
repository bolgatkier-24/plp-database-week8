-- ============================================================
-- V5__seed_demo_data.sql
-- Realistic demo data for MediTrack
-- ============================================================

-- Departments
INSERT INTO departments (name, description) VALUES
    ('General Medicine', 'Primary care and general consultations'),
    ('Cardiology', 'Heart and cardiovascular care'),
    ('Pediatrics', 'Child and adolescent health'),
    ('Orthopedics', 'Bones, joints and musculoskeletal'),
    ('Emergency', 'Emergency and urgent care');

-- Staff
INSERT INTO staff (department_id, first_name, last_name, email, role, phone, password_hash) VALUES
    (1, 'Kwame', 'Asante', 'kwame.asante@meditrack.local', 'doctor', '+233241000001', crypt('pass123', gen_salt('bf'))),
    (2, 'Ama', 'Mensah', 'ama.mensah@meditrack.local', 'doctor', '+233241000002', crypt('pass123', gen_salt('bf'))),
    (3, 'Kofi', 'Boateng', 'kofi.boateng@meditrack.local', 'doctor', '+233241000003', crypt('pass123', gen_salt('bf'))),
    (1, 'Abena', 'Osei', 'abena.osei@meditrack.local', 'nurse', '+233241000004', crypt('pass123', gen_salt('bf'))),
    (4, 'Yaw', 'Darko', 'yaw.darko@meditrack.local', 'doctor', '+233241000005', crypt('pass123', gen_salt('bf'))),
    (NULL, 'Efua', 'Adjei', 'efua.adjei@meditrack.local', 'receptionist', '+233241000006', crypt('pass123', gen_salt('bf'))),
    (NULL, 'Kojo', 'Appiah', 'kojo.appiah@meditrack.local', 'admin', '+233241000007', crypt('pass123', gen_salt('bf')));

-- Patients
INSERT INTO patients (first_name, last_name, date_of_birth, gender, phone, email, blood_group, emergency_contact_name, emergency_contact_phone) VALUES
    ('Akosua', 'Owusu', '1990-03-15', 'Female', '+233501111111', 'akosua.owusu@email.com', 'O+', 'Kwesi Owusu', '+233501111112'),
    ('Yaw', 'Mensah', '1985-07-22', 'Male', '+233502222222', 'yaw.mensah@email.com', 'A+', 'Ama Mensah', '+233502222223'),
    ('Ama', 'Boateng', '2015-11-05', 'Female', '+233503333333', NULL, 'B+', 'Kofi Boateng', '+233503333334'),
    ('Kofi', 'Asante', '1978-01-30', 'Male', '+233504444444', 'kofi.asante@email.com', 'AB+', 'Abena Asante', '+233504444445'),
    ('Efua', 'Darko', '1995-09-12', 'Female', '+233505555555', 'efua.darko@email.com', 'O-', 'Yaw Darko', '+233505555556'),
    ('Kwame', 'Osei', '2000-05-18', 'Male', '+233506666666', NULL, 'A-', 'Ama Osei', '+233506666667'),
    ('Abena', 'Adjei', '1988-12-03', 'Female', '+233507777777', 'abena.adjei@email.com', 'B-', 'Kojo Adjei', '+233507777778'),
    ('Kojo', 'Owusu', '2010-08-25', 'Male', '+233508888888', NULL, 'O+', 'Akosua Owusu', '+233508888889');

-- Appointments (mix of statuses and dates)
INSERT INTO appointments (patient_id, doctor_id, department_id, appointment_date, start_time, end_time, status, reason, created_by) VALUES
    (1, 1, 1, CURRENT_DATE, '09:00', '09:30', 'scheduled', 'General checkup', 6),
    (2, 2, 2, CURRENT_DATE, '10:00', '10:45', 'scheduled', 'Chest pain follow-up', 6),
    (3, 3, 3, CURRENT_DATE, '11:00', '11:30', 'completed', 'Child fever', 6),
    (4, 1, 1, CURRENT_DATE + 1, '09:00', '09:30', 'scheduled', 'Blood pressure review', 6),
    (5, 5, 4, CURRENT_DATE + 1, '14:00', '14:45', 'scheduled', 'Knee pain', 6),
    (6, 1, 1, CURRENT_DATE - 2, '10:00', '10:30', 'completed', 'Routine checkup', 6),
    (7, 2, 2, CURRENT_DATE - 1, '15:00', '15:45', 'no_show', 'Heart palpitations', 6),
    (8, 3, 3, CURRENT_DATE + 2, '09:30', '10:00', 'scheduled', 'Vaccination', 6),
    (1, 1, 1, CURRENT_DATE - 7, '11:00', '11:30', 'completed', 'Previous visit', 6),
    (2, 2, 2, CURRENT_DATE - 14, '09:00', '09:45', 'completed', 'Initial consultation', 6);

-- Medical Records
INSERT INTO medical_records (patient_id, appointment_id, doctor_id, visit_date, diagnosis, treatment_plan, notes) VALUES
    (3, 3, 3, CURRENT_DATE, 'Viral upper respiratory infection', 'Rest, fluids, paracetamol as needed', 'Child presented with mild fever. No signs of bacterial infection.'),
    (6, 6, 1, CURRENT_DATE - 2, 'Hypertension - controlled', 'Continue current medication, lifestyle advice', 'BP 128/82. Patient compliant with meds.'),
    (1, 9, 1, CURRENT_DATE - 7, 'Healthy adult', 'Annual checkup normal', 'All vitals within normal range.'),
    (2, 10, 2, CURRENT_DATE - 14, 'Atypical chest pain - non cardiac', 'Reassurance, follow-up if worsens', 'ECG normal. Likely musculoskeletal.');

-- Prescriptions
INSERT INTO prescriptions (medical_record_id, medication_name, dosage, frequency, duration_days, instructions) VALUES
    (1, 'Paracetamol', '250mg', 'Every 6-8 hours as needed', 5, 'Give with food if stomach upset occurs'),
    (2, 'Amlodipine', '5mg', 'Once daily', 30, 'Take in the morning'),
    (2, 'Lisinopril', '10mg', 'Once daily', 30, 'Monitor for dry cough');
