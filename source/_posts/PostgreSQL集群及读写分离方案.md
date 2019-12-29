---
title: PostgreSQL集群及读写分离实践
date: 2019-12-29 17:26:58
categories: 数据库
tags: 
	- PostgreSql
---

为了方便，只搭建一主一从。首先准备两台服务器，信息如下：

| IP           | 角色      | 端口 |
| ------------ | --------- | ---- |
| 192.168.0.31 | master    | 5432 |
|              | pgpool-II | 9999 |
| 192.168.0.32 | slave     | 5432 |

## 一、基础环境配置

1. host设置

   ```
   # 修改vi /etc/hosts, 增加以下内容
   192.168.0.31 master
   192.168.0.32 slave
   ```

2. 安装

   PostgreSQL

   ```
   # 添加源
   rpm -Uvh https://yum.postgresql.org/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
   # 下载
   yum install postgresql10-server postgresql10
   # 安装
   /usr/pgsql-10/bin/postgresql-10-setup initdb
   
   # 启动
   systemctl enable postgresql-10.service
   systemctl start postgresql-10.service
   
   # 验证
   su - postgres -c "psql"
   # 出现以下信息则成功
   psql (10.0)
   Type "help" for help.
   postgres=#
   
   # 创建密码
   postgres=# \password postgres
   
   # 查看路径（/var/lib/pgsql/10/data）
   postgres=# show data_directory;
   
   # 编辑文件 (vi /var/lib/pgsql/10/data/pg_hba.conf)
   # host all all 127.0.0.1/32 ident 修改为允许所有网络登录，并使用md5方式进行认证：
   # host all all 0.0.0.0/0 md5
   
   # 编辑文件 (vi /var/lib/pgsql/10/data/postgresql.conf)
   listen_addresses = '*' # 表示开放外网访问
   
   # 打开防火墙
   sudo firewall-cmd --add-service=postgresql --permanent
   sudo firewall-cmd --reload
   # 重启
   systemctl restart postgresql-10.service
   ```

   pgpool-II

   ```
   # 安装
   yum install http://www.pgpool.net/yum/rpms/3.7/redhat/rhel-7-x86_64/pgpool-II-release-3.7-1.noarch.rpm
   yum install pgpool-II-pg10
   # 可选
   yum install pgpool-II-pg10-debuginfo
   yum install pgpool-II-pg10-devel
   yum install pgpool-II-pg10-extensions
   
   #启动
   systemctl enable pgpool.service
   systemctl start pgpool.service
   ```

## 二、流复制

1. Master

   ```
   # 创建用于复制的用户
   su - postgres
   psql
   postgres=# CREATE ROLE pgrepuser REPLICATION LOGIN PASSWORD 'pgreppass';
   # 编辑文件 (vi /var/lib/pgsql/10/data/pg_hba.conf)
   # host replication pgrepuser 0.0.0.0/0 md5
   
   # 编辑文件 (vi /var/lib/pgsql/10/data/postgresql.conf),修改配置(根据实际情况填写)
   wal_level = hot_standby
   archive_mode = on
   max_wal_sender = 4
   wal_keep_segments = 10
   
   # 重启数据库
   systemctl restart postgresql-10.service
   ```

2. Slave

   ```
   # 停止服务
   systemctl stop postgresql-10.service
   
   su - postgres
   # 使用 pg_basebackup 生成备库
   #1. 清空 $PGDATA 目录
   rm -rf /var/lib/pgsql/10/data
   
   # pg_basebackup 命令生成备库
   pg_basebackup -D /var/lib/pgsql/10/data -Fp -Xs -v -P -h master -U pgrepuser
   
   # 编辑文件 (vi /var/lib/pgsql/10/data/postgresql.conf)
   hot_standby = on
   
   # 新建文件 (vi /var/lib/pgsql/10/data/recovery.conf)
   standby_mode = 'on'
   primary_conninfo = 'host=master port=5432 user=pgrepuser password=pgreppass'
   trigger_file = 'failover.now'
   recovery_target_timeline = 'latest'
   
   # 重启数据库
   systemctl restart postgresql-10.service
   
   #验证：在master新增数据slave节点可以看到数据。
   ```

## 三、读写分离

