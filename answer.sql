-- ============================================================
-- MySQL Database Backup Assignment
-- File: answer.sql
-- Student submission for mysqldump backup operations
-- ============================================================

-- ------------------------------------------------------------
-- Question 1: Creating a Complete Database Backup
-- ------------------------------------------------------------
-- Task: Create a complete backup of the 'sales' database.
-- Requirements:
--   - Username: root
--   - Prompt for password
--   - Output file: sales_backup.sql
--
-- Command:
mysqldump -u root -p sales > sales_backup.sql

-- Explanation:
-- The command above uses mysqldump to create a full logical backup of the
-- 'sales' database. The -u root option specifies the MySQL username, and
-- -p forces the utility to prompt for the password (the password is never
-- typed on the command line for security). The database name 'sales' is
-- given as the target, and the > operator redirects the SQL statements
-- (CREATE TABLE, INSERT, etc.) into the file sales_backup.sql.
--
-- Why regular database backups are important:
-- Regular backups protect against data loss caused by hardware failure,
-- human error, software bugs, ransomware, or natural disasters. They form
-- the foundation of any disaster-recovery plan and allow a database to be
-- restored to a known good state quickly. Without recent backups, recovery
-- may be impossible or extremely costly.


-- ------------------------------------------------------------
-- Question 2: Backing Up All Databases
-- ------------------------------------------------------------
-- Task: Create a complete backup of every database on the MySQL server.
-- Requirements:
--   - Use the appropriate option to export all databases
--   - Username: root
--   - Prompt for password
--   - Output file: all_databases_backup.sql
--
-- Command:
mysqldump -u root -p --all-databases > all_databases_backup.sql

-- Explanation:
-- The --all-databases (or -A) option tells mysqldump to dump every database
-- on the server, including the system databases (mysql, information_schema,
-- performance_schema, sys) as well as all user databases. The rest of the
-- options work the same way as in Question 1: authentication is handled by
-- -u root -p, and the output is redirected to all_databases_backup.sql.
--
-- Why backing up all databases is important before migrating to another server:
-- A full-server backup guarantees that no database, stored procedure, user
-- account, or privilege is left behind. During a migration the target server
-- can be restored from this single file, ensuring that application data,
-- configuration data, and security settings are all transferred consistently.
-- This reduces the risk of missing a critical database and shortens the
-- overall migration window.


-- ------------------------------------------------------------
-- Question 3: Generating a Data-Only Backup
-- ------------------------------------------------------------
-- Task: Create a data-only backup of the 'sales' database
--       (structure is omitted; only INSERT statements are produced).
-- Requirements:
--   - Username: root
--   - Prompt for password
--   - Output file: sales_data_only.sql
--
-- Command:
mysqldump -u root -p --no-create-info sales > sales_data_only.sql

-- Explanation:
-- The --no-create-info (or -t) option suppresses all CREATE TABLE statements.
-- Only the data (INSERT statements) is written to the output file. This type
-- of backup is useful when the table structures already exist on the target
-- server and you only need to reload or refresh the data, or when you want a
-- lighter file for data migration or testing.


-- ============================================================
-- End of answer.sql
-- ============================================================
