from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession
import os

if __name__ == '__main__':
    spark_session = SparkSession.builder.master('local[4]').appName('LocalWordCount').getOrCreate()
    sc = spark_session.sparkContext
    words = sc.textFile('hdfs://localhost:9000/user/' + os.getlogin() + '/wordcount/input/' + argv[1]).flatMap(lambda line: line.split(" "))
    word_counts = words.map(lambda word: (word, 1)).reduceByKey(lambda a,b:a +b)
    word_counts.saveAsTextFile('hdfs://localhost:9000/user/' + os.getlogin() + '/wordcount/output')