1. pgpool配置

   ```
   cd /etc/pgpool-II
   cp -pv pgpool.conf.sample-stream pgpool.conf
   
   # 修改 vi pgpool.conf
   listen_addresses = '*'# 外网访问
   # 0为主库
   backend_hostname0 = 'master
   backend_port0 = 5432
   backend_weight0 = 0 # 分配比例
   backend_data_directory0 = '/var/lib/pgsql/10/data'
   backend_flag0 = 'ALLOW_TO_FAILOVER'
   backend_hostname1 = 'slave'
   backend_port1 = 5432
   backend_weight1 = 1
   backend_data_directory1 = '/var/lib/pgsql/10/data'
   backend_flag1 = 'ALLOW_TO_FAILOVER'
   #hba认证
   enable_pool_hba = on
   # 执行log
   log_statement = on
   log_per_node_statement = on
   # 流复制
   sr_check_user = 'replicator' # 流复制账号
   sr_check_password = '123456'  # 流复制密码
   # 函数默认分发到从节点，过滤如下
   black_function_list = 'currval,lastval,nextval,setval,funcw_.*'
   
   # 修改 vi pool_hba.conf
   host    all         all         0.0.0.0/0          md5
   
   # 修改 vi pcp.conf
   pcp:e10adc3949ba59abbe56e057f20f883e # 密码为123456
   
   # 生成pool_passwd
   pg_md5  123456
   
   # 与 postgresql 用户密码一致
   pg_md5 -m -u postges postgres
   
   # 启动pgpool
   # systemctl restart pgpool.service 
   pgpool -n -d > /etc/pgpool-II/pgpool.log 2>&1 &
   
   # 连接
   su - postgres
   psql postgres -h master -p 9999 -U postgres
   
   # 节点信息
   postgres=# show pool_nodes;
   node_id | hostname | port | status | lb_weight |  role   | select_cnt | load_balance_node | replication_delay 
   ---------+----------+------+--------+-----------+---------+------------+-------------------+-------------------
   0       | master   | 5432 | up     | 0.000000  | primary | 28         | false             | 0
   1       | slave    | 5432 | up     | 1.000000  | standby | 6          | true              | 0
   
   # 查看日志
   tail -f /etc/pgpool-II/pgpool.log 
   
   # 下面是测试情况：
   # select 1;
   2017-10-30 06:38:25: pid 3637: LOG:  DB node id: 1 backend pid: 3658 statement: select * from test where id = 1;
   
   # update test set name = 'test' where id = 2;
   DB node id: 0 backend pid: 8032 statement: update test set name = 'test' where id = 2;
   #/*REPLICATION*/select 1; # 强制master节点执行
   DB node id: 0 backend pid: 8032 statement: 	/*REPLICATION*/select 1;
   # DB node id,0表示主节点执行，1表示从节点
   ```



## 四、错误解决

1. 端口占用

   ```
   2017-10-30 01:50:21: pid 3790: FATAL:  failed to bind a socket: "/tmp/.s.PGSQL.9998"
   2017-10-30 01:50:21: pid 3790: DETAIL:  bind socket failed with error: "Address already in use"
   
   # 非正常结束导致的，删除以下目录即可
   rm -f /tmp/.s.PGSQL.9999
   rm -f /tmp/.s.PGSQL.9898
   ```

   

## 五、后续优化

1. 宕机主从切换

   ```
   # 修改 vi pgpool.conf
   follow_master_command = '/etc/pgpool-II/failover_stream.sh'
   ```

   新建切换脚本

   ```
   #! /bin/sh 
   # Failover command for streaming replication. 
   # Arguments: $1: new master hostname. 
   
   new_master=$1 
   trigger_command="$PGHOME/bin/pg_ctl promote -D $PGDATA" 
   
   # Prompte standby database. 
   /usr/bin/ssh -T $new_master $trigger_command 
   
   exit 0;
   ```

2. pgpool集群

   配置虚拟ip(delegate_IP)，使用WATCHDOG监控，服务A宕机时，服务B自动接管虚拟IP对外提供服务。

   

## 六、基于ShardingJDBC实现读写分离

