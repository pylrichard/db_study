--
-- 1 评论分页查询
--
-- SQL语句1
SELECT
  customer_id,
  title,
  content
FROM product_comment
WHERE product_id = 199726
      AND audit_status = 1
LIMIT 0, 5;

--
-- 2 优化评论分页查询第一步
--
-- 计算索引区分度
SELECT
  count(DISTINCT audit_status) / count(*) AS audit_rate,
  count(DISTINCT product_id) / count(*)   AS product_rate
FROM product_comment;
-- product_id的区分度更高，创建复合索引
-- SQL语句1的总IO=索引IO+索引对应的表数据IO
CREATE INDEX i_product_id_audit_status
  ON product_comment (product_id, audit_status);

--
-- 3 优化评论分页查询第二步
--
-- 改写SQL语句1为语句2
-- 要求comment_id为product_comment主键，存在(product_id, audit_status)复合索引
-- SQL语句2的总IO=索引IO+
SELECT
  b.customer_id,
  b.title,
  b.content
FROM (SELECT comment_id
      FROM product_comment
      WHERE product_id = 199726 AND audit_status = 1
      LIMIT 1, 15) a
  JOIN product_comment b ON a.comment_id = b.comment_id LIMIT 0, 10000;