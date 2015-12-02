#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`
. "${DIR}/../bin/config.sh"
. "${DIR}/bin/config.sh"

echo "========== preparing ${APP} data =========="

JAR="${DIR}/target/SVMApp-1.0.jar"
CLASS="SVM.src.main.scala.SVMDataGen"
OPTION=" ${APP_MASTER} ${INOUT_SCHEME}${INPUT_HDFS} ${NUM_OF_EXAMPLES} ${NUM_OF_FEATURES}  ${NUM_OF_PARTITIONS} "
${RM} -r ${INPUT_HDFS}
#genOpt="large"
# paths check
setup
START_TS=`get_start_ts`;

if [ "$genOpt" = "large" ]; then
	tmp_dir=${APP_DIR}/tmp	
	${RM} -r $tmp_dir
	${MKDIR} ${APP_DIR}
	${MKDIR} $tmp_dir
	#srcf=${DATASET_DIR}/tmp-10k
	srcf=${DATASET_DIR}/SVMdata.txt
	${CPFROM} $srcf $tmp_dir
	for((i=1; i<${DATA_COPIES}; i++)); do
	    ${HADOOP_HOME}/bin/hdfs dfs -appendToFile $srcf ${INPUT_HDFS}/Auto.data 2> /dev/null
	done

	JAR="${DIR}/target/scala-2.10/svmapp_2.10-1.0.jar"
	CLASS="src.main.scala.DocToTFIDF"
	OPTION="${tmp_dir} ${INPUT_HDFS} ${NUM_OF_PARTITIONS} "
fi
START_TIME=`timestamp`
echo "${SPARK_HOME}/bin/spark-submit --class $CLASS --master ${APP_MASTER} ${YARN_OPT} ${SPARK_OPT}  $JAR ${OPTION} 2>&1|tee ${BENCH_NUM}/SVM_gendata_${START_TS}.dat"
exec ${SPARK_HOME}/bin/spark-submit --class $CLASS --master ${APP_MASTER} ${YARN_OPT} ${SPARK_OPT}  $JAR ${OPTION} 2>&1|tee ${BENCH_NUM}/SVM_gendata_${START_TS}.dat
res=$?;
END_TIME=`timestamp`
SIZE=`${DU} -s ${INPUT_HDFS} | awk '{ print $1 }'`
get_config_fields >> ${BENCH_REPORT}
print_config  ${APP}-gen ${START_TIME} ${END_TIME} ${SIZE} ${START_TS} ${res}>> ${BENCH_REPORT};
teardown
exit 0



