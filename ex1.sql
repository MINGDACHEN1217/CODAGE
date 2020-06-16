cmdwoaini
>>>>>>> 34dc48dc21859f22dabd7c1a62c152bb46547f79
ex1取得每个部门最高薪水的人员名称
1取得每个部门最高薪水
select deptno,max(sal) as maxsal from emp group by deptno;
2将上面当作临时表t t表和emp e表进行表连接
select e.ename,t.* from emp e join (select deptno,max(sal) as maxsal from emp group by deptno) t on e.deptno=t.deptno and t.maxsal=e.sal;

ex2 哪些人薪水在部门平均薪水之上
1找出部门平均薪水 按照部门编号分组求平均值
select avg(sal) as avgsal,deptno from emp group by deptno;
2当作临时表t连接emp e表
条件e.sal>t.avgsal and t.deptno=e.deptno

select t.*,e.ename,e.sal from emp e join (select avg(sal) as avgsal,deptno from emp group by deptno) t on e.sal>t.avgsal and t.deptno=e.deptno;

ex3 取得部门中所有人的平均薪水等级

select e.deptno,avg(s.grade) as avggrade from emp e join salgrade s on e.sal between s.losal and s.hisal group by e.deptno;

ex4 不准用组函数 max 取得最高薪水
第一种方案：按照薪水降序排列，取第一个
select sal from emp order by sal desc limit 1;

第二种方案：自连接
a表和b表进行连接：select distinct a.sal from emp a join emp b on a.sal < b.sal; 唯独没有最高薪水
not in : select sal from emp where sal not in (select distinct a.sal from emp a join emp b on a.sal < b.sal);

ex5 取得平均薪水最高的部门编号 至少给出两种解决方案
	1 select deptno,avg(sal) as avgsal from emp group by deptno order by avgsal desc limit 1; //我的答案 但可能若有多个最大值 则行不通 只能找出一个
	
	第一种方案: 平均薪水降序排列
	1取得每一个部门的平均薪水：select deptno,avg(sal) as avgsal from emp group by deptno；
	2 取得平均薪水最大值： select avg(sal) as avgsal from emp group by deptno order by avgsal desc limit 1;
	3 第一步第二步联合得出答案： select deptno,avg(sal) as avgsal from emp group by deptno having avgsal = (select avg(sal) as avgsal from emp group by deptno order by avgsal desc limit 1);
			
	第二种方案：max函数
	
	select deptno,avg(sal) as avgsal 
	from emp 
	group by deptno 
	having avgsal = (select max(t.avgsal) from (select avg(sal) as avgsal from emp group by deptno) t); //(这里需要有名字t 因为两次select)？
	
	+--------+-------------+
| deptno | avgsal      |
+--------+-------------+
|     10 | 2916.666667 |
+--------+-------------+
	
ex6:取得平均薪水最高的部门的部门名称
	select d.dname as deptname,avg(e.sal) as avgsal
	from emp e
	join dept d
	on e.deptno=d.deptno
	group by d.dname
	having avgsal = (select avg(sal) as avgsal from emp group by deptno order by avgsal desc limit 1);   //可以根据部门名字或者编号分组
	+------------+-------------+
| deptname   | avgsal      |
+------------+-------------+
| ACCOUNTING | 2916.666667 |
+------------+-------------+

ex7 取得平均薪水的等级最高的部门名称
	1取得各部门的平均薪水
	select avg(e.sal) as avgsal, d.dname
	from emp e
	join dept d
	on e.deptno=d.deptno
	group by d.dname;
	
	2 求得各部门平均薪水的等级
	select s.grade,t.dname
	from salgrade s
	join (select avg(e.sal) as avgsal, d.dname from emp e join dept d on e.deptno=d.deptno group by d.dname) t
	on t.avgsal between s.losal and s.hisal;
	+-------+-------------+
| grade | dname       |
+-------+-------------+
|     3 | SALES       |
|     4 | ACCOUNTING  |
|     4 | RESEARCHING |
+-------+-------------+

	
	3 取得最高等级
	select max(s.grade) 
	from salgrade s
	join (select avg(sal) as avgsal from emp group by deptno) t
	on t.avgsal between s.losal and s.hisal;
	
	2 3 联合
	select s.grade,t.dname
	from salgrade s
	join (select avg(e.sal) as avgsal, d.dname from emp e join dept d on e.deptno=d.deptno group by d.dname) t
	on t.avgsal between s.losal and s.hisal
	where s.grade= (select max(s.grade) 
	from salgrade s
	join (select avg(sal) as avgsal from emp group by deptno) t
	on t.avgsal between s.losal and s.hisal);
	