1.  新建一个Spring Boot工程，添加必要的依赖，其pom.xml定义如下：

   ```java
   <?xml version="1.0" encoding="UTF-8"?>
   <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
       <modelVersion>4.0.0</modelVersion>
   
       <groupId>com.demo</groupId>
       <artifactId>shardingjdbcdemo</artifactId>
       <version>0.0.1-SNAPSHOT</version>
       <packaging>jar</packaging>
   
       <name>shardingjdbcdemo</name>
       <description>Demo project for ShardingJDBC Demo</description>
   
       <parent>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-parent</artifactId>
           <version>1.5.7.RELEASE</version>
           <relativePath/> <!-- lookup parent from repository -->
       </parent>
   
       <properties>
           <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
           <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
           <java.version>1.8</java.version>
           <sharding-jdbc.version>1.5.4.1</sharding-jdbc.version>
           <mybatis-spring-boot-starter.version>1.1.1</mybatis-spring-boot-starter.version>
       </properties>
   
       <dependencies>
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-web</artifactId>
           </dependency>
           <!--支持面向方面的编程即AOP，包括spring-aop和AspectJ-->
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-aop</artifactId>
           </dependency>
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-jdbc</artifactId>
           </dependency>
           <dependency>
               <groupId>org.mybatis.spring.boot</groupId>
               <artifactId>mybatis-spring-boot-starter</artifactId>
               <version>${mybatis-spring-boot-starter.version}</version>
           </dependency>
   
           <dependency>
               <groupId>org.postgresql</groupId>
               <artifactId>postgresql</artifactId>
               <scope>runtime</scope>
           </dependency>
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-test</artifactId>
               <scope>test</scope>
           </dependency>
   
           <!-- 引入sharding-jdbc核心模块 -->
           <dependency>
               <groupId>com.dangdang</groupId>
               <artifactId>sharding-jdbc-core</artifactId>
               <version>${sharding-jdbc.version}</version>
           </dependency>
           <dependency>
               <groupId>commons-dbcp</groupId>
               <artifactId>commons-dbcp</artifactId>
               <version>1.4</version>
           </dependency>
       </dependencies>
   
       <build>
           <plugins>
               <plugin>
                   <groupId>org.springframework.boot</groupId>
                   <artifactId>spring-boot-maven-plugin</artifactId>
               </plugin>
           </plugins>
       </build>
   
   </project>
   ```

2. 定义DataSource

   ```java
   package com.demo.shardingjdbc.config;
   
   import com.dangdang.ddframe.rdb.sharding.api.MasterSlaveDataSourceFactory;
   import com.dangdang.ddframe.rdb.sharding.api.strategy.slave.MasterSlaveLoadBalanceStrategyType;
   import org.apache.commons.dbcp.BasicDataSource;
   import org.springframework.boot.context.properties.ConfigurationProperties;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   
   import javax.sql.DataSource;
   import java.sql.Driver;
   import java.sql.SQLException;
   import java.util.HashMap;
   import java.util.Map;
   
   @Configuration
   public class DataSourceConfig {
       @Bean(name = "shardingDataSource")
       @ConfigurationProperties(prefix="spring.datasource")
       public DataSource getDataSource() throws SQLException {
           return buildDataSource();
       }
   
       private DataSource buildDataSource() throws SQLException {
           BasicDataSource masterDataSource0 = createDataSource("jdbc:postgresql://192.168.0.31:5432/master");
           // 构建读写分离数据源, 读写分离数据源实现了DataSource接口, 可直接当做数据源处理. masterDataSource0, slaveDataSource00, slaveDataSource01等为使用DBCP等连接池配置的真实数据源
           Map<String, DataSource> slaveDataSourceMap0 = new HashMap<>();
           BasicDataSource slaveDataSource00 = createDataSource("jdbc:postgresql://192.168.0.31:5432/slave");
           slaveDataSourceMap0.put("slaveDataSource00", slaveDataSource00);
           // 可选择主从库负载均衡策略, 默认是ROUND_ROBIN, 还有RANDOM可以选择, 或者自定义负载策略
           DataSource masterSlaveDs0 = MasterSlaveDataSourceFactory.createDataSource("ms_0", "masterDataSource0", masterDataSource0, slaveDataSourceMap0, MasterSlaveLoadBalanceStrategyType.ROUND_ROBIN);
   
           return masterSlaveDs0;
       }
   
       private static BasicDataSource createDataSource(final String dataSourceUrl) {
           BasicDataSource result = new BasicDataSource();
           result.setDriverClassName(Driver.class.getName());
           result.setUrl(dataSourceUrl);
           result.setUsername("postgres");
           result.setPassword("");
           return result;
       }
   }
   ```