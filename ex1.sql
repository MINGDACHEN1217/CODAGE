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