-- VIEWS (SIMPLE & COMPLEX) AND TRIGGERS 
use sql_company_db;
/* Question 1 – SIMPLE VIEW: EmployeeBasicView 
Task: Create a simple view named EmployeeBasicView that displays: EmpName, DeptID, and Salary from the Employees table. 
Then, query the view to verify results. 
Expected Output: 
EmpName | DeptID | Salary 
*/
create view employeebasicview as
select emp_name,dept_id,salary from employees;
select * from employeebasicview;
/* Question 2 – COMPLEX VIEW: EmployeeDepartmentView 
Scenario: 
Management needs a detailed view combining employee and department information. 
Task: 
Create a complex view named EmployeeDepartmentView 
that joins Employees and Departments to show: 
EmpName, DeptName, Location, and Salary. 
Expected Output: 
EmpName | DeptName | Location | Salary 
*/
create view EmployeeDepartmentView as
select emp_name as EmpName,dept_name DeptName,city Location,salary Salary from employees e join departments d on e.dept_id=d.dept_id;
select * from EmployeeDepartmentView;
/* Question 3 – COMPLEX VIEW with Aggregation 
Scenario: 
The finance department wants to analyze average salary and employee count per department. 
Task: 
Create a complex view named DeptSalaryStats 
that shows each department’s name, average salary, and number of employees. 
Expected Output: 
DeptName | AvgSalary | TotalEmployees 
*/
create view DeptSalaryStats as
 select dept_name DeptName,avg(salary) AvgSalary,count(emp_id) TotalEmployees 
 from departments d left join employees e on e.dept_id=d.dept_id group by d.dept_id;
 select * from DeptSalaryStats;
/* Question 4 – UPDATE Using VIEW 
Scenario: 
HR wants to increase salary by ₹5,000 for all employees visible in the view. 
Task: 
Use the EmployeeBasicView to update each employee’s salary by ₹5,000. 
Ensure the change reflects in the main Employees table. 
Expected Output: 
EmpName | Updated_Salary 
*/
set sql_safe_updates=0;
update employeebasicview set  salary=salary+5000;
select emp_name EmpName,salary Updated_Salary from employeebasicview;
/* Question 5 – DROP VIEW 
Scenario: 
After the financial analysis is complete, some views are no longer needed. 
Task: 
Drop the DeptSalaryStats view from the database. 
Expected Output: 
Confirmation that the view was removed successfully. 
*/
drop view DeptSalaryStats;
/* Question 6 – TRIGGER (BEFORE INSERT) 
Scenario: 
HR wants to prevent inserting an employee with a salary below ₹30,000. 
Task: 
Create a BEFORE INSERT trigger named check_min_salary 
on the Employees table to block any insert with Salary < 30000. 
Expected Output: 
Attempt to insert such a record → should return an error message like 
"Salary must be at least 30000" 
*/
delimiter //
create trigger check_min_salary
before insert on employees
for each row
begin
	if new.salary <=30000 then
		signal sqlstate '45000'
        set message_text="Salary must be at least 30000" ;
	end if;
end //
delimiter ;

select * from employees;
insert into employees(emp_id, emp_name, dept_id, salary, city) values(112,'Sara',5,80000,'Trichy');
/* Question 7 – TRIGGER (AFTER INSERT – Audit Log) 
Scenario: 
The admin team wants to keep a record every time a new employee is added. 
Task: 
Create a new table EmployeeAudit(EmpID, EmpName, Action, ActionDate). 
Then create an AFTER INSERT trigger named log_employee_insert 
to insert a record into EmployeeAudit whenever a new employee is added. 
Expected Output: 
EmployeeAudit table shows log entries: 
EmpID | EmpName | Action | ActionDate 
*/
drop table EmployeeAudit;
create table EmployeeAudit(
emp_id int, 
emp_name varchar(50), 
action_performed varchar(50), 
action_date date
);
select * from EmployeeAudit;
delimiter //
create trigger log_employee_insert
after insert on employees
for each row
begin
	insert into EmployeeAudit(emp_id, emp_name, action_performed, action_date)
    values(new.emp_id,new.emp_name,"insert on employees",curdate());
end //
delimiter ;
/* Question 8 – TRIGGER (AFTER UPDATE – Salary Change Log) 
Scenario: 
Finance wants to track salary changes for compliance. 
Task: 
Create a table SalaryLog(EmpID, OldSalary, NewSalary, ChangeDate). 
Then create an AFTER UPDATE trigger named log_salary_change 
that logs every time an employee’s salary is updated. 
Expected Output: 
SalaryLog shows: 
EmpID | OldSalary | NewSalary | ChangeDate 
*/
create table SalaryLog(
emp_id int,
old_salary decimal(10,2),
new_salary decimal(10,2),
change_date date);
select * from salarylog;
delimiter //
create trigger log_salary_change
after update on employees
for each row
begin
insert into salarylog(emp_id, old_salary, new_salary, change_date) values(new.emp_id,old.salary,new.salary,curdate());
end //
delimiter ;
select * from salarylog;
/* Question 9 – TRIGGER (BEFORE DELETE – Block Action) 
Scenario: 
The HR policy restricts deleting employees from the IT department. 
Task: 
Create a BEFORE DELETE trigger named prevent_it_delete 
that prevents deletion of employees where DeptID corresponds to the IT department. 
Expected Output: 
When trying to delete such an employee → show an error message like 
"Cannot delete employees from IT department" 
*/
delimiter //
create trigger prevent_it_delete
before delete on employees
for each row
begin
declare temp_id int;
select dept_id into temp_id from departments where dept_name='IT';
if old.dept_id=temp_id then
	signal sqlstate '45000'
    set message_text="Cannot delete employees from IT department" ;
end if;
end //
delimiter ;

select * from employees;
select * from departments;
delete from employees where emp_id=101;

/* Question 10 – TRIGGER (AFTER DELETE – Archive Record) 
Scenario: 
When any employee leaves the company, HR wants their record saved in an archive table. 
Task: 
Create a new table EmployeeArchive(EmpID, EmpName, DeptID, Salary, ExitDate). 
Then create an AFTER DELETE trigger named archive_deleted_employee 
that automatically inserts the deleted record into EmployeeArchive. 
Expected Output: 
Deleted employee appears in EmployeeArchive with exit timestamp. 
*/
create table EmployeeArchive( 
emp_id int,
emp_name varchar(50),
dept_id int,
salary decimal(10,2),
exit_date date
);
delimiter //
create trigger archive_deleted_employee
after delete on employees
for each row
begin
insert into EmployeeArchive(emp_id, emp_name, dept_id, salary, exit_date) 
values(old.emp_id,old.emp_name,old.dept_id,old.salary,curdate());
end //
delimiter ;
delete from employees where emp_id=112;
 select * from EmployeeArchive;
 