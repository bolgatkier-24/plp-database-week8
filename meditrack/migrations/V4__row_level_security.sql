-- ============================================================
-- V4__row_level_security.sql
-- Least-privilege roles + Row Level Security
-- ============================================================

-- Application roles
CREATE ROLE app_readonly;
CREATE ROLE app_receptionist;
CREATE ROLE app_clinical;          -- doctors & nurses
CREATE ROLE app_admin;

-- Database connection grants
GRANT CONNECT ON DATABASE capstone TO app_readonly, app_receptionist, app_clinical, app_admin;
GRANT USAGE ON SCHEMA public TO app_readonly, app_receptionist, app_clinical, app_admin;

-- Table privileges
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly;
GRANT SELECT, INSERT, UPDATE ON patients, appointments TO app_receptionist;
GRANT SELECT ON departments, staff TO app_receptionist;
GRANT SELECT, INSERT, UPDATE ON patients, appointments, medical_records, prescriptions TO app_clinical;
GRANT SELECT ON departments, staff TO app_clinical;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO app_admin;

-- Future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO app_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE ON TABLES TO app_receptionist;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE ON TABLES TO app_clinical;

-- Application users (examples)
CREATE USER meditrack_readonly LOGIN PASSWORD 'readonly_pass' IN ROLE app_readonly;
CREATE USER meditrack_reception LOGIN PASSWORD 'reception_pass' IN ROLE app_receptionist;
CREATE USER meditrack_clinical LOGIN PASSWORD 'clinical_pass' IN ROLE app_clinical;
CREATE USER meditrack_admin LOGIN PASSWORD 'admin_pass' IN ROLE app_admin;

-- Enable RLS on sensitive tables
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;

-- Simple RLS policies (role-based)
-- Note: In a real app we would use current_setting('app.current_user_id') etc.
-- For this school project we use role names for clarity.

-- Patients: clinical & admin can see all; receptionist can see all (needed for booking)
CREATE POLICY patients_select_policy ON patients
    FOR SELECT
    USING (true);   -- all authenticated roles can read (further restricted by GRANT)

CREATE POLICY patients_modify_reception ON patients
    FOR ALL
    TO app_receptionist
    USING (true)
    WITH CHECK (true);

CREATE POLICY patients_modify_clinical ON patients
    FOR ALL
    TO app_clinical
    USING (true)
    WITH CHECK (true);

CREATE POLICY patients_admin ON patients
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);

-- Appointments
CREATE POLICY appointments_select ON appointments
    FOR SELECT
    USING (true);

CREATE POLICY appointments_modify_reception ON appointments
    FOR ALL
    TO app_receptionist
    USING (true)
    WITH CHECK (true);

CREATE POLICY appointments_modify_clinical ON appointments
    FOR ALL
    TO app_clinical
    USING (true)
    WITH CHECK (true);

CREATE POLICY appointments_admin ON appointments
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);

-- Medical records – only clinical staff and admin
CREATE POLICY medical_records_clinical ON medical_records
    FOR ALL
    TO app_clinical
    USING (true)
    WITH CHECK (true);

CREATE POLICY medical_records_admin ON medical_records
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);

-- Prescriptions – same as medical records
CREATE POLICY prescriptions_clinical ON prescriptions
    FOR ALL
    TO app_clinical
    USING (true)
    WITH CHECK (true);

CREATE POLICY prescriptions_admin ON prescriptions
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);