ex8:取得比普通员工（员工代码没有在mgr字段上出现的）的最高薪水高的领导人姓名
第一步：找出普通员工
select * from emp where empno not in( select distinct mgr from emp);
+------+
| mgr  |
+------+
| 7902 |
| 7698 |
| 7839 |
| 7566 |
| NULL |
| 7788 |
| 7782 |
+------+
无法查询到结果，因为not in不能排空 有null会影响查询结果
select * from emp where empno not in( select distinct mgr from emp where mgr is not null);
+-------+--------+----------+------+------------+---------+---------+--------+
| empno | ename  | job      | mgr  | hiredate   | sal     | comm    | deptno |
+-------+--------+----------+------+------------+---------+---------+--------+
|  7369 | SIMITH | CLERK    | 7902 | 1980-12-17 |  800.00 |    NULL |     20 |
|  7499 | ALLEN  | SALESMAN | 7698 | 1981-02-20 | 1600.00 |  300.00 |     30 |
|  7521 | WARD   | SALESMAN | 7698 | 1981-02-22 | 1250.00 |  500.00 |     30 |
|  7654 | MARTIN | SALESMAN | 7698 | 1981-09-28 | 1250.00 | 1400.00 |     30 |
|  7844 | TURNER | SALESMAN | 7698 | 1981-09-08 | 1500.00 |    NULL |     30 |
|  7876 | ADAMS  | CLERK    | 7788 | 1987-05-23 | 1100.00 |    NULL |     20 |
|  7900 | JAMES  | CLERK    | 7698 | 1981-12-03 |  950.00 |    NULL |     30 |
|  7934 | MILLER | CLERK    | 7782 | 1982-01-23 | 1300.00 |    NULL |     10 |
+-------+--------+----------+------+------------+---------+---------+--------+

第二步：找出普通员工最高薪水
select max(sal) from emp where empno not in( select distinct mgr from emp where mgr is not null);

3:找出领导人名字 和薪水 （比1600高的一定是领导人）

select ename,sal from emp where sal> (select max(sal) from emp where empno not in( select distinct mgr from emp where mgr is not null));
+-------+---------+
| ename | sal     |
+-------+---------+
| JONES | 2975.00 |
| BLAKE | 2850.00 |
| CLARK | 2450.00 |
| SCOTT | 3000.00 |
| KING  | 5000.00 |
| FORD  | 3000.00 |
+-------+---------+

补充：not in不会自动忽略空值 但 in会
select * from emp where empno in( select distinct mgr from emp );

补充： case.. when ..then..when..then.. else...end 使用在dql语句中
select ename,sal,(case job when 'manager' then sal*1.1 when 'salesman' then sal*1.5 end) as newsal from emp;
+--------+---------+---------+
| ename  | sal     | newsal  |
+--------+---------+---------+
| SIMITH |  800.00 |    NULL |
| ALLEN  | 1600.00 | 2400.00 |
| WARD   | 1250.00 | 1875.00 |
| JONES  | 2975.00 | 3272.50 |
| MARTIN | 1250.00 | 1875.00 |
| BLAKE  | 2850.00 | 3135.00 |
| CLARK  | 2450.00 | 2695.00 |
| SCOTT  | 3000.00 |    NULL |
| KING   | 5000.00 |    NULL |
| TURNER | 1500.00 | 2250.00 |
| ADAMS  | 1100.00 |    NULL |
| JAMES  |  950.00 |    NULL |
| FORD   | 3000.00 |    NULL |
| MILLER | 1300.00 |    NULL |
+--------+---------+---------+

