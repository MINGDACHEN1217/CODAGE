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