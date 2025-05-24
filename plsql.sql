--Procedure
/*
Task: Write a Procedure — check_salary_level
Objective:
Create a procedure that:
Accepts an employee ID as input.
Retrieves the employee’s salary from the employees table.
Prints a salary level message based on this logic:
If salary < 30000 → 'Low Salary'
If salary between 30000 and 70000 → 'Medium Salary'
If salary > 70000 → 'High Salary'
Handle the case if the employee ID is not found (NO_DATA_FOUND).
*/
create or replace procedure check_salary_level(
v_employee_id in number)
 is
v_salary number;
begin
select salary into v_salary from employees1 where employee_id=v_employee_id;
if v_salary < 30000 then
dbms_output.put_line('Low Salary');
elsif v_salary between 30000 and 70000 then
dbms_output.put_line('Medium Salary');
elsif v_salary > 70000 then
dbms_output.put_line('High Salary');
end if;
exception when NO_DATA_FOUND then
dbms_output.put_line('No Data Found');
end check_salary_level;
/
exec check_salary_level(100);
/
--Function

CREATE OR REPLACE FUNCTION get_salary_status(
V_EMPLOYEE_ID IN NUMBER)
RETURN varchar2 IS
V_SALARY NUMBER;
v_status varchar2(50);
BEGIN
select salary into v_salary from employees1 where employee_id=v_employee_id;
if v_salary < 30000 then
v_status:='Low Salary';
elsif v_salary between 30000 and 70000 then
v_status:='Medium Salary';
elsif v_salary > 70000 then
v_status:='High Salary';
end if;
RETURN v_status;
exception when NO_DATA_FOUND then
RETURN'No Data Found';
END get_salary_status;
/

SELECT get_salary_status(18) as status FROM dual;
/

--emp_pkg 

--spec
create or replace package emp_pkg is 
procedure check_salary_level(v_employee_id in number);
FUNCTION get_salary_status(V_EMPLOYEE_ID IN NUMBER) RETURN varchar2;
end emp_pkg ;

create or replace package body emp_pkg is 
procedure check_salary_level(
v_employee_id in number)
 is
v_salary number;
begin
select salary into v_salary from employees1 where employee_id=v_employee_id;
if v_salary < 30000 then
dbms_output.put_line('Low Salary');
elsif v_salary between 30000 and 70000 then
dbms_output.put_line('Medium Salary');
elsif v_salary > 70000 then
dbms_output.put_line('High Salary');
end if;
exception when NO_DATA_FOUND then
dbms_output.put_line('No Data Found');
end check_salary_level;

FUNCTION get_salary_status(
V_EMPLOYEE_ID IN NUMBER)
RETURN varchar2 IS
V_SALARY NUMBER;
v_status varchar2(50);
BEGIN
select salary into v_salary from employees1 where employee_id=v_employee_id;
if v_salary < 30000 then
v_status:='Low Salary';
elsif v_salary between 30000 and 70000 then
v_status:='Medium Salary';
elsif v_salary > 70000 then
v_status:='High Salary';
end if;
RETURN v_status;
exception when NO_DATA_FOUND then
RETURN'No Data Found';
END get_salary_status;
end emp_pkg ;
/
exec emp_pkg.check_salary_level(18) ;
/
select emp_pkg.get_salary_status(18) as status from dual;
/

--- INOUT PARAMETER TASK

CREATE OR REPLACE PROCEDURE adjust_bonus_by_job(
  p_emp_id     IN NUMBER,
  p_job_id     OUT VARCHAR2,
  p_bonus_amt  IN OUT NUMBER
) IS
BEGIN
  SELECT job_id INTO p_job_id FROM employees1 WHERE employee_id = p_emp_id;

  IF p_job_id = 'SA_REP' THEN
    p_bonus_amt := p_bonus_amt * 1.20;
  ELSIF p_job_id = 'IT_PROG' THEN
    p_bonus_amt := p_bonus_amt * 1.15;
  ELSE
    p_bonus_amt := p_bonus_amt * 1.10;
  END IF;

  DBMS_OUTPUT.PUT_LINE('Job ID: ' || p_job_id);
  DBMS_OUTPUT.PUT_LINE('Updated Bonus: ' || p_bonus_amt);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Employee not found.');
END;
/
SET SERVEROUTPUT ON;
DECLARE
  v_job_id   VARCHAR2(20);
  v_bonus    NUMBER := 10000;
