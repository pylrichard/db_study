-- 见log_bin_trust_function_creators变量解释.png
SET GLOBAL log_bin_trust_function_creators = 1;

DROP FUNCTION IF EXISTS rand_string;
DELIMITER $$
CREATE FUNCTION rand_string(num INT)
RETURNS VARCHAR(255)
BEGIN
    DECLARE chars_str VARCHAR(100) DEFAULT 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    DECLARE return_str VARCHAR(255) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    WHILE i < num DO
        -- binlog_format=statement，此处使用随机数，可能会导致主从数据不一致，造成复制中断
        SET return_str = CONCAT(return_str, SUBSTRING(chars_str , FLOOR(1 + RAND() * 62), 1));
        SET i = i + 1;
    END WHILE;
    RETURN return_str;
END $$
DELIMITER ;