select ename,sal,(case job when 'manager' then sal*1.1 when 'salesman' then sal*1.5 else sal end) as newsal from emp; 
加入else 其他的职位薪水不变
+--------+---------+---------+
| ename  | sal     | newsal  |
+--------+---------+---------+
| SIMITH |  800.00 |  800.00 |
| ALLEN  | 1600.00 | 2400.00 |
| WARD   | 1250.00 | 1875.00 |
| JONES  | 2975.00 | 3272.50 |
| MARTIN | 1250.00 | 1875.00 |
| BLAKE  | 2850.00 | 3135.00 |
| CLARK  | 2450.00 | 2695.00 |
| SCOTT  | 3000.00 | 3000.00 |
| KING   | 5000.00 | 5000.00 |
| TURNER | 1500.00 | 2250.00 |
| ADAMS  | 1100.00 | 1100.00 |
| JAMES  |  950.00 |  950.00 |
| FORD   | 3000.00 | 3000.00 |
| MILLER | 1300.00 | 1300.00 |
+--------+---------+---------+



 结构化查询语言（Structured Query Languages）简称SQL或“S-Q-L”，是一种数据库查询、程序设计和数据库管理语言，用于存取数据、查询数据、更新数据和管理关系数据库系统；同时也是数据库脚本文件的扩展名。包括以下四种类型。
1、数据操纵语言（Data Manipulation Language）简称 DML：用来操纵数据库中数据的命令。包括：select、insert、update、delete。 
2、数据定义语言（Data Definition Language）简称 DDL：用来建立数据库、数据库对象和定义列的命令。包括：create、alter、drop。 
3、数据控制语言（Data Control Language）简称 DCL：用来控制数据库组件的存取许可、权限等的命令。包括：grant、deny、revoke。 
4、事务控制（Transaction control）:commit、rollback、savepoint。
————————————————

ex9 取得薪水最高的前五名员工
select sal,ename from emp order by sal desc limit 5;
+---------+-------+
| sal     | ename |
+---------+-------+
| 5000.00 | KING  |
| 3000.00 | SCOTT |
| 3000.00 | FORD  |
| 2975.00 | JONES |
| 2850.00 | BLAKE |
+---------+-------+

ex10 取得薪水最高的6-10名员工
select sal,ename from emp order by sal desc limit 5,5;
 （前面的5是位置，从第6个位置开始）	
 +---------+--------+
| sal     | ename  |
+---------+--------+
| 2450.00 | CLARK  |
| 1600.00 | ALLEN  |
| 1500.00 | TURNER |
| 1300.00 | MILLER |
| 1250.00 | MARTIN |
+---------+--------+
 
 ex11 取得最后入职的五名员工
 select ename,hiredate from emp order by hiredate desc limit 5;
+--------+------------+
| ename  | hiredate   |
+--------+------------+
| ADAMS  | 1987-05-23 |
| SCOTT  | 1987-04-19 |
| MILLER | 1982-01-23 |
| FORD   | 1981-12-03 |
| JAMES  | 1981-12-03 |
+--------+------------+
<<<<<<< HEAD
日期也可以进行排列

ex12 取得每个薪水等级有多少员工
1找出每个员工的薪水等级
select e.ename,e.sal,s.grade from emp e join salgrade s on e.sal between s.losal and s.hisal;
+--------+---------+-------+
| ename  | sal     | grade |
+--------+---------+-------+
| SIMITH |  800.00 |     1 |
| ALLEN  | 1600.00 |     3 |
| WARD   | 1250.00 |     2 |
| JONES  | 2975.00 |     4 |
| MARTIN | 1250.00 |     2 |
| BLAKE  | 2850.00 |     4 |
| CLARK  | 2450.00 |     4 |
| SCOTT  | 3000.00 |     4 |
| KING   | 5000.00 |     5 |
| TURNER | 1500.00 |     3 |
| ADAMS  | 1100.00 |     1 |
| JAMES  |  950.00 |     1 |
| FORD   | 3000.00 |     4 |
| MILLER | 1300.00 |     2 |
+--------+---------+-------+
2按照grade 分组并且计数 count（*）
select s.grade,count(*) from emp e join salgrade s on e.sal between s.losal and s.hisal group by s.grade;
+-------+----------+
| grade | count(*) |
+-------+----------+
|     1 |        3 |
|     2 |        3 |
|     3 |        2 |
|     4 |        5 |
|     5 |        1 |
+-------+----------+
count(*) 它返回检索行的数目， 不论其是否包含 NULL值


ex14 列出所有员工及领导的名字
emp a 员工表
emp b 领导表
select a.ename as employee,b.ename as leader from emp a join emp b on a.mgr = b.empno;

