rem set HADOOP_HOME=
rem set SPARK_LOCAL_DIRS=

%SPARK_HOME%\bin\spark-submit.cmd --driver-memory 7G --master local[*] -v --class roffild.MLPDataFileSparkTest build\libs\MLPDataFileSparkTest-all.jar %*
