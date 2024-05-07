from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, udf
from pyspark.sql.types import StructType, StructField, StringType, DoubleType
from pyspark.sql.types import IntegerType

# Initialize SparkSession with Kafka consumer configuration
spark = SparkSession.builder \
    .appName("Calcul AQI Streaming") \
    .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.0") \
    .getOrCreate()

# Define the schema with appropriate data types
# Définir le schéma avec les types de données appropriés
schema = StructType([
    StructField("DateTime", StringType()),
    StructField("Latitude", StringType()), 
    StructField("Longitude", StringType()),  
    StructField("NO2", IntegerType()),
    StructField("CO", IntegerType()),  
    StructField("PM10", IntegerType()),  
    StructField("PM25", IntegerType()),  
    StructField("SO2", IntegerType()), 
    StructField("O3", IntegerType()),  
    StructField("Direction vent", StringType()),  
    StructField("Vitesse vent", StringType())  
])

kafka_consumer_properties = {
    "kafka.bootstrap.servers": "localhost:9092",
    "subscribe": "TransferData",
    "kafka.consumer.poll.ms": "500"  # Adjust as needed
}

# Read streaming data from Kafka with specified consumer properties
streaming_df = spark \
    .readStream \
    .format("kafka") \
    .options(**kafka_consumer_properties) \
    .load() \
    .selectExpr("CAST(value AS STRING)")  # Assuming data is in JSON format

parsed_streaming_df = streaming_df \
    .select(from_json(col("value"), schema).alias("data")) \
    .select("data.*")
from pyspark.sql.functions import col

# Convertir les champs numériques en entiers
parsed_streaming_df = streaming_df \
    .selectExpr(
        "CAST(DateTime AS StringType()) AS DateTime",
        "CAST(Latitude AS Double) AS Latitude",
        "CAST(Longitude AS Double) AS Longitude",
        "CAST(NO2 AS Double) AS NO2",
        "CAST(CO AS Double) AS CO",
        "CAST(PM10 AS Double) AS PM10",
        "CAST(PM25 AS Double) AS PM25",
        "CAST(SO2 AS Double) AS SO2",
        "CAST(O3 AS Double) AS O3",
        "Direction vent",
        "Vitesse vent"
    )

# Lire les données de streaming depuis Kafka et les afficher dans la console
query = parsed_streaming_df \
    .writeStream \
    .outputMode("append") \
    .format("console") \
    .start()

# Attendez que la requête en continu se termine
query.awaitTermination()
