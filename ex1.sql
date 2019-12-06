取得每个部门最高薪水的人员名称
1取得每个部门最高薪水
select deptno,max(sal) as maxsal from emp group by deptno;
2将上面当作临时表t t表和emp e表进行表连接
select e.ename,t.* from emp e join (select deptno,max(sal) as maxsal from emp group by deptno) t on e.deptno=t.deptno and t.maxsal=e.sal;