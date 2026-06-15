-- ================================================================
-- FUNCTIONS & STORED PROCEDURES TEMPLATE (TOPIC 12)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
--
-- FUNCTIONS (at least 3):
--   - Each function should encapsulate reusable logic or a
--     calculation relevant to your project domain.
--   - Use CREATE OR REPLACE FUNCTION ... RETURNS ...
--
-- STORED PROCEDURES — SELECT / INSERT (at least 2):
--   - Procedures that retrieve data or insert new records.
--   - Use CREATE OR REPLACE PROCEDURE ...
--
-- STORED PROCEDURES — UPDATE (at least 2):
--   - Procedures that modify existing records.
--
-- FOR EACH FUNCTION / PROCEDURE, ADD COMMENTS EXPLAINING:
--   - Purpose: what it does
--   - Parameters: name, type, meaning
--   - Expected behavior / return value
--
-- TEST CALLS:
--   - Include at least one example call per function/procedure
--     (SELECT my_function(...) or CALL my_procedure(...))
--
-- OPTIONAL:
--   - EXCEPTION blocks for error handling
--   - Transaction management with BEGIN / COMMIT / ROLLBACK
--
-- RECOMMENDED ORDER:
-- 1) Functions
-- 2) SELECT / INSERT procedures
-- 3) UPDATE procedures
-- 4) Test calls
--
-- IMPORTANT:
-- - All routines must execute in PostgreSQL without errors.
-- - Logic must be relevant to your project domain.
-- - Submit everything in this single SQL file.
-- ================================================================

-- Add your functions and procedures below this line

--Yevhen
CREATE OR REPLACE FUNCTION public.get_member_attendance_count(p_member_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    total_attendance INT;
BEGIN
    SELECT COUNT(*)
    INTO total_attendance
    FROM public.attendance
    WHERE member_id = p_member_id;

    RETURN total_attendance;
END;
$$;


-- Test function
SELECT public.get_member_attendance_count(21);

CREATE OR REPLACE PROCEDURE public.insert_member(
    p_full_name VARCHAR,
    p_phone VARCHAR,
    p_email VARCHAR,
    p_date_of_birth DATE,
    p_membership_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate that the membership exists before inserting the member
    IF NOT EXISTS (
        SELECT 1
        FROM public.memberships
        WHERE membership_id = p_membership_id
    ) THEN
        RAISE EXCEPTION 'Membership ID % does not exist', p_membership_id;
    END IF;

    -- Insert a new member
    INSERT INTO public.members (
        full_name,
        phone,
        email,
        date_of_birth,
        membership_id
    )
    VALUES (
        p_full_name,
        p_phone,
        p_email,
        p_date_of_birth,
        p_membership_id
    );
END;
$$;


-- Test procedure
CALL public.insert_member(
    'Test Member',
    '+380501234567',
    'test.member@example.com',
    '1999-01-15',
    2
);

-- Check inserted member
SELECT *
FROM public.members
WHERE email = 'test.member@example.com';

--Tetiana
-- add new fitnes goal (INSERT into FitnessGoals table)
CREATE OR REPLACE PROCEDURE add_fitness_goal(
    p_member_id INT,
    p_goal_description VARCHAR(100),
    p_target_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO FitnessGoals (
        member_id,
        goal_description,
        target_date,
        achievement_date,
        is_achieved
    )
    VALUES (
        p_member_id,
        p_goal_description,
        p_target_date,
        NULL,
        FALSE
    );
END;
$$;

CALL add_fitness_goal(
    21,
    'Lose 5 kg',
    '2026-12-31'
);


-- SELECT from FitnessGoals by member_id
CREATE OR REPLACE FUNCTION get_member_goals(
    p_member_id INT
)
RETURNS TABLE (
    goal_id INT,
    goal_description VARCHAR(100),
    target_date DATE,
    achievement_date DATE,
    is_achieved BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        fg.goal_id,
        fg.goal_description,
        fg.target_date,
        fg.achievement_date,
        fg.is_achieved
    FROM FitnessGoals fg
    WHERE fg.member_id = p_member_id;
END;
$$;

SELECT * FROM get_member_goals(21);

--Anton
CREATE OR REPLACE FUNCTION public.get_member_goals(
    p_member_id INT
)
RETURNS TABLE (
    goal_id INT,
    goal_description VARCHAR(100),
    target_date DATE,
    achievement_date DATE,
    is_achieved BOOLEAN
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        fg.goal_id,
        fg.goal_description,
        fg.target_date,
        fg.achievement_date,
        fg.is_achieved
    FROM public.fitnessgoals fg
    WHERE fg.member_id = p_member_id;
END;
$$;

CREATE OR REPLACE PROCEDURE public.add_fitness_goal(
    p_member_id INT,
    p_goal_description VARCHAR(100),
    p_target_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM public.members
        WHERE member_id = p_member_id 
    ) THEN
        RAISE EXCEPTION 'Member ID % does not exist. Insert aborted.', p_member_id;
    END IF;

    INSERT INTO public.fitnessgoals (
        member_id,
        goal_description,
        target_date,
        achievement_date,
        is_achieved
    )
    VALUES (
        p_member_id,
        p_goal_description,
        p_target_date,
        NULL,
        FALSE
    );
END;
$$;

SELECT * FROM public.get_member_goals(21);

CALL public.add_fitness_goal(21, 'Lose 5 kg', '2026-12-31');

--Ihor
--update
CREATE OR REPLACE PROCEDURE public.mark_goal_achieved(
    p_goal_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.fitnessgoals
    SET
        is_achieved = TRUE,
        achievement_date = CURRENT_DATE
    WHERE goal_id = p_goal_id;
END;
$$;

-- Test
CALL public.mark_goal_achieved(1);

SELECT *
FROM public.fitnessgoals
WHERE goal_id = 1;
--update2
CREATE OR REPLACE PROCEDURE public.update_equipment_status(
    p_equipment_id INT,
    p_new_status VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.equipment
    SET equipment_status = p_new_status
    WHERE equipment_id = p_equipment_id;
END;
$$;

-- Test
CALL public.update_equipment_status(
    1,
    'in use'
);

SELECT *
FROM public.equipment
WHERE equipment_id = 1;


-- Anatolii

REVOKE CREATE ON SCHEMA public FROM PUBLIC;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
REVOKE USAGE, SELECT ON SEQUENCES FROM role_views_readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
REVOKE USAGE, SELECT ON SEQUENCES FROM role_readwrite;

-- READ ONLY ROLE

GRANT role_views_readonly TO user_views_readonly;

GRANT CONNECT ON DATABASE postgres TO role_views_readonly;
GRANT USAGE ON SCHEMA public TO role_views_readonly;

GRANT SELECT ON public.VwClassScheduleDetails TO role_views_readonly;
GRANT SELECT ON public.VwAvailableEquipment TO role_views_readonly;
GRANT SELECT ON public.VwUnreturnedEquipment TO role_views_readonly;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public
TO role_views_readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO role_views_readonly;

-- READ WRITE ROLE

GRANT role_readwrite TO user_readwrite;

GRANT CONNECT ON DATABASE postgres TO role_readwrite;
GRANT USAGE ON SCHEMA public TO role_readwrite;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO role_readwrite;

GRANT CREATE ON SCHEMA public
TO role_readwrite;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public
TO role_readwrite;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO role_readwrite;
