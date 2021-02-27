import org.apache.log4j._
import org.apache.spark._
import org.scalatest._

val hashTests = new com.nvidia.spark.rapids.HashAggregatesSuite

// potential start up issue should already have happened
// resetting the log level to WARN
sc.setLogLevel("WARN")
LogManager.getLogger("com.nvidia.spark.rapids.SparkSessionHolder").setLevel(Level.DEBUG)
