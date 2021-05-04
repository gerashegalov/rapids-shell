# rapids-shell

A utility to start RAPIDS-enabled Spark Shell with access to unit tests resources from https://github.com/NVIDIA/spark-rapids
Before running the examples make sure to at least execute `mvn package` in your local spark-rapids repo if you are not using binaries.

## Environment variables 

- `SPARK_RAPIDS_HOME` - the path either to the local repo or to the location used for downloading the [binaries](https://nvidia.github.io/spark-rapids/docs/download.html)

- `SPARK_HOME` - the path either to the local Spark repo or to the root fo binary distro

- `SPARK_SHELL` - one of `spark-shell` (default), `pyspark`, `jupyter`, `jupyter-lab`

## Examples

Use Spark RAPIDS in Jupyter notebook
```bash
SPARK_HOME=~/spark-3.1.1-bin-hadoop3.2 SPARK_SHELL=jupyter[-lab] rapids.sh
```

Other supported values for `SPARK_SHELL` are `spark-shell` (Scala REPL, default) and `pyspark` (Python REPL)


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