ex15 列出受雇日期早于其直接上级的所有员工的编号，姓名，部门名称
emp a员工表
emp b领导表
 select a.ename,a.empno from emp a join emp b on a.mgr=b.empno on a.hiredate < b.hiredate; //我自己写的
 select c.dname,t.ename,t.empno from dept c join (select a.ename,a.empno,a.deptno from emp a join emp b on a.mgr=b.empno and a.hiredate < b.hiredate) t on t.deptno=c.deptno;
 //结果一样
 select a.ename,a.empno,d.dname from emp a join emp b on a.mgr=b.empno and a.hiredate < b.hiredate join dept d on d.deptno=a.deptno;
 +--------+-------+-------------+
| ename  | empno | dname       |
+--------+-------+-------------+
| CLARK  |  7782 | ACCOUNTING  |
| SIMITH |  7369 | RESEARCHING |
| JONES  |  7566 | RESEARCHING |
| ALLEN  |  7499 | SALES       |
| WARD   |  7521 | SALES       |
| BLAKE  |  7698 | SALES       |
+--------+-------+-------------+


 
 select a.ename,a.empno from emp a join emp b on a.mgr=b.empno where a.hiredate < b.hiredate; //答案 用的where挑选日期
 +--------+-------+
| ename  | empno |
+--------+-------+
| SIMITH |  7369 |
| ALLEN  |  7499 |
| WARD   |  7521 |
| JONES  |  7566 |
| BLAKE  |  7698 |
| CLARK  |  7782 |
+--------+-------+
select a.ename,a.empno,d.dname from emp a join emp b on a.mgr=b.empno join dept d on d.deptno=a.deptno where a.hiredate < b.hiredate; 
+--------+-------+-------------+
| ename  | empno | dname       |
+--------+-------+-------------+
| CLARK  |  7782 | ACCOUNTING  |
| SIMITH |  7369 | RESEARCHING |
| JONES  |  7566 | RESEARCHING |
| ALLEN  |  7499 | SALES       |
| WARD   |  7521 | SALES       |
| BLAKE  |  7698 | SALES       |
+--------+-------+-------------+

ex16 : 列出部门名称和这些部门的员工信息，同时列出那些没有员工的部门
外连接： emp e员工表 dept d部门表
左向外联接的结果集包括 LEFT OUTER子句中指定的左表的所有行，而不仅仅是联接列所匹配的行。如果左表的某行在右表中没有匹配行，则在相关联的结果集行中右表的所有选择列表列均为空值。
右向外联接是左向外联接的反向联接。将返回右表的所有行。如果右表的某行在左表中没有匹配行，则将为左表返回空值。
select e.*,d.dname from emp e right join dept d on e.deptno=d.deptno;
+-------+--------+-----------+------+------------+---------+---------+--------+-------------+
| empno | ename  | job       | mgr  | hiredate   | sal     | comm    | deptno | dname       |
+-------+--------+-----------+------+------------+---------+---------+--------+-------------+
|  7782 | CLARK  | MANAGER   | 7839 | 1981-06-09 | 2450.00 |    NULL |     10 | ACCOUNTING  |
|  7839 | KING   | PRESIDENT | NULL | 1981-11-17 | 5000.00 |    NULL |     10 | ACCOUNTING  |
|  7934 | MILLER | CLERK     | 7782 | 1982-01-23 | 1300.00 |    NULL |     10 | ACCOUNTING  |
|  7369 | SIMITH | CLERK     | 7902 | 1980-12-17 |  800.00 |    NULL |     20 | RESEARCHING |
|  7566 | JONES  | MANAGER   | 7839 | 1981-04-02 | 2975.00 |    NULL |     20 | RESEARCHING |
|  7788 | SCOTT  | ANALYST   | 7566 | 1987-04-19 | 3000.00 |    NULL |     20 | RESEARCHING |
|  7876 | ADAMS  | CLERK     | 7788 | 1987-05-23 | 1100.00 |    NULL |     20 | RESEARCHING |
|  7902 | FORD   | ANALYST   | 7566 | 1981-12-03 | 3000.00 |    NULL |     20 | RESEARCHING |
|  7499 | ALLEN  | SALESMAN  | 7698 | 1981-02-20 | 1600.00 |  300.00 |     30 | SALES       |
|  7521 | WARD   | SALESMAN  | 7698 | 1981-02-22 | 1250.00 |  500.00 |     30 | SALES       |
|  7654 | MARTIN | SALESMAN  | 7698 | 1981-09-28 | 1250.00 | 1400.00 |     30 | SALES       |
|  7698 | BLAKE  | MANAGER   | 7839 | 1981-05-01 | 2850.00 |    NULL |     30 | SALES       |
|  7844 | TURNER | SALESMAN  | 7698 | 1981-09-08 | 1500.00 |    NULL |     30 | SALES       |
|  7900 | JAMES  | CLERK     | 7698 | 1981-12-03 |  950.00 |    NULL |     30 | SALES       |
|  NULL | NULL   | NULL      | NULL | NULL       |    NULL |    NULL |   NULL | OPERATIONS  |
+-------+--------+-----------+------+------------+---------+---------+--------+-------------+
14个员工外加一个没有员工的部门

