### 慢查询

- 分析慢查询日志

```sql
-- 查看查询时间的前 10 条
mysqldumpslow -t 10 /usr/local/var/mysql/bogon-slow.log;

-- 查看命令帮助信息
mysqldumpslow -h;
```

- 查看及设置慢查询参数

```sql
-- 查看慢查询日志是否开启
show variables like 'slow_query_log';

-- 查看慢查询日志存储位置
show variables like 'slow_query_log_file';

-- 开启慢查询日志
set global slow_query_log=on;

-- 指定慢查询日志存储位置
set global show_query_log_file='/var/lib/mysql/homestead-slow.log';

-- 记录没有使用索引的sql
set global log_queries_not_using_indexes=on;

-- 记录查询超过1s的sql
set global long_query_time=1;
```

- 编码

```sql
-- 查看编码
show variables like 'character%';
```

### 优化配置

- 设置 sleep 线程空闲的最大时间

```sql
show global variables like 'wait_timeout';
set global wait_timeout=100;
```

### 存储过程

- 创建存储过程

```sql
CREATE PROCEDURE insertData ( )
BEGIN
	DECLARE i INT DEFAULT 1;
	WHILE i < 10000 DO
		SET i = i + 1;
		INSERT INTO account ( username, age )VALUES( '测试', 12 );	
	END WHILE;
END;
```

- 执行存储过程

```sql
CALL insertData ( );
```

- 删除存储过程

```sql
DROP PROCEDURE insertData;
```

- 查看所有的存储过程

```sql
SHOW PROCEDURE status; 
```

- 查看存储过程的代码

```sql
SHOW CREATE PROCEDURE insertData;
```

### 自定义函数

```sql
-- 存在函数删除
DROP FUNCTION if EXISTS test_data;

-- 创建函数，指定参数类型和返回值
CREATE FUNCTION test_data(age int) RETURNS int(11)
BEGIN
set age=age+1;
RETURN age;
END;
-- 调用函数
SELECT test_data(2);
```
