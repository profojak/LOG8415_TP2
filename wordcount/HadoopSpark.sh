#!/usr/bin/env bash

source ~/.profile

if [ ! -d "input" ] ; then
	echo "Downloading dataset!"
	mkdir input
	cat url.txt | while read line
	do
		(cd input
		URL=`curl -Ls -o /dev/null -w "%{url_effective}\n" "$line"`
		curl -Ls -O "$URL")
	done
	echo "Starting pseudo-distributed Hadoop daemons!"
	/usr/local/hadoop-3.3.1/sbin/start-all.sh
	echo "Setting up HDFS!"
	hdfs dfs -mkdir /user
	hdfs dfs -mkdir /user/$(whoami)
	hdfs dfs -mkdir wordcount
	hdfs dfs -mkdir wordcount/input
	hdfs dfs -copyFromLocal input/* wordcount/input
	hdfs dfs -copyFromLocal mapper.py wordcount
	hdfs dfs -copyFromLocal reducer.py wordcount
	echo "Following files copide to HDFS:"
	hdfs dfs -ls wordcount/input/
fi


function average () {
        ARR=("$@")
        echo $(IFS='+'; echo "scale=2;(${ARR[*]})/${#ARR[@]}"|bc)
}

OLD_TIMEFORMAT="$TIMEFORMAT"
TIMEFORMAT='%3U'
hdfs dfs -mkdir wordcount/output

for input in input/*.txt; do
        times_spark=()
        times_hadoop=()
        FILENAME=$(basename "$input")
        echo "Benchmarking $FILENAME"
        for i in {1..3}; do
		SPARK_TIME=$(time (spark-submit spark.py $input wordcount/output &> /dev/null) 2>&1 )
        	times_spark+=($SPARK_TIME)
		echo "Spark: $SPARK_TIME"

		hdfs dfs -rm -r wordcount/output &> /dev/null

                HADOOP_TIME=$(time (hadoop jar /usr/local/hadoop-3.3.1/share/hadoop/tools/lib/hadoop-streaming-3.3.1.jar -mapper wordcount/mapper.py -reducer wordcount/reducer.py -input wordcount/input/$input -output wordcount/output &> /dev/null) 2>&1 )
                times_hadoop+=($HADOOP_TIME)
		echo "Hadoop: $HADOOP_TIME"
        done

	AVG=$(average "${times_spark[@]}")
        echo "Average Spark: $AVG"
        AVG=$(average "${times_hadoop[@]}")
        echo "Average Hadoop: $AVG"
done

TIMEFORMAT="$OLD_TIMEFORMAT"
hdfs dfs -rm -r wordcount
rm -r input
/usr/local/hadoop-3.3.1/sbin/stop-all.sh
