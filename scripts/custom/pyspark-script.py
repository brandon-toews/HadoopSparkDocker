from pyspark.sql import SparkSession

# Initialize Spark session
spark = SparkSession.builder \
    .appName("Titanic Analysis") \
    .master("spark://spark-master:7077") \
    .getOrCreate()

# Read the dataset
df = spark.read.format("csv") \
    .option("header", True) \
    .option("separator", ",") \
    .load("hdfs://namenode:9000/titanic.csv")

# Show the data
print("Sample of Titanic dataset:")
df.show()

# Get basic statistics
print("\nDataset Statistics:")
df.describe().show()

# Stop the Spark session
spark.stop()