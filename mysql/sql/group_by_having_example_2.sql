CREATE TABLE t_1 (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL
);

INSERT INTO t_1 VALUES (NULL, 1), (NULL, 2), (NULL, 3);

CREATE TABLE t_2 (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    status SMALLINT NULL
);

INSERT INTO t_2 VALUES (NULL, 2, 0), (NULL, 2, 1), (NULL, 3, 0);

SELECT
    t_2.user_id,
    t_2.status
FROM t_1
  LEFT JOIN t_2 ON t_1.user_id = t_2.user_id
GROUP BY t_1.user_id
-- 获取user_id为空或者user_id不为空并且不存在status = 1的分组记录
-- 分组存在status = 1的记录，则过滤掉该分组记录
HAVING t_2.user_id IS NULL OR MAX(t_2.status) = 0;