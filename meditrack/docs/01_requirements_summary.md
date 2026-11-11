# MediTrack – Requirements Summary

**Project:** MediTrack – Hospital Patient Records & Appointment System  
**Track:** Hospital Management (Patient Records + Appointments)

## Problem Statement
Hospitals need a reliable system to manage patient demographics, medical history, and appointment scheduling while protecting sensitive health data and supporting different staff roles (doctors, nurses, receptionists, administrators).

## Core Goals
- Maintain accurate patient records and visit history
- Schedule, reschedule, and track appointments efficiently
- Support role-based access so staff only see what they need
- Provide basic operational reports
- Keep an immutable audit trail of critical changes
- Cache frequently accessed data for better performance

## Key Users
| Role | Responsibilities |
|------|------------------|
| Receptionist | Register patients, book/manage appointments |
| Doctor | View assigned appointments, update medical notes |
| Nurse | View patient info, assist with records |
| Admin | Manage staff, departments, system configuration |

## Functional Requirements
1. Patient registration and profile management
2. Appointment booking with status tracking (Scheduled, Completed, Cancelled, No-show)
3. Medical visit/encounter notes linked to appointments
4. Department and doctor management
5. Role-based access control
6. Audit logging of changes to patient and appointment data
7. Basic analytical queries

## Non-Functional Requirements
- Data privacy (sensitive fields protected, RLS)
- Least-privilege database roles
- Repeatable schema via migrations
- Caching layer for hot data
- Backup & restore capability

## Out of Scope
- Billing / invoicing
- Pharmacy inventory
- Full EHR (lab results, imaging)
- Patient-facing mobile app
