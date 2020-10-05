## Mysql 架构

![](http://oss.mflyyou.cn/blog/20200920151707.png?author=zhangpanqin)



![](http://oss.mflyyou.cn/blog/20200920184243.png?author=zhangpanqin)

```mysql
-- 查看 innodb_buffer_pool_size 大小或者 innodb_buffer 相关的参数
SHOW VARIABLES LIKE 'INNODB_buffer%'
```

### 字符串

Mysql 官方手册中定义的 65535 字节是指每行数据所有 varchar 列所占用字节的总长度。

varchar（n）是指字符数。 

```sql
-- 插入 text 数据
INSERT INTO test_data_type ( test_text )
VALUES
	((
		SELECT
	REPEAT
	( 'a', 9000 )));
```



















### SHOW PROFILES

### Performance Schema

### EXPLAIN

## SQL优化

### SHOW PROFILE

`SHOW PROFILE` 可以查看当前会话执行语句的资源使用情况。

```mysql
SHOW PROFILE [type [, type] ... ]
    [FOR QUERY n]
    [LIMIT row_count [OFFSET offset]]

type: {
    ALL
  | BLOCK IO
  | CONTEXT SWITCHES
  | CPU
  | IPC
  | MEMORY
  | PAGE FAULTS
  | SOURCE
  | SWAPS
}
```

```mysql
# 查看当前会话是否开启了 profile, 0 或者 off 标识关闭
SHOW VARIABLES LIKE "profiling"

# 开启当前会话 profile
SET profiling = 1;

# 查看最近执行了哪些 sql
SHOW PROFILES; 

# 查看具体的 sql 执行情况
SHOW PROFILE FOR QUERY 2;
show profile CPU ,BLOCK IO for query 2;
```



## 操作表 SQL

### 查看表结构

```sql
desc mysql_study.test_data_type \G;
```

### 获取表结构 sql

```sql
-- SHOW CREATE TABLE tbl_name \G;
SHOW CREATE TABLE mysql_study.test_data_type \G
```

### 增加列

```sql
ALTER TABLE 表名 ADD COLUMN 列名 数据类型 [列的属性];
-- 将列添加到指定列之后
ALTER TABLE 表名 ADD COLUMN 列名 列的类型 [列的属性] AFTER 指定列名;

```

### 删除列

```sql
-- 删除列
ALTER TABLE 表名 DROP COLUMN 列名;
```

### 修改列

```sql
ALTER TABLE 表名 MODIFY 列名 新数据类型 [新属性];
ALTER TABLE 表名 CHANGE 旧列名 新列名 新数据类型 [新属性];
```



## 操作索引

UNIQUE：可选参数，表明索引为唯一性索引。

FULLTEXT：可选参数，表明索引为全文搜索。

SPATIAL：可选参数，表明索引为空间索引。

不选择参数就是普通索引。

### 添加索引

```sql
ALTER TABLE 表名 ADD [UNIQUE|FULLTEXT|SPATIAL] INDEX 索引名 (需要被索引的单个列或多个列);

-- 添加正常索引
ALTER TABLE `test2`.`my_test` ADD INDEX `index_a_b`(`name`(20), `age`(5)) USING BTREE;
-- 添加唯一索引
ALTER TABLE `test2`.`my_test` ADD UNIQUE INDEX `index_a_b`(`name`(20), `age`(5)) USING BTREE;
```

### 删除索引

```sql
ALTER TABLE 表名 DROP INDEX 索引名;

ALTER TABLE my_test DROP INDEX index_a_b;
```



### 修改索引

```sql
ALTER TABLE `test2`.`my_test` 
DROP INDEX `index_a`,
ADD INDEX `index_a`(`name`(20), `age`(20)) USING BTREE;
```



### Buffer Poll

Mysql 以 `页` 的形式将 Mysql 数据存入到表空间中，通常页大小为 16KB。页分为索引页，数据页等等。

Mysql 需要将这些页数据加载到内存中去，修改索引，修改数据等等之后，Mysql 再将脏页落盘到磁盘上。

Bufffer Poll 就是 InnoDB 向操作系统申请一段连续的内存空间，用于保存页数据。`innodb_buffer_pool_size` 可以调整大小，默认 128M。



Buffer Poll 中，有一部分数据经常被访问到，也就是热数据（young 区域）；还有一部分访问频率少的叫做冷数据（old 区域）。



```sql
 -- 查看 old 区域所占比列
 SHOW VARIABLES LIKE 'innodb_old_blocks_pct';
```





Mysql 推荐`innodb_buffer_pool_size` 大于 1G，将 Buffer Poll 拆成多个实例，减少对内存访问带来的锁冲突。

`innodb_buffer_pool_instances` 控制实例个数。

每个 Buffer Poll 的大小，都需要申请，每次申请的数值可以由，`innodb_buffer_pool_chunk_size`

控制，innodb_buffer_pool_chunk_size 默认 128M。

`innodb_buffer_pool_size` 必须是`innodb_buffer_pool_chunk_size × innodb_buffer_pool_instances`的倍数。

