import com.nvidia.spark.rapids._
import org.apache.log4j._
import org.apache.spark.sql.Row
import org.apache.spark.sql.types._
import org.scalatest._

// potential start up issue should already have happened
// resetting the log level to WARN
sc.setLogLevel("WARN")

// review effective configuration
LogManager.getLogger("com.nvidia.spark.rapids.SparkSessionHolder").setLevel(Level.DEBUG)
