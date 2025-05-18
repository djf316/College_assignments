create table sf(
 rq date,
shengfu varchar(20)
);
insert into sf values('2024-06-01','胜');
insert into sf values('2024-06-01','胜');
insert into sf values('2024-06-01','负');
insert into sf values('2024-06-02','胜');
insert into sf values('2024-06-02','负');
insert into sf values('2024-06-02','负');
select * from sf;
--将上表按下图显示
/*
rq           胜  负
2024-06-01   2   1
2024-06-02   1   2
*/
select rq,
       sum(case when shengfu='胜' then 1 end) as 胜,
	     sum(case when shengfu='负' then 1 end) as 负
from sf
group by rq

/*2.1根据数据统计
  每天的新增用户
   1,2021/9/1
   2,2021/9/1
   3,2021/9/1
   4,2021/9/1
   5,2021/9/2
   6,2021/9/3*/
select id,min(date(login_dt))
from liucun
group by id
order by id 

/*
--2.2 求连续三天登录的用户id显示结果为下  
id
1
2
4
5
*/
select * from liucun;
select id
from(
			select id,date_sub(login_dt,interval pm day) as diff
			from(
						select id,date(login_dt) as login_dt,row_number()over(partition by id order by login_dt) as pm
						from liucun) t1)t2
group by id,diff 
having count(*)>=3;

-- 2.3
-- 将liucun表按照以下的方式显示
/*
id    start_time  end_time
1      2021/9/1    2021/9/3
2      2021/9/1    2021/9/4
3      2021/9/1    2021/9/1
3      2021/9/3    2021/9/4
4      2021/9/1    2021/9/3
5      2021/9/2    2021/9/4
6      2021/9/3    2021/9/4 */
explain
select id,min(login_dt) as start_time,max(login_dt) as end_time
from(
			select id,login_dt,date_sub(login_dt,interval pm day) as diff
			from(
						select id,date(login_dt) as login_dt,row_number()over(partition by id order by login_dt) as pm
						from liucun) t1)t2
group by id,diff 
order by id;

-- 2.4   根据数据统计次日留存率
/*解释：次日留存率=次日留存数/新增用户数
次日留存数：比如 9月1号新增的用户在9月2号还登录的用户数
9月1号的次日留存率=9月2号登录的用户并且这部分的用户是9月1号
新增的/9月1号新增的用户数*/
select rq,count(t1.id) as 新增用户数,count(t2.id) as 留存用户数,
			 concat(round(count(t2.id)/count(t1.id)*100,2),'%') as 留存率
from(
			select id,min(date(login_dt)) as rq 
			from liucun
			group by id) t1 left join liucun t2 on t1.id=t2.id and t1.rq=date(t2.login_dt)-interval '1' day
group by rq

explain
select id,login_dt from liucun
create index idx_i_l_01 on liucun(id,login_dt)

-- 3.列出至少有三个员工的所有部门和部门信息
explain
select department_id,department_name,manager_id,location_id
from departmentswhere department_id in(select department_id
											 from employees
											 group by department_id
											 having count(*)>=3)
											 
﻿-- 4.列出受雇日期早于直接上级的所有员工的编号，姓名，部门名称
select * from employees;
select t1.employee_id,t1.last_name,department_name
from employees t1 join employees  t2 
on t1.manager_id=t2.employee_id join departments t3
on t1.department_id=t3.department_id
where t1.hire_date<t2.hire_date;

﻿-- 5.列出职位为“ST_CLERK”的姓名和部门名称，部门人数：
select last_name,department_name,deptno_number
from(
			select last_name,department_name,job_id,count(*)over(partition by t2.department_id) deptno_number
			from employees t1 join departments t2
			on t1.department_id=t2.department_id) t3
where job_id='ST_CLERK';

-- 6、查询各个部门的平均工资，以及该部门的员工信息
select e.*,avg(salary)over(partition by department_id) avg_salary
from employees e
order by avg_salary desc;

-- 7.查询学生的总成绩并进行排名
select s_id,sum(s_t_score) total_score,
			 row_number()over(order by sum(s_t_score) desc) pm
from t_score
group by s_id

-- 9. 创建emp2表 表中包含 empno 数值类型  主键 ,
-- ename 字符串类型 非空 ,
-- hiredate 日期类型 ,
-- sal 数值类型 ,--
-- deptno 数值类型 关联departments表department_id的外键
create table emp2(
empno int primary key,
ename varchar(30) not null,
hiredate date,
sal bigint,
deptno int,
foreign key (deptno) references departments (department_id)
)

-- 10.参照employees表中50部门的员工信息将对应的数据插入emp2表中
insert into emp2
select employee_id,last_name,hire_date,salary,department_id
from employees
where department_id=50;
select * from emp2;