ex17：列出至少有五个员工的所有部门部门详细信息）
select count(ename),deptno from emp group by deptno having count(ename)>=5;
对分组结果不满意 用having
+--------------+--------+
| count(ename) | deptno |
+--------------+--------+
|            5 |     20 |
|            6 |     30 |
+--------------+--------+

emp e
dept d
可以多个字段联合分组
select count(e.ename),d.deptno,d.dname,d.loc from emp e join dept d on e.deptno=d.deptno group by d.deptno,d.loc,d.dname having count(e.ename)>=5;
+----------------+--------+-------------+---------+
| count(e.ename) | deptno | dname       | loc     |
+----------------+--------+-------------+---------+
|              5 |     20 | RESEARCHING | DALLAS  |
|              6 |     30 | SALES       | CHICAGO |
+----------------+--------+-------------+---------+

ex18 列出薪金比simith高的所有员工信息
select sal from emp where ename = 'simith';
select * from emp where sal > (select sal from emp where ename = 'simith');


ex19 列出所有 clerk 的姓名 部门名称以及部门人数
select ename from emp where job = 'clerk';
emp e
dept d
部门人数  select deptno,count(deptno) as totalEmp from emp group by deptno; 临时表t
+--------+----------+
| deptno | totalEmp |
+--------+----------+
|     10 |        3 |
|     20 |        5 |
|     30 |        6 |
+--------+----------+

select e.ename,e.job,d.dname,t.totalEmp from dept d join emp e on e.deptno=d.deptno join(select deptno,count(deptno) as totalEmp from emp group by deptno)t on d.deptno = t.deptno where job = 'clerk';
+--------+-------+-------------+----------+
| ename  | job   | dname       | totalEmp |
+--------+-------+-------------+----------+
| SIMITH | CLERK | RESEARCHING |        5 |
| ADAMS  | CLERK | RESEARCHING |        5 |
| JAMES  | CLERK | SALES       |        6 |
| MILLER | CLERK | ACCOUNTING  |        3 |
+--------+-------+-------------+----------+

ex20 列出最低薪金大于1500的各种工作以及从事此工作的全部雇员人数。
select min(sal) as minsal ,job from emp group by job having minsal>1500;
+---------+-----------+
| minsal  | job       |
+---------+-----------+
| 3000.00 | ANALYST   |
| 2450.00 | MANAGER   |
| 5000.00 | PRESIDENT |
+---------+-----------+



select min(sal) as minsal ,job, count(job) from emp group by job having minsal>1500;
+---------+-----------+------------+
| minsal  | job       | count(job) |
+---------+-----------+------------+
| 3000.00 | ANALYST   |          2 |
| 2450.00 | MANAGER   |          3 |
| 5000.00 | PRESIDENT |          1 |


EX21 列出在部门 'sales' 工作的的员工姓名，假定不知道部门编号
select deptno from dept where dname='sales';
select ename from emp where deptno = (select deptno from dept where dname='sales');

