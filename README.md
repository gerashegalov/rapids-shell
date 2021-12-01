# rapids-shell

A utility to start RAPIDS-enabled Spark Shell with access to unit tests resources from https://github.com/NVIDIA/spark-rapids
Before running the examples make sure to at least execute `mvn package` in your local spark-rapids repo if you are not using binaries.

## Comand line options
See `rapids.sh --help` for up to date information
```
Usage: rapids.sh [OPTION]
Options:
  --debug
    enable bash tracing
  -h, --help
    prints this message
  -m=MASTER, --master=MASTER
    specify MASTER for spark command, default is local[-cluster], see --num-local-execs
  -n, --dry-run
    generates and prints the spark submit command without executing
  -nle=N, --num-local-execs=N
    specify the number of local executors to use, default is 2. If > 1 use pseudo-distributed
    local-cluster, otherwise local[*]
  -uecp, --use-extra-classpath
    use extraClassPath instead of --jars to add RAPIDS jars to spark-submit (default)
  -uj, --use-jars
    use --jars instead of extraClassPath to add RAPIDS jars to spark-submit
  --ucx-shim=spark<3xy>
    Spark buildver to populate shim-dependent package name of RapidsShuffleManager.
    Will be replaced by a Boolean option
  -cmd=CMD, --spark-command=CMD
    specify one of spark-submit (default), spark-shell, pyspark, jupyter, jupyter-lab
  -dopts=EOPTS, --driver-opts=EOPTS
    pass EOPTS as --driver-java-options
  -eopts=EOPTS, --executor-opts=EOPTS
    pass EOPTS as spark.executor.extraJavaOptions
  --gpu-fraction=GPU_FRACTION
    GPU share per executor JVM unless local or local-cluster mode, see spark.rapids.memory.gpu.allocFraction
```

## Environment variables

- `SPARK_RAPIDS_HOME` - the path either to the local repo or to the location used for downloading the [binaries](https://nvidia.github.io/spark-rapids/docs/download.html)

- `SPARK_HOME` - the path either to the local Spark repo or to the root fo binary distro

- `SPARK_CMD` - one of `spark-shell` (default), `spark-submit`, `pyspark`, `jupyter`, `jupyter-lab`

## Examples

Use Spark RAPIDS in Jupyter notebook
```bash
SPARK_HOME=~/spark-3.1.1-bin-hadoop3.2 SPARK_CMD=jupyter[-lab] rapids.sh
```

Run in pseudo-distirbuted `local-cluster` mode
```bash
NUM_LOCAL_EXECS=2 SPARK_HOME=~/spark-3.1.1-bin-hadoop3.2 rapids.sh
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

## Using integration test datagens

In pyspark based drivers one can use data generators from spark-rapids/integration-tests or run whole pytests.

Add `rapids.py` as an ipython startup file, e.g. on *NIX

```bash
cp src/python/rapids.py ~/.ipython/profile_default/startup/
```

### Datagen

```python
key_data_gen = StructGen([
        ('a', IntegerGen(min_val=0, max_val=4)),
        ('b', IntegerGen(min_val=5, max_val=9)),
    ], nullable=False)
val_data_gen = IntegerGen()
df = two_col_df(spark, key_data_gen, val_data_gen)

...
```

### Pytest

```python
runpytest('test_struct_count_distinct')
```
