--
-- 1 实时获取有性能问题的SQL
--
SELECT *
FROM information_schema.processlist
WHERE time >= 60;

--
-- 2 批量删除大表数据
--
-- 每次删除5000条，休眠几秒
DELIMITER $$
USE 'imooc'$$
DROP PROCEDURE IF EXISTS 'p_delete_rows'$$
CREATE DEFINER='root'@'127.0.0.1' PROCEDURE 'p_delete_rows'()
BEGIN
  DECLARE v_rows INT;
  SET v_rows = 1;
  WHILE v_rows > 0
  DO
    DELETE FROM sbtest1 WHERE id >= 9000 AND id <= 19000 LIMIT 5000;
  END WHILE;
END$$
DELIMITER ;

--
-- 3 查看SQL各阶段执行时间
--
# USE performance_schema;
# UPDATE setup_instruments
# SET enabled = 'yes', timed = 'yes'
# WHERE name LIKE 'stage%';
# UPDATE setup_consumers
# SET enabled = 'yes'
# WHERE name LIKE 'events%';

-- use biz_db，切换到业务库
-- 执行SQL

USE performance_schema;
SELECT
  a.THREAD_ID,
  SQL_TEXT,
  c.EVENT_NAME,
  (c.TIMER_END - c.TIMER_START) / 1000000000 AS 'DURATION(ms)'
FROM events_statements_history_long a
  JOIN threads b ON a.THREAD_ID = b.THREAD_ID
  JOIN events_stages_history_long c ON c.THREAD_ID = b.THREAD_ID
                                       AND c.EVENT_ID BETWEEN a.EVENT_ID AND a.END_EVENT_ID
-- 查看当前会话执行的SQL
WHERE b.PROCESSLIST_ID = connection_id()
      AND a.EVENT_NAME = 'statement/sql/select'
ORDER BY a.THREAD_ID, c.EVENT_ID;

--
-- 4 优化NOT IN查询
-- 查询未付费用户
--
SELECT customer_id
FROM customer
WHERE customer_id NOT IN (SELECT customer_id
                          FROM payment);
-- 改写为
SELECT a.customer_id
FROM customer a
  LEFT JOIN payment b ON a.customer_id = b.customer_id
WHERE a.customer_id IS NULL;

--
-- 5 汇总表优化查询
--
SELECT count(*)
FROM product_commment
WHERE product_id = 999;
-- 改写为
CREATE TABLE product_comment_cnt (
  product_id INT,
  cnt        INT
);

SELECT sum(cnt)
FROM (SELECT cnt
      FROM product_comment_cnt
      WHERE product_id = 999
      UNION ALL
      SELECT count(*)
      FROM product_comment
      WHERE product_id = 999
            AND time_str > date(now())) a