EX22 列出薪金高于公司平均薪金的所有员工，所在部门，领导，雇员(ta)的工资等级
MySQL中Between and是包含边界的
select avg(sal) from emp;
select e.ename empname ,d.dname deptname,s.ename leadername , m.grade from emp e join dept d on e.deptno=d.deptno join emp s on e.mgr=s.empno join salgrade m on e.sal between m.losal and m.hisal where e.sal > (select avg(sal) from emp);
+---------+-------------+------------+-------+
| empname | deptname    | leadername | grade |
+---------+-------------+------------+-------+
| JONES   | RESEARCHING | KING       |     4 |
| BLAKE   | SALES       | KING       |     4 |
| CLARK   | ACCOUNTING  | KING       |     4 |
| SCOTT   | RESEARCHING | JONES      |     4 |
| FORD    | RESEARCHING | JONES      |     4 |
+---------+-------------+------------+-------+
少了一个king 因为他没有领导 用左连接
select e.ename empname ,d.dname deptname,s.ename leadername , m.grade from emp e join dept d on e.deptno=d.deptno left join emp s on e.mgr=s.empno join salgrade m on e.sal between m.losal and m.hisal where e.sal > (select avg(sal) from emp);
+---------+-------------+------------+-------+
| empname | deptname    | leadername | grade |
+---------+-------------+------------+-------+
| JONES   | RESEARCHING | KING       |     4 |
| BLAKE   | SALES       | KING       |     4 |
| CLARK   | ACCOUNTING  | KING       |     4 |
| SCOTT   | RESEARCHING | JONES      |     4 |
| KING    | ACCOUNTING  | NULL       |     5 |
| FORD    | RESEARCHING | JONES      |     4 |
+---------+-------------+------------+-------+


EX23 列出与SCOTT 从事相同工作的所有员工及部门名称

select e.ename,e.job,d.dname from emp e join dept d on e.deptno=d.deptno where e.job = (select job from emp where ename = 'scott') and e.ename != 'scott';

+-------+---------+-------------+
| ename | job     | dname       |
+-------+---------+-------------+
| FORD  | ANALYST | RESEARCHING |
+-------+---------+-------------+

EX24 列出薪金等于部门30中员工的薪金的其他员工的姓名和薪金
select distinct sal from emp where deptno=30;
+---------+
| sal     |
+---------+
| 1600.00 |
| 1250.00 |
| 2850.00 |
| 1500.00 |
|  950.00 |
+---------+

select ename,sal,deptno from emp where sal in (select distinct sal from emp where deptno=30) and deptno !=30;

EX24 列出薪金高于部门30工作的所有员工的薪金的员工姓名 薪金和部门

select max(sal) from emp where deptno=30;
select ename,sal,deptno from emp where sal > (select max(sal) from emp where deptno=30);
+-------+---------+--------+
| ename | sal     | deptno |
+-------+---------+--------+
| JONES | 2975.00 |     20 |
| SCOTT | 3000.00 |     20 |
| KING  | 5000.00 |     10 |
| FORD  | 3000.00 |     20 |
+-------+---------+--------+

select e.ename,e.sal,d.dname from emp e join dept d on d.deptno=e.deptno where sal > (select max(sal) from emp where deptno=30);
+-------+---------+-------------+
| ename | sal     | dname       |
+-------+---------+-------------+
| KING  | 5000.00 | ACCOUNTING  |
| JONES | 2975.00 | RESEARCHING |
| SCOTT | 3000.00 | RESEARCHING |
| FORD  | 3000.00 | RESEARCHING |
+-------+---------+-------------+

ex26 列出再每个部门工作的员工数量，平均工资和平均服务期限
select d.deptno,ifnull(avg(e.sal),0),count(e.ename),d.dnamefrom emp e right join dept d on d.deptno = e.deptno group by d.deptno;
再计算平均服务期限
now() 现在的日期
to_days() 日期转换为天数
select d.deptno,ifnull(avg(e.sal),0) as avgsal ,ifnull(avg((to_days(now())-to_days(e.hiredate))/365),0) as avgtime,count(e.ename),d.dname from emp e right join dept d on d.deptno = e.deptno group by d.deptno;

+--------+-------------+-------------+----------------+-------------+
| deptno | avgsal      | avgtime     | count(e.ename) | dname       |
+--------+-------------+-------------+----------------+-------------+
|     10 | 2916.666667 | 38.43376667 |              3 | ACCOUNTING  |
|     20 | 2175.000000 | 36.46082000 |              5 | RESEARCHING |
|     30 | 1566.666667 | 38.73241667 |              6 | SALES       |
|     40 |    0.000000 |  0.00000000 |              0 | OPERATIONS  |
+--------+-------------+-------------+----------------+-------------+
=======
>>>>>>> 34dc48dc21859f22dabd7c1a62c152bb46547f79