BEGIN
  adjust_bonus_by_job(18, v_job_id, v_bonus);
END;
/
SELECT * FROM EMPLOYEES1 ORDER BY EMPLOYEE_ID;
/
ALTER TABLE EMPLOYEES1 ADD BONUS NUMBER;
/
CREATE OR REPLACE PROCEDURE adjust_bonus_by_job(
  p_emp_id     IN NUMBER,
  p_job_id     OUT VARCHAR2,
  p_bonus_amt  IN OUT NUMBER
) IS
  v_current_bonus NUMBER;
BEGIN
  -- Get current job_id and bonus from table
  SELECT job_id, NVL(bonus, 0) INTO p_job_id, v_current_bonus
  FROM employees1
  WHERE employee_id = p_emp_id;

  -- Apply bonus logic on current bonus
  IF p_job_id = 'SA_REP' THEN
    p_bonus_amt := v_current_bonus + (p_bonus_amt * 1.20);
  ELSIF p_job_id = 'IT_PROG' THEN
    p_bonus_amt := v_current_bonus + (p_bonus_amt * 1.15);
  ELSE
    p_bonus_amt := v_current_bonus + (p_bonus_amt * 1.10);
  END IF;

  -- Update the new bonus in the table
  UPDATE employees1
  SET bonus = p_bonus_amt
  WHERE employee_id = p_emp_id;

  DBMS_OUTPUT.PUT_LINE('Bonus updated for Job ID: ' || p_job_id);
  DBMS_OUTPUT.PUT_LINE('New Total Bonus: ' || p_bonus_amt);

  COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Employee not found.');
    ROLLBACK;
END;
/
SET SERVEROUTPUT ON;
DECLARE
  v_job_id VARCHAR2(20);
  v_bonus NUMBER := 10000;
BEGIN
  adjust_bonus_by_job(18, v_job_id, v_bonus);
END;
/
SELECT * FROM EMPLOYEES1;
/
SELECT * FROM DEPARTMENTS1;
/
CREATE OR REPLACE PROCEDURE update_commission_by_dept(
P_EMP_ID IN NUMBER, P_DEPT_NAME OUT VARCHAR2, P_COMMISSION IN OUT NUMBER)
IS 
P_CURRENT_COMMISSION NUMBER;--NVL(COMMISSION_PCT, 0)
BEGIN
SELECT B.DEPARTMENT_NAME,NVL(A.COMMISSION_PCT, 0) 
INTO P_DEPT_NAME,P_CURRENT_COMMISSION
FROM EMPLOYEES1 A INNER JOIN DEPARTMENTS1 B
ON A.DEPARTMENT_ID=B.DEPARTMENT_ID WHERE A.EMPLOYEE_ID=P_EMP_ID;
IF P_DEPT_NAME='Sales' THEN
P_COMMISSION:=P_CURRENT_COMMISSION+(P_CURRENT_COMMISSION*0.2);
ELSIF P_DEPT_NAME='Marketing' THEN
P_COMMISSION:=P_CURRENT_COMMISSION+(P_CURRENT_COMMISSION*0.15);
ELSE 
P_COMMISSION:=P_CURRENT_COMMISSION+(P_CURRENT_COMMISSION*0.10);
END IF;

UPDATE EMPLOYEES1 SET COMMISSION_PCT=P_COMMISSION
WHERE EMPLOYEE_ID=P_EMP_ID;

DBMS_OUTPUT.PUT_LINE('COMMISSION updated for EMPLOYEE_ID '||P_EMP_ID);
DBMS_OUTPUT.PUT_LINE('NEW COMMISSION IS '||P_COMMISSION);
COMMIT;

EXCEPTION
  WHEN NO_DATA_FOUND  THEN
    DBMS_OUTPUT.PUT_LINE('Employee not found.');
    ROLLBACK;
      WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
END;
/

-- Step 1: Set up host variables
VARIABLE v_dept_name VARCHAR2(50);
VARIABLE v_commission NUMBER;

-- Step 2: Set an initial value for commission
BEGIN :v_commission := 0.1; END;
/

-- Step 3: Execute the procedure
EXEC update_commission_by_dept(18, :v_dept_name, :v_commission);

-- Step 4: Check the output
PRINT v_dept_name
PRINT v_commission