case WHEN ucp.aa LIKE '%姐%'
    OR ucp.aa LIKE '%妹%'
    OR ucp.aa LIKE '%哥%'
    OR ucp.aa LIKE '%弟%'
    OR ucp.aa LIKE '%儿子%'
    OR ucp.aa LIKE '%女儿%' THEN 2
ELSE 3 END aa_level

-- 把ucp.aa列设计成枚举类型
-- 1=姐
-- 2=妹
-- 3=哥
-- ...
-- 不要使用like
-- int类型比char类型快N倍
WHEN ucp.aa REGEXP '姐'|'妹'|'哥'|'弟'|'儿子'|'女儿' then 2
