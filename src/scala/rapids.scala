import org.apache.spark._
import org.apache.spark.sql._
import com.nvidia.spark.rapids._

val hashTests = new HashAggregatesSuite

val frame = hashTests.shortsFromCsv(spark).agg(
      (max("shorts") - min("more_shorts")) * lit(5),
      sum("shorts"),
      count("*"),
      avg("shorts"),
      avg(col("more_shorts") * lit("10")))
