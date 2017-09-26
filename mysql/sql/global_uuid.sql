-- 分区表不支持以下表的order_uuid/order_id全局唯一，只能保证分区内order_uuid/order_id唯一，需要自行实现全局唯一
-- 1, 2015-01-01
-- 2, 2015-01-02
-- 1, 2015-02-01
-- 2, 2015-02-02
-- 1在p0和p1分区重复出现

CREATE TABLE orders (
	-- 可以通过应用程序主键生成器生成，Java有GUID()，MySQL有uuid()
    order_uuid VARCHAR(128),
    order_date DATETIME,
    PRIMARY KEY (order_uuid , order_date)
) ENGINE=INNODB PARTITION BY RANGE COLUMNS (order_date) (
	PARTITION p0 VALUES LESS THAN ('2015-01-01'), 
    PARTITION p1 VALUES LESS THAN ('2015-02-01')
);

-- 另一种做法
CREATE TABLE orders (
    order_id BIGINT AUTO_INCREMENT,
    order_date DATETIME,
    PRIMARY KEY (order_id , order_date)
) ENGINE=INNODB PARTITION BY RANGE COLUMNS (order_date) (
	PARTITION p0 VALUES LESS THAN ('2015-01-01'), 
    PARTITION p1 VALUES LESS THAN ('2015-02-01')
);

-- 使用单独一张表生成订单id
CREATE TABLE order_id (
    order_id BIGINT AUTO_INCREMENT,
    PRIMARY KEY (order_id)
);

BEGIN;
-- order_id表的主键order_id保证了orders表的主键order_id全局唯一
INSERT INTO order_id VALUE(NULL);
INSERT INTO orders VALUES(LAST_INSERT_ID(), NOW());
COMMIT;
