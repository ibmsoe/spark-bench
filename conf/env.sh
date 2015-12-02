# global settings

master="hdfs-master-0"
#A list of machines where the spark cluster is running
MC_LIST="plugin-0"
sparkmaster="plugin-0"
export SPARK_HOME=/usr/lib/spark
export HADOOP_HOME=/usr/lib/hadoop
export PATH="$PATH:$HADOOP_HOME/bin"

# base dir for DataSet
HDFS_URL="hdfs://${master}:8020"
SPARK_HADOOP_FS_LOCAL_BLOCK_SIZE=536870912

# base dir in HDFS for data ingestion & output
DATA_HDFS="${HDFS_URL}/spark-bench"


#Local dataset dir where preloaded datasets resides
#usually the root of spark-bench
DATASET_DIR=~/spark-bench
DATA_COPIES=1

SPARK_VERSION=1.4.1  #1.4.0

#SPARK_MASTER=local
#SPARK_MASTER=local[K]
#SPARK_MASTER=local[*]
#SPARK_MASTER=yarn-client
SPARK_MASTER=spark://${sparkmaster}:7077

# host running generator for PageView Streaming App
PAGEVIEW_GEN=${sparkmaster}

# Spark config in environment variable or aruments of spark-submit 
# - SPARK_SERIALIZER, --conf spark.serializer
# - SPARK_RDD_COMPRESS, --conf spark.rdd.compress
# - SPARK_IO_COMPRESSION_CODEC, --conf spark.io.compression.codec
# - SPARK_DEFAULT_PARALLELISM, --conf spark.default.parallelism
# - SPARK_KRYOSERIALIZER_BUFFER_MAX, --conf spark.kryoserializer.buffer.max
SPARK_SERIALIZER=org.apache.spark.serializer.KryoSerializer
SPARK_RDD_COMPRESS=false
SPARK_IO_COMPRESSION_CODEC=lzf
SPARK_KRYOSERIALIZER_BUFFER_MAX=2047m

# Spark options in system.property or arguments of spark-submit 
# - SPARK_EXECUTOR_MEMORY, --conf spark.executor.memory
# - SPARK_STORAGE_MEMORYFRACTION, --conf spark.storage.memoryfraction
SPARK_STORAGE_MEMORYFRACTION=0.5
#export MEM_FRACTION_GLOBAL=0.005
SPARK_EXECUTOR_MEMORY=200g
SPARK_DRIVER_MEMORY=10g

# Spark options in YARN client mode
# - SPARK_DRIVER_MEMORY, --driver-memory
# - SPARK_EXECUTOR_INSTANCES, --num-executors
# - SPARK_EXECUTOR_CORES, --executor-cores
# - SPARK_DRIVER_MEMORY, --driver-memory
export EXECUTOR_GLOBAL_MEM=40G
export executor_cores=6

# Storage levels, see http://spark.apache.org/docs/latest/api/java/org/apache/spark/api/java/StorageLevels.html
# - STORAGE_LEVEL, set MEMORY_AND_DISK or MEMORY_AND_DISK_SER
STORAGE_LEVEL=MEMORY_AND_DISK

# for data generation
NUM_OF_PARTITIONS=10
# for running
NUM_TRIALS=1

COMPRESS_GLOBAL=0

