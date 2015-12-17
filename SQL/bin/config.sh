#!/bin/bash

this="${BASH_SOURCE-$0}"
bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
if [ -f "${bin}/../conf/env.sh" ]; then
  set -a
  . "${bin}/../conf/env.sh"
  set +a
fi

APP=sql
APP_DIR=${DATA_HDFS}/${APP}
INPUT_HDFS=${DATA_HDFS}/${APP}/Input
OUTPUT_HDFS=${DATA_HDFS}/${APP}/Output

if [ ${COMPRESS_GLOBAL} -eq 1 ]; then
    INPUT_HDFS=${INPUT_HDFS}-comp
    OUTPUT_HDFS=${OUTPUT_HDFS}-comp
fi

# either stand alone or yarn cluster
APP_MASTER=${SPARK_MASTER}

set_gendata_opt
set_run_opt

function print_config(){
get_config_values $1 $2 $3 $4 $5 $6
}

function get_config_fields(){
local report_field=$(get_report_field_name)
echo -n "#${report_field},AppType,numV,numPar,mu,sigma,iter,tol,reset_prob"
echo -en "\n"

}
function get_config_values(){
gen_report $1 $2 $3 $4 $5 $6
echo -n ",${APP}-MLlibConfig,${numV},${NUM_OF_PARTITIONS},${mu},${sigma},${MAX_ITERATION},${TOLERANCE},${RESET_PROB}"
echo -en "\n"
return 0
}

#output results + extended config details
function print_extended_config(){
	local output=$1

	CONFIG=
	if [ ! -z "$SPARK_STORAGE_MEMORYFRACTION" ]; then
	  CONFIG="${CONFIG} memoryFraction ${SPARK_STORAGE_MEMORYFRACTION}"
	fi
	if [ "$MASTER" = "yarn" ]; then
	  if [ ! -z "$SPARK_EXECUTOR_CORES" ]; then
	    CONFIG="${CONFIG} exe_core ${SPARK_EXECUTOR_CORES}"
	  fi
	fi
	if [ ! -z "$SPARK_SERIALIZER" ]; then
	  CONFIG="${CONFIG} ${SPARK_SERIALIZER}"
	fi
	if [ ! -z "$SPARK_RDD_COMPRESS" ]; then
	  CONFIG="${CONFIG} RDDcomp ${SPARK_RDD_COMPRESS}"
	fi
	if [ ! -z "$SPARK_IO_COMPRESSION_CODEC" ]; then
	  CONFIG="${CONFIG} ${SPARK_IO_COMPRESSION_CODEC}"
	fi

	echo "${APP}_config \
	numV ${numV} numPar ${NUM_OF_PARTITIONS} mu ${mu} sigma ${sigma} \
	iter ${MAX_ITERATION} tol ${TOLERANCE} reset_prob ${RESET_PROB} \
	${CONFIG} " >> ${output}
}
