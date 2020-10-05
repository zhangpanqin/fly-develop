## 数据库操作

### 查看当前数据库版本

```mysql
select version();
```

### 查看有哪些数据库

```mysql
SHOW DATABASES;
```

### 创建数据库

数据库名和表名在 `linux` 和 `windows`大小写敏感会存在问题，尽管可以通过配置统一。但是推荐：

<font color=red>数据库和表名使用全小写，单词之间下划线隔开。</font>

```mysql
CREATE DATABASE 数据库名称;
```

### 使用数据库

```mysql
use 数据库名称;
```

### 查看当前所用数据库

```mysql
SELECT DATABASE();
```

## 表操作

### 查看数据库中的表

```mysql
SHOW TABLES;
```

### 创建表

### 查看表结构

```mysql
DESC ceshi_index;
```

## 查询语句

### 用户变量

```mysql
SELECT @min_price:=MIN(price),@max_price:=MAX(price) FROM shop;
```

## 数据库优化

### 调整数据库最大保存数据大小

```mysq
[mysql]
max_allowed_packet=16M
```

## 权限控制

```txt
'Select', 'Insert', 'Update', 'Delete', 'Create', 'Drop', 'Grant', 'References', 'Index', 'Alter'
```

| 权限         | 列              | 上下文                 | 说明                                                         |
| ------------ | --------------- | ---------------------- | ------------------------------------------------------------ |
| CREATE       | Create_priv     | 数据库、表或索引       |                                                              |
| DROP         | Drop_priv       | 数据库或表             |                                                              |
| GRANT OPTION | Grant_priv      | 数据库、表或保存的程序 | GRANT权限允许你把你自己拥有的那些权限授给其他的用户。可以用于数据库、表和保存的程序。 |
| REFERENCES   | References_priv | 数据库或表             |                                                              |
| ALTER        | Alter_priv      | 表                     | 通过ALTER权限，你可以使用ALTER TABLE来更改表的结构和重新命名表。 |
| DELETE       | Delete_priv     | 表                     |                                                              |
| INDEX        | Index_priv      | 表                     | INDEX权限允许你创建或删除索引。INDEX适用已有表。             |
| INSERT       | Insert_priv     | 表                     |                                                              |
| SELECT       | Select_priv     | 表                     |                                                              |
| UPDATE       | Update_priv     | 表                     |                                                              |
| PROCESS      | Process_priv    | 服务器管理             | processlist命令显示在服务器内执行的线程的信息（即其它账户相关的客户端执行的语句）。 |

## 安全

### 使用 ssl 链接

```mysql
#  检查 mysqld 服务器支持OpenSSL，值为 yes 支持
SHOW VARIABLES LIKE 'have_openssl';
```