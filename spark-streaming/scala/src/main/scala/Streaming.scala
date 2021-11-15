import org.apache.spark.sql.SparkSession

object Streaming {
  def main(agrs: Array[String]) = {

    val spark = SparkSession
      .builder()
      .appName("Spark Streaming With Scala and Kafka")
      .master("spark://172.18.0.10:7077")
      .getOrCreate()

    import spark.implicits._

    spark.sparkContext.setLogLevel("ERROR")

    val df = spark.readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", "172.18.0.9:9093")
      .option("subscribe", "test-topic")
      .load()

    val rawDF = df.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)").as[(String, String)]


    val query = rawDF.writeStream
      .outputMode("update")
      .format("console")
      .start()

    query.awaitTermination()
  }
}
