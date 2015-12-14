#!/bin/bash

echo "========== preparing ${APP} data =========="
# configure
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`
. "${DIR}/../bin/config.sh"
. "${DIR}/bin/config.sh"


${RM} -r ${INPUT_HDFS}
${MKDIR} ${APP_DIR}
${MKDIR} ${INPUT_HDFS}

srcf=${DATASET_DIR}/ECT

START_TS=`get_start_ts`;
setup
START_TIME=`timestamp`

# Use externally created data (vs synthetic) but make it bigger
# by repeated append
#
${CPFROM} $srcf/* ${INPUT_HDFS} 2> /dev/null

for((i=1; i<${DATA_COPIES}; i++)); do
    ${HADOOP_HOME}/bin/hdfs dfs -appendToFile $srcf/OS_ORDER_ITEM.txt ${INPUT_HDFS}/OS_ORDER_ITEM.txt 2> /dev/null
    ${HADOOP_HOME}/bin/hdfs dfs -appendToFile $srcf/OS_ORDER.txt ${INPUT_HDFS}/OS_ORDER.txt 2> /dev/null
done

res=$?;

END_TIME=`timestamp`

SIZE=`${DU} -s ${INPUT_HDFS} | awk '{ print $1 }'`
get_config_fields >> ${BENCH_REPORT}
print_config  ${APP}-gen ${START_TIME} ${END_TIME} ${SIZE} ${START_TS} ${res}>> ${BENCH_REPORT};
print_extended_config ${APP}-gen-with-config
teardown
exit 0


# ===unused ==compress check
if [ ${COMPRESS_GLOBAL} -eq 1 ]; then
    COMPRESS_OPT="-compress true \
        -compressCodec $COMPRESS_CODEC \
        -compressType BLOCK "
else
    COMPRESS_OPT="-compress false"
fi


