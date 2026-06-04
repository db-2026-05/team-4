-- ================================================================
-- SQL VIEWS TEMPLATE (TOPIC 10)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) CREATE VIEW scripts for required view types:
--    - Horizontal view (select specific columns)
--    - Vertical view (filter specific rows)
--    - Mixed view (columns + row filters)
--    - Join-based view (multiple tables)
--    - Subquery-based view
--    - UNION-based view
--    - View based on another view
--    - Updatable view with WITH CHECK OPTION
--
-- 2) Comments before each view explaining:
--    - Purpose of the view
--    - How it supports your project design
--
-- 3) Optional demo SELECT statements to show view output.
--
-- RECOMMENDED ORDER:
-- 1) Simple views (horizontal / vertical / mixed)
-- 2) Join and subquery views
-- 3) UNION and layered views
-- 4) CHECK OPTION view
--
-- IMPORTANT:
-- - Script must execute in PostgreSQL without errors.
-- - Keep naming consistent and readable.
-- - Submit all views in this single SQL file.
-- ================================================================

-- Add your CREATE VIEW statements below this line

--Yewhen
CREATE VIEW public.VwActiveBasicMembers AS
SELECT
    member_id,
    full_name,
    phone,
    email,
    date_of_birth,
    membership_id
FROM public.members
WHERE membership_id = 1;

SELECT *
FROM public.VwActiveBasicMembers;


CREATE VIEW public.VwAllContacts AS
SELECT
    member_id AS person_id,
    full_name AS full_name,
    phone AS phone,
    email AS email,
    'member' AS person_type
FROM public.members

UNION

SELECT
    trainer_id AS person_id,
    first_name || ' ' || last_name AS full_name,
    phone_number AS phone,
    email AS email,
    'trainer' AS person_type
FROM public.trainers;
--Anatolii
CREATE VIEW public.VwClassScheduleDetails AS
SELECT
    cs.class_schedule_id,
    c.class_name,
    c.room_number,
    cs.start_time,
    cs.end_time
FROM public.classschedule cs
JOIN public.classes c ON cs.class_id = c.class_id;

SELECT * FROM public.VwClassScheduleDetails;



CREATE VIEW public.VwAvailableEquipment AS
SELECT
    equipment_id,
    equipment_name,
    equipment_status,
    quantity
FROM public.equipment
WHERE equipment_status = 'available';

SELECT * FROM public.VwAvailableEquipment;



CREATE VIEW public.VwUnreturnedEquipment AS
SELECT
    ec.equipment_id,
    e.equipment_name,
    ec.class_schedule_id,
    cs.start_time,
    ec.is_returned
FROM public.equipmentclasses ec
JOIN public.equipment e ON ec.equipment_id = e.equipment_id
JOIN public.classschedule cs ON ec.class_schedule_id = cs.class_schedule_id
WHERE ec.is_returned = FALSE;

SELECT * FROM public.VwUnreturnedEquipment;
--Anton
CREATE OR REPLACE VIEW public.VwMemberAttendanceHistory AS
SELECT
    m.member_id,
    m.full_name AS member_name,
    c.class_name AS attended_class,
    cs.start_time AS session_start,
    t.first_name || ' ' || t.last_name AS trainer_name,
    a.is_private_class
FROM public.members m
JOIN public.attendance a ON m.member_id = a.member_id
JOIN public.classschedule cs ON a.class_schedule_id = cs.class_schedule_id
JOIN public.classes c ON cs.class_id = c.class_id
JOIN public.trainers t ON c.trainer_id = t.trainer_id;

SELECT * FROM public.VwMemberAttendanceHistory ORDER BY session_start DESC LIMIT 5;
--Tetiana
--views that uses subqueries
--view shows trainers with amount of personal trainings less than avg
CREATE OR REPLACE VIEW aptraining_view AS
SELECT t.first_name || ' ' || t.last_name AS full_name
FROM trainers AS t
JOIN (SELECT trainer_id, COUNT(*) AS amount_ptraining
FROM personaltraining
GROUP BY trainer_id) AS pt
ON t.trainer_id = pt.trainer_id
WHERE amount_ptraining < (
  SELECT AVG(amount_ptraining)
  FROM (
    SELECT trainer_id, COUNT(*) AS amount_ptraining
    FROM personaltraining
    GROUP BY trainer_id) AS pta
)
ORDER BY full_name;


--join view, shows names of trainers and their specializations
CREATE OR REPLACE VIEW trainers_and_specializations_join_view AS
SELECT t.first_name || ' ' || t.last_name AS full_name, s.specialization_name
FROM trainers AS t
JOIN trainersspecializations AS ts ON t.trainer_id = ts.trainer_id
JOIN specializations AS s ON s.specialization_id = ts.specialization_id
ORDER BY full_name;
--Ihor
--View that selects from another view
CREATE OR REPLACE VIEW VwPrivateAttendanceSummary AS
SELECT
    member_name,
    attended_class,
    trainer_name,
    session_start
FROM VwMemberAttendanceHistory
WHERE is_private_class = TRUE;
--View with CHECK OPTION
CREATE OR REPLACE VIEW VwAvailableEquipmentCheck AS
SELECT
    equipment_id,
    equipment_name,
    equipment_status,
    quantity
FROM Equipment
WHERE equipment_status = 'available'
WITH CHECK OPTION;
