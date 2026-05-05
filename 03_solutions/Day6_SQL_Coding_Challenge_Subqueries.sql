-- DAY 6: SQL CODING CHALLENGE –SUBQUERIES 
-- Use sql_company_db ; 

-- Single Row Subquery Questions 
-- 1. Find employees whose salary is greater than the average salary of all employees. 
select emp_name from employees where salary > (select avg(salary) from employees);
-- 2. Find employees who earn more than Ravi. 
select emp_name from employees where salary > (select salary from employees where emp_name='ravi');
-- 3. Find employees who joined after Meena.
select emp_name from employees where joining_date > (select joining_date from employees where emp_name='meena');
-- 4. Find employees whose salary is greater than the average salary of the IT department.
select emp_name from employees where salary > (select avg(salary) from employees where dept_id=(select dept_id from departments where dept_name='it')); 
-- 5. Find employees whose performance rating is higher than the average performance rating of all employees. 

-- Multi Row Subquery Questions  
-- 1. Find employees who work in departments located in Chennai or Bangalore. 
SELECT emp_name,dept_id FROM employees e WHERE dept_id IN (SELECT dept_id FROM departments d where e.dept_id=d.dept_id) and city IN ('Chennai', 'Bangalore');
-- 2. Find employees who work in departments located in Pune. 
SELECT emp_name,dept_id FROM employees e WHERE dept_id IN (SELECT dept_id FROM departments d where e.dept_id=d.dept_id) and city ='pune';
-- 3. Find employees whose salary is greater than any employee in the Marketing department. 
select emp_name from employees where salary > 
any(select salary from employees where dept_id =(select dept_id from departments where dept_name='marketing'));
-- 4. Find employees whose salary is greater than all employees in the HR department. 
select emp_name from employees where salary > 
all(select salary from employees where dept_id =(select dept_id from departments where dept_name='hr'));
-- 5. Find employees who belong to departments that have employees with performance rating = 5. 
ALTER TABLE salesteam ADD COLUMN performance_rating INT;
set sql_safe_updates=0;
update salesteam set performance_rating=case
	when sales>90000 then 5
    when sales>80000 then 4
    when sales>70000 then 3
    when sales>60000 then 2
    else 1
end;
select emp_name from employees where dept_id in 
(select dept_id from employees where emp_name in 
(select emp_name from salesteam where performance_rating=5));
-- Correlated Subquery Questions (10) 
-- 1. Find employees whose salary is greater than the average salary of their department. 
select e1.emp_name from employees e1 where e1.salary > (select avg(e2.salary) from employees e2 where e1.dept_id=e2.dept_id);
-- 2. Find employees who earn the highest salary in their department. 
select e1.emp_name from employees e1 where e1.salary = (select max(e2.salary) from employees e2 where e1.dept_id=e2.dept_id);
-- 3. Find employees whose performance rating is higher than the average performance rating in their department. 
SELECT e.emp_name,e.dept_id,s.performance_rating FROM employees e
JOIN salesteam s ON e.emp_name = s.emp_name
WHERE s.performance_rating > (
    SELECT AVG(s2.performance_rating) FROM employees e2 JOIN salesteam s2 ON e2.emp_name = s2.emp_name WHERE e2.dept_id = e.dept_id );
-- 4. Find employees who joined after the average join date of their department. 
select e1.emp_name from employees e1 where joining_date > (select avg(e2.joining_date) from employees e2 where e1.dept_id=e2.dept_id);
-- 5. Find employees whose salary is less than the maximum salary in their department.
select e1.emp_name from employees e1 where e1.salary < (select max(e2.salary) from employees e2 where e1.dept_id=e2.dept_id); 
-- 6. Find employees whose salary is equal to the minimum salary in their department. 
select e1.emp_name from employees e1 where e1.salary = (select min(e2.salary) from employees e2 where e1.dept_id=e2.dept_id);
-- 7. Find departments that have employees earning more than 70000. 
select distinct dept_name from employees e left join departments d on e.dept_id=d.dept_id where salary>70000;
-- 8. Find employees whose salary is greater than at least one employee in their department. 
select e1.emp_name from employees e1 where salary > any(select e2.salary from employees e2 where e1.dept_id=e2.dept_id);
-- 9. Find employees who are the only employee in their department. 
select e1.emp_name from employees e1 where 1 = (select count(*) from employees e2 where e1.dept_id=e2.dept_id);
-- 10. Find employees whose salary is greater than the average salary of employees who joined after them. 
select e1.emp_name from employees e1 where e1.salary >(select avg(e2.salary) from employees e2 where e2.joining_date > e1.joining_date);

