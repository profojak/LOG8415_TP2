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
fi


function average () {
        ARR=("$@")
        echo $(IFS='+'; echo "scale=2;(${ARR[*]})/${#ARR[@]}"|bc)
}

OLD_TIMEFORMAT="$TIMEFORMAT"
TIMEFORMAT='%3U'

for input in input/*.txt; do
        times_linux=()
        times_hadoop=()
        FILENAME=$(basename "$input")
        echo "Benchmarking $FILENAME"
        for i in {1..3}; do
		LINUX_TIME=$(time (cat $input | tr ' ' '\n' | sort | uniq -c &> /dev/null) 2>&1 )
        	times_linux+=($LINUX_TIME)
		echo "Linux: $LINUX_TIME"

                HADOOP_TIME=$(time (hadoop jar /usr/local/hadoop-3.3.1/share/hadoop/tools/lib/hadoop-streaming-3.3.1.jar -mapper mapper.py -reducer reducer.py -input $input -output output &> /dev/null) 2>&1 )
                times_hadoop+=($HADOOP_TIME)
		echo "Hadoop: $HADOOP_TIME"
		rm -r output
        done

	AVG=$(average "${times_linux[@]}")
        echo "Average Linux: $AVG"
        AVG=$(average "${times_hadoop[@]}")
        echo "Average Hadoop: $AVG"
done

TIMEFORMAT="$OLD_TIMEFORMAT"
rm -r output
rm -r input
