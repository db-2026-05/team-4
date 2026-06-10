-- ================================================================
-- DATABASE ADMINISTRATION TEMPLATE (TOPIC 11)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) CREATE ROLE statements for at least 2 distinct roles.
--    Example roles: read-only analyst, read-write editor.
--
-- 2) GRANT statements assigning appropriate permissions to each role:
--    - Read-only role: GRANT SELECT ON ALL TABLES IN SCHEMA ...
--    - Read-write role: GRANT SELECT, INSERT, UPDATE, DELETE ...
--
-- 3) CREATE USER statements for at least 2 users.
--    Each user must be assigned to one of the defined roles.
--
-- 4) Comments before each section explaining the rationale:
--    - Why this role exists
--    - What access it should and should not have
--
-- RECOMMENDED ORDER:
-- 1) Roles + their GRANTs
-- 2) Users + GRANT ROLE TO USER
-- 3) Optional: REVOKE statements for fine-grained restrictions
-- 4) Optional cleanup block (commented out by default):
--    -- DROP USER ...; DROP ROLE ...;
--
-- IMPORTANT:
-- - Use explicit GRANT / REVOKE statements — do not rely on defaults.
-- - Roles must have meaningfully different permission levels.
-- - Script must execute in PostgreSQL without errors.
-- ================================================================

-- Add your script below this line
--Tetiana
--create role
CREATE ROLE fitnessgoals_readwrite_role;
--create user
CREATE USER fitnessgoals_readwrite_user WITH PASSWORD 'fitnessgoals_readwrite';

--assign role
GRANT fitnessgoals_readwrite_role TO fitnessgoals_readwrite_user;
--grant connect to db
GRANT CONNECT ON DATABASE postgres TO fitnessgoals_readwrite_role;
--grant schema usage
GRANT USAGE ON SCHEMA public TO fitnessgoals_readwrite_role;

--allows manage data (SELECT, INSERT, UPDATE) in the public schema, fitnessgoals table.
GRANT SELECT, INSERT, UPDATE
ON TABLE public.fitnessgoals
TO fitnessgoals_readwrite_role;

--needed for insert when tables use serial or identity columns
GRANT USAGE, SELECT
ON SEQUENCE public.fitnessgoals_goal_id_seq
TO fitnessgoals_readwrite_role;

-- fitnessgoals_readwrite_role:
-- Can manage data (SELECT, INSERT, UPDATE) in the public schema, fitnessgoals table.
--Anatolii
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

DROP USER IF EXISTS user_views_readonly;
DROP USER IF EXISTS user_readwrite;
DROP ROLE IF EXISTS role_views_readonly;
DROP ROLE IF EXISTS role_readwrite;

CREATE ROLE role_views_readonly;
CREATE USER user_views_readonly WITH PASSWORD 'ViewsReadonly';
GRANT role_views_readonly TO user_views_readonly;
GRANT CONNECT ON DATABASE postgres TO role_views_readonly;
GRANT USAGE ON SCHEMA public TO role_views_readonly;
GRANT SELECT ON public.VwClassScheduleDetails TO role_views_readonly;
GRANT SELECT ON public.VwAvailableEquipment TO role_views_readonly;
GRANT SELECT ON public.VwUnreturnedEquipment TO role_views_readonly;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO role_views_readonly;

CREATE ROLE role_readwrite;
CREATE USER user_readwrite WITH PASSWORD 'ReadWrite123';
GRANT role_readwrite TO user_readwrite;
GRANT CONNECT ON DATABASE postgres TO role_readwrite;
GRANT USAGE ON SCHEMA public TO role_readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO role_readwrite;
GRANT CREATE ON SCHEMA public TO role_readwrite;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO role_readwrite;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
REVOKE USAGE, SELECT ON SEQUENCES FROM role_views_readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
REVOKE USAGE, SELECT ON SEQUENCES FROM role_readwrite;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO role_views_readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO role_readwrite;

-- Optional cleanup after testing:
-- DROP USER IF EXISTS user_views_readonly;
-- DROP USER IF EXISTS user_readwrite;
-- DROP ROLE IF EXISTS role_views_readonly;
-- DROP ROLE IF EXISTS role_readwrite;
--ADMIN FOR ANTON CLEANUP
CREATE ROLE role_admin_limited;
CREATE USER user_admin_limited WITH PASSWORD 'AdminLimited';
GRANT role_admin_limited TO user_admin_limited;
--Anton
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE USAGE, SELECT ON SEQUENCES FROM role_admin_limited;

DROP USER IF EXISTS user_admin_limited;

DROP ROLE IF EXISTS role_admin_limited;
--Yevhen
--create role
CREATE ROLE role_admin_limited;
--create user
CREATE USER user_admin_limited WITH PASSWORD 'AdminLimited';
--assign role
GRANT role_admin_limited TO user_admin_limited;
--grant connect to db
GRANT CONNECT ON DATABASE postgres TO role_admin_limited;
--grant schema usage
GRANT USAGE ON SCHEMA public TO role_admin_limited;

--limited admin role can manage data and create objects in schema
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO role_admin_limited;

GRANT CREATE
ON SCHEMA public
TO role_admin_limited;

--needed for insert when tables use serial or identity columns
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO role_admin_limited;
--default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO role_admin_limited;

-- role_admin_limited:
-- Can manage data and create objects in the public schema.
-- This is not a full superuser role, so it follows the principle
-- of least privilege.

--Ihor
-- create role
CREATE ROLE role_members_readonly;

-- create user
CREATE USER user_members_readonly WITH PASSWORD 'MembersRead123';

-- assign role
GRANT role_members_readonly TO user_members_readonly;

-- grant connect to db
GRANT CONNECT ON DATABASE postgres TO role_members_readonly;

-- grant schema usage
GRANT USAGE ON SCHEMA public TO role_members_readonly;

-- grant read access only
GRANT SELECT
ON TABLE public.members,
         public.trainers
TO role_members_readonly;

-- role_members_readonly:
-- Can only view data from Members and Trainers tables.
-- Cannot insert, update, delete or create objects.
