#!/bin/bash
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`
. "${DIR}/../bin/config.sh"
. "${DIR}/bin/config.sh"

# =============== path check ===============

SIZE=`$HADOOP_HOME/bin/hadoop fs -du -s ${INPUT_HDFS} | awk '{ print $1 }'`


APP=sql_rddRelation
JAR="${DIR}/target/SQLApp_2.10-1.0.jar"
CLASS="src.main.scala.RDDRelation"
OPTION="${INPUT_HDFS} ${OUTPUT_HDFS} ${numPar}  "
if  [ $# -ge 1 ] && [ $1 = "hive" ]; then	
	
	APP=sql_hive
	JAR="${DIR}/target/scala-2.10/sqlapp_2.10-1.0.jar"
	CLASS="src.main.scala.HiveFromSpark"
	OPTION="${INPUT_HDFS} ${OUTPUT_HDFS} ${numPar} "
fi



echo "========== running ${APP} benchmark =========="

start
for((i=0;i<${NUM_TRIALS};i++)); do

	$HADOOP_HOME/bin/hadoop dfs -rm -r ${OUTPUT_HDFS}
	purge_data "${MC_LIST}"	
	START_TS=`ssh ${master} "date +%F-%T"`	
	export logf=${BENCH_NUM}/${APP}_run_${START_TS}.dat
	START_TIME=`timestamp`
	exec ${SPARK_HOME}/bin/spark-submit --class $CLASS --master ${APP_MASTER} ${YARN_OPT} ${SPARK_OPT} $JAR ${OPTION} 2>&1|tee $logf
	END_TIME=`timestamp`
	gen_report "${APP}" ${START_TIME} ${END_TIME} ${SIZE} ${START_TS} >> ${BENCH_REPORT}
	print_config ${BENCH_REPORT}
done
teardown
exit 0

if [[ -z "$JAR" ]]; then
  echo "Failed to find Spark examples assembly in  ${SPARK_HOME}/examples/target" 1>&2
  echo "You need to build Spark before running this program" 1>&2
  exit 1
fi
