import csv
import re
from nltk.corpus import cmudict

names_file = open("data-baby-names/baby-names.csv", 'rb')
names_list = csv.reader(names_file)

the_dict = cmudict.dict()

year_dict = {}

header = names_list.next()

in_dict = {}
out_dict = {}

for row in names_list:
	year = row[0]
	name = row[1].lower()
	sex = row[3]

	if name in the_dict:
		if name in in_dict:
			in_dict[name] += 1
		else:
			in_dict[name] = 1
	else:
		if name in out_dict:
			out_dict[name] += 1
		else:
			out_dict[name] = 1


print len(in_dict.keys())
print len(out_dict.keys())