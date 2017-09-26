-- create database study;
use study;

create table group_concat_test (
    id bigint(20) not null auto_increment,
    num int not null comment '学号',
    score int not null comment '科目成绩',
    primary key (id)
) engine=innodb charset=utf8mb4;

desc group_concat_test;

insert into group_concat_test values(null, 1, 80), (null, 1, 80), (null, 1, 90);

select last_insert_id();

insert into group_concat_test values(null, 2, 70), (null, 2, 80), (null, 2, 60);

select * from group_concat_test;

-- group_concat([distinct] 要连接的字段 [order by asc(默认)/desc 排序字段] [separator '分隔符'])

select num, group_concat(score) as scores from group_concat_test group by num;

select num, group_concat(score separator ';') as scores from group_concat_test group by num;

select num, group_concat(distinct score separator ';') as scores from group_concat_test group by num;

select num, group_concat(distinct score order by score desc separator ';') as scores from group_concat_test group by num;

-- 返回一行记录
select num, group_concat(score order by score desc separator ';') as scores from group_concat_test;

-- 设置最大长度
show variables like 'group_concat_max_len';