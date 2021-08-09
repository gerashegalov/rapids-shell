#!/bin/bash
set -x

SCALATEST_VERSION=3.0.5

# https://stackoverflow.com/a/246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# parse command line arguments
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-n|--dry-run)
			DRY_RUN=true
			shift
			;;

		-h|--help)
			#TODO
			shift
			;;


		*) #NOPE
			break
			;;
	esac
done

SPARK_HOME=${SPARK_HOME:-$HOME/gits/apache/spark}

# pre-requisite: `mvn package` has been run
SPARK_RAPIDS_HOME=${SPARK_RAPIDS_HOME:-$HOME/gits/NVIDIA/spark-rapids}

RAPIDS_SHELL_HOME=${RAPIDS_SHELL_HOME:-"$(dirname $(dirname $DIR))"}

SCALATEST_JARS=$(find ~/.m2 \
	-path \*/$SCALATEST_VERSION/\* -name \*scalatest\*jar -o \
	-path \*/$SCALATEST_VERSION/\* -name \*scalactic\*jar | tr -s "\n" ":")

RAPIDS_PLUGIN_JAR=$(find $SPARK_RAPIDS_HOME -regex ".*/rapids-4-spark_2.12-[0-9]+\.[0-9]+\.[0-9]+\(-SNAPSHOT\)?$SHIMVER.jar")

CUDF_JAR=$(find $SPARK_RAPIDS_HOME -name cudf\*jar)
if [ "$CUDF_JAR" == "" ]; then
	if [[ "$RAPIDS_PLUGIN_JAR" =~ .*/rapids-4-spark_2.12-([0-9]+.[0-9]+.[0-9]+(-SNAPSHOT)?).jar ]]; then
		RAPIDS_VERSION="${BASH_REMATCH[1]}"
	else
		echo "error: rapids version not detetected!"
		exit 1
	fi
	CUDF_JAR=$HOME/.m2/repository/ai/rapids/cudf/$RAPIDS_VERSION/cudf-$RAPIDS_VERSION-cuda11.jar
fi

RAPIDS_CLASSPATH="${RAPIDS_PLUGIN_JAR}:${CUDF_JAR}:${SPARK_RAPIDS_HOME}/tests/target/test-classes:${SCALATEST_JARS}"
RAPIDS_JARS="file://${RAPIDS_PLUGIN_JAR},file://${CUDF_JAR}"
FINAL_JAVA_OPTS=(
	"-ea"
	"-Duser.timezone=UTC"
	"-Dlog4j.debug=true"
	"-Dlog4j.configuration=file:${RAPIDS_SHELL_HOME}/src/conf/log4j.properties"
)

SPARK_SHELL=${SPARK_SHELL:-spark-shell}

export IT_ROOT=${IT_ROOT:-"$SPARK_RAPIDS_HOME/integration_tests"}

# for all pyspark drivers
export PYTHONPATH="$PYTHONPATH:$IT_ROOT/src/main/python"

export LD_LIBRARY_PATH="$CONDA_PREFIX/lib"

case "$SPARK_SHELL" in

	"spark-shell")
		# 	SPARK_SHELL_RC="-I $RAPIDS_SHELL_HOME/src/scala/rapids.scala"
		;;

	"pyspark")
		;;

	"jupyter")
		export PYSPARK_DRIVER_PYTHON="$SPARK_SHELL"
		export PYSPARK_DRIVER_PYTHON_OPTS="notebook"
		SPARK_SHELL="pyspark"
		;;

	"jupyter-lab")
		export PYSPARK_DRIVER_PYTHON="$SPARK_SHELL"
		SPARK_SHELL="pyspark"
		;;

	*)
		echo -n "Unknown spark-rapids driver!"
		;;
esac

NUM_LOCAL_EXECS=${NUM_LOCAL_EXECS:-0}
if ((NUM_LOCAL_EXECS > 0)); then
	LOCAL_MASTER="local-cluster[$NUM_LOCAL_EXECS,2,4096]"
	GPU_FRACTION=$(<<< "scale=2; 0.96 / $NUM_LOCAL_EXECS" bc)
else
	LOCAL_MASTER="local[*]"
	GPU_FRACTION=0.96
fi

COMMAND_ARR=(
	${SPARK_HOME}/bin/${SPARK_SHELL}
	${SPARK_SHELL_RC}
	--master \"$LOCAL_MASTER\"
	--driver-memory 4g
	--driver-java-options \"${FINAL_JAVA_OPTS[*]} ${RAPIDS_DRIVER_OPTS}\"
	--driver-class-path "${RAPIDS_CLASSPATH}"
	--conf spark.executor.extraJavaOptions=\"${FINAL_JAVA_OPTS[*]} ${RAPIDS_EXEC_OPTS}\"
	--conf spark.executor.extraClassPath=\"${RAPIDS_CLASSPATH}\"
	--conf spark.plugins=com.nvidia.spark.SQLPlugin
	--conf spark.rapids.memory.gpu.minAllocFraction=0
	--conf spark.rapids.memory.gpu.allocFraction=\"${GPU_FRACTION}\"
	--conf spark.rapids.sql.enabled=true
	--conf spark.rapids.sql.test.enabled=false
	--conf spark.rapids.sql.test.allowedNonGpu=org.apache.spark.sql.execution.LeafExecNode
	--conf spark.rapids.sql.explain=ALL
	--conf spark.rapids.sql.exec.CollectLimitExec=true
)
COMMAND_ARR+=("$@")

if [ "$DRY_RUN" = "true" ]; then
	echo "# Generating SparkSubmit command to start Spark RAPIDS"
	echo "${COMMAND_ARR[*]}"
else
	echo "#### Launchng generated Spark RAPIDS shell command"
	eval "${COMMAND_ARR[*]}"
fi
