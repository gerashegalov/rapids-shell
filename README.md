# rapids-shell

A utility to start RAPIDS-enabled Spark Shell with access to unit tests resources from https://github.com/NVIDIA/spark-rapids
Before running the examples make sure to at least execute `mvn package` in your local spark-rapids repo if you are not using binaries.

## Examples 

Invoke `spark-shell`
```bash
SPARK_HOME=~/spark-3.1.1-bin-hadoop3.2 rapids.sh
```

Invoke `pyspark`
```bash
SPARK_HOME=~/gits/spark rapids.sh
```

Invoke `pyspark`
```bash
SPARK_HOME=~/gits/spark SPARK_SHELL=pyspark rapids.sh
```

Run in pseudo-distirbuted `local-cluster` mode
```bash
SPARK_HOME=~/spark-3.1.1-bin-hadoop3.2 rapids.sh --master local-cluster[1,10,10000]
```

Allow attaching a java debugger to the driver JVM 
```bash
JDBSTR=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 SPARK_HOME=~/spark-3.1.1-bin-hadoop3.2 rapids.sh
``` 

## Running Spark RAPIDS ScalaTests in `spark-shell` once started 

Single test suite
```scala
scala> run(new com.nvidia.spark.rapids.InsertPartition311Suite)
InsertPartition311Suite:
...
```

Single test case
```scala
scala> run(new com.nvidia.spark.rapids.HashAggregatesSuite, "sum(floats) group by more_floats 2 partitions")
HashAggregatesSuite:
...
```

