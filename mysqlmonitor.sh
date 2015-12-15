#/bin/sh
HOST='127.0.0.1'
USER='root'
PWD='root'
PORT='3306'

#检测mysql server是否正常提供服务
mysqladmin -h $HOST -u$USER -p$PWD  ping

#获取mysql当前的几个状态值
mysqladmin -h $HOST -u$USER -p$PWD  status

#获取数据库当前的连接信息
mysqladmin -h $HOST -u$USER -p$PWD processlist

#获取当前数据库的连接数
mysql -h $HOST -u$USER -p$PWD -BNe "select host,count(host) from processlist group by host;" information_schema

#显示mysql的uptime
mysql -h $HOST -u$USER -p$PWD -e"SHOW STATUS LIKE '%uptime%'"|awk '/ptime/{ calc = $NF / 3600;print $(NF-1), calc"Hour" }'

#查看数据库的大小
mysql -h $HOST -u$USER -p$PWD-e 'select table_schema,round(sum(data_length+index_length)/1024/1024,4) from information_schema.tables group by table_schema;'

#查看某个表的列信息
mysql -h $HOST -u$USER -p$PWD -e "SHOW COLUMNS FROM <table>" <database> | awk '{print $1}' | tr "\n" "," | sed 's/,$//g'

#执行mysql脚本
mysql -h $HOST -u$USER -p$PWD < script.sql

#mysql dump数据导出
mysqldump -h $HOST -u$USER -p$PWD -T/tmp/mysqldump test test_outfile --fields-enclosed-by=\" --fields-terminated-by=,

#mysql数据导入
mysqlimport --user=$USER --password=$PWD test --fields-enclosed-by=\" --fields-terminated-by=, /tmp/test_outfile.txt
LOAD DATA INFILE '/tmp/test_outfile.txt' INTO TABLE test_outfile FIELDS TERMINATED BY '"' ENCLOSED BY ',';

#mysql进程监控
ps -ef | grep "mysqld_safe" | grep -v "grep"
ps -ef | grep "mysqld" | grep -v "mysqld_safe"| grep -v "grep"


#查看当前数据库的状态
mysql -h $HOST -u$USER -p$PWD -e 'show status'


#mysqlcheck 工具程序可以检查(check),修 复( repair),分 析( analyze)和优化(optimize)MySQL Server 中的表
mysqlcheck -h $HOST -u$USER -p$PWD --all-databases

#mysql qps查询  QPS = Questions(or Queries) / Seconds
mysql -h $HOST -u$USER -p$PWD -e 'SHOW /*!50000 GLOBAL */ STATUS LIKE "Questions"'
mysql -h $HOST -u$USER -p$PWD -e 'SHOW /*!50000 GLOBAL */ STATUS LIKE "Queries"'

#mysql Key Buffer 命中率  key_buffer_read_hits = (1 - Key_reads / Key_read_requests) * 100%  key_buffer_write_hits= (1 - Key_writes / Key_write_requests) * 100%
mysql -h $HOST -u$USER -p$PWD -e 'SHOW /*!50000 GLOBAL */ STATUS LIKE "Key%"'

#mysql Innodb Buffer 命中率  innodb_buffer_read_hits=(1-Innodb_buffer_pool_reads/Innodb_buffer_pool_read_requests) * 100%
mysql -h $HOST -u$USER -p$PWD -e 'SHOW /*!50000 GLOBAL */ STATUS LIKE "Innodb_buffer_pool_read%"'

#mysql Query Cache 命中率 Query_cache_hits= (Qcache_hits / (Qcache_hits + Qcache_inserts)) * 100%
mysql -h $HOST -u$USER -p$PWD 'SHOW /*!50000 GLOBAL */ STATUS LIKE "Qcache%"'

#mysql Table Cache 状态量
mysql -h $HOST -u$USER -p$PWD -e 'SHOW /*!50000 GLOBAL */ STATUS LIKE "Open%"'

#mysql Thread Cache 命中率  Thread_cache_hits = (1 - Threads_created / Connections) * 100%  正常来说,Thread Cache 命中率要在 90% 以上才算比较合理。
mysql -h $HOST -u$USER -p$PWD -e 'SHOW /*!50000 GLOBAL */ STATUS LIKE "Thread%"'

#mysql 锁定状态:锁定状态包括表锁和行锁两种,我们可以通过系统状态变量获得锁定总次数,锁定造成其他线程等待的次数,以及锁定等待时间信息
mysql -h $HOST -u$USER -p$PWD -e 'SHOW /*!50000 GLOBAL */ STATUS LIKE "%lock%"'

#mysql 复制延时量 在slave节点执行
mysql -h $HOST -u$USER -p$PWD -e 'SHOW SLAVE STATUS'

#mysql Tmp table 状况 Tmp Table 的状况主要是用于监控 MySQL 使用临时表的量是否过多,是否有临时表过大而不得不从内存中换出到磁盘文件上
mysql -h $HOST -u$USER -p$PWD -e 'SHOW /*!50000 GLOBAL */ STATUS LIKE "Created_tmp%"'

#mysql Binlog Cache 使用状况:Binlog Cache 用于存放还未写入磁盘的 Binlog 信 息 。
mysql -h $HOST -u$USER -p$PWD -e 'SHOW /*!50000 GLOBAL */ STATUS LIKE "Binlog_cache%"'

#mysql nnodb_log_waits 量:Innodb_log_waits 状态变量直接反应出 Innodb Log Buffer 空间不足造成等待的次数
mysql -h $HOST -u$USER -p$PWD -e 'SHOW /*!50000 GLOBAL */ STATUS LIKE "Innodb_log_waits'

