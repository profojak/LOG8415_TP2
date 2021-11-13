# This file benchmarks downloaded files from input/ in PySpark interactive shell.
# Open shell with the `pyspark` command and copypaste everything from this file
# including newlines at the end.
# Output: Indexes of files and the time it took to process them, in seconds.

from timeit import default_timer as timer

import glob
import shutil

averages = []
times = []

for file in glob.iglob("input/*.txt"):
	for i in range(3):
		start = timer()
		words = sc.textFile(file).flatMap(lambda line: line.split(" "))
		wordCounts = words.map(lambda word: (word, 1)).reduceByKey(lambda a,b:a +b)
		wordCounts.saveAsTextFile(f'out-{file}')
		end = timer()
		times.append(end - start)
		shutil.rmtree(f'out-{file}', ignore_errors=True)
	averages.append(sum(times)/len(times))
	times = []


for index, avg in enumerate(averages, start=1):
	print(f'({index}, {round(avg, 2)}) ', end='')


