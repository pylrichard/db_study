USE study;
-- 计算阶乘
DROP TABLE IF EXISTS tbl_proc_test;
CREATE TEMPORARY TABLE tbl_proc_test(num BIGINT);
DROP PROCEDURE IF EXISTS proc_test;

delimiter //
CREATE PROCEDURE proc_test
(IN total INT, OUT res INT)
BEGIN
	DECLARE i INT;
    SET i = 1;
    SET res = 1;
    IF total <= 0 THEN
		SET total = 1;
	END IF;
    WHILE i <= total DO
		SET res = res * i;
        INSERT INTO tbl_proc_test(num) VALUES(res);
        SET i = i + 1;
	END WHILE;
END ;//
delimiter ;

CALL proc_test(10, @a);
SELECT @a;
SELECT 
    *
FROM
    tbl_proc_test;

-- 函数不能返回结果集
DROP FUNCTION IF EXISTS func_test;

delimiter //
CREATE FUNCTION func_test(total INT)
RETURNS BIGINT
BEGIN
	DECLARE i INT;
    DECLARE res INT;
    SET i = 1;
    SET res = 1;
    IF total <= 0 THEN
		SET total = 1;
	END IF;
    WHILE i <= total DO
		SET res = res * i;
        SET i = i + 1;
	END WHILE;
    RETURN res;
END ;//
delimiter ;

SELECT func_test(10);
