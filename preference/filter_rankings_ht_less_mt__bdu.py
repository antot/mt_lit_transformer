#!/usr/bin/env python3

# Remove lines from the csv file in which HT<MT


import csv
import sys


with open(sys.argv[1]) as csvfile:
	readCSV = csv.reader(csvfile, delimiter=',')
	c_line = 0
	c_discard = 0
	for row in readCSV:
		c_line += 1

		if(c_line > 1):
			sys1 = row[2]
			sys2 = row[10]
			sys1_rank = int(row[6])
			sys2_rank = int(row[0])


			if "_t1" in sys1:
				if sys1_rank > sys2_rank:
					#print("discard")
					c_discard += 1
					continue
			elif "_t1" in sys2:
				if sys2_rank > sys1_rank:
					#print("discard")
					c_discard += 1
					continue

		print("{},{},{},{},{},{},{},{},{},{},{},{}".format(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11]))



print("{} lines read, {} lines discarded".format(c_line, c_discard), file=sys.stderr)

