#!/bin/bash
set -x

SCALATEST_VERSION=3.0.5

SPARK_HOME=${SPARK_HOME:-$HOME/gits/spark}

# pre-requisite: `mvn package` has been run 
SPARK_RAPIDS_HOME=${SPARK_RAPIDS_HOME:-$HOME/gits/spark-rapids}

RAPIDS_SHELL_HOME=${RAPIDS_SHELL_HOME:-$HOME/gits/rapids-shell}

MODULES="sql-plugin
	shuffle-plugin
	shims/spark*
	udf-compiler
	udf-examples
	api_validation
	integration_tests
	tests
	tests-spark310+"

for module in $MODULES; do
  # RAPIDS_CLASSES=$RAPIDS_CLASSES:$SPARK_RAPIDS_HOME/$module/target/classes
  RAPIDS_CLASSES=$RAPIDS_CLASSES:$SPARK_RAPIDS_HOME/$module/target/test-classes
done

SCALATEST_JARS=$(find ~/.m2 \
	-path \*/$SCALATEST_VERSION/\* -name \*scalatest\*jar -o \
	-path \*/$SCALATEST_VERSION/\* -name \*scalactic\*jar | tr -s "\n" ":")

ALL_JARS=$(echo $SPARK_RAPIDS_HOME/dist/target/rapids*.jar)
ALL_JARS=$ALL_JARS:$(echo $SPARK_RAPIDS_HOME/integration_tests/target/dependency/cudf*jar)
ALL_JARS=$ALL_JARS:$(echo $SPARK_RAPIDS_HOME/tests/target/rapids*jar)
ALL_JARS=$(echo $ALL_JARS | tr -s " " ":" )
RAPIDS_CLASSPATH=$RAPIDS_CLASSES:$ALL_JARS:$SCALATEST_JARS

SPARK_SHELL=${SPARK_SHELL:-pyspark}

${SPARK_HOME}/bin/${SPARK_SHELL} \
	-I $RAPIDS_SHELL_HOME/src/scala/rapids.scala \
	--driver-memory 10g \
	--num-executors 1 \
	--driver-java-options "-ea -Dlog4j.debug=true -Dlog4j.configuration=file:${RAPIDS_SHELL_HOME}/src/conf/log4j.properties $JDBSTR" \
	--driver-class-path "$RAPIDS_CLASSPATH" \
	--conf spark.executor.extraClassPath="$RAPIDS_CLASSPATH" \
	--conf spark.plugins=com.nvidia.spark.SQLPlugin \
	$@
