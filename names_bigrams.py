import csv
import re
from nltk.corpus import cmudict

names_file = open("top_names_since_1950.csv", 'rb')
names_list = csv.reader(names_file)

the_dict = cmudict.dict()

year_dict = {}

for row in names_list:
	year = row[0]
	rank = row[1]
	boy  = row[2].lower()
	girl = row[3].lower()

	if boy in the_dict:
		boy_trans = the_dict[boy][0]
		boy_trans = [x.replace("AH0", "@") for x in boy_trans]
		boy_trans = [re.sub("[0-9]", "", x) for x in boy_trans]
		if "#" not in boy_trans[0]:
			boy_trans[0]  = "#"+boy_trans[0]
		if "#" not in boy_trans[-1]:
			boy_trans[-1] = boy_trans[-1]+"#"
		boy_bigrams = []

		for i in range(1,len(boy_trans)):
			boy_bigrams.append(boy_trans[i-1]+" "+boy_trans[i])

		if year not in year_dict:
			year_dict[year] = {"M" : {}, "F" : {}}
		for boy_gram in boy_bigrams:
			if boy_gram in year_dict[year]["M"]:
				year_dict[year]["M"][boy_gram] += 1
			else:
				year_dict[year]["M"][boy_gram] = 1

	if girl in the_dict:
		girl_trans = the_dict[girl][0]
		girl_trans = [x.replace("AH0", "@") for x in girl_trans]
		girl_trans = [re.sub("[0-9]", "", x) for x in girl_trans]

		if "#" not in girl_trans[0]:
			girl_trans[0] = "#"+girl_trans[0]
		if "#" not in girl_trans[-1]:
			girl_trans[-1] = girl_trans[-1]+"#"

		girl_bigrams = []
		for i in range(1, len(girl_trans)):
			girl_bigrams.append(girl_trans[i-1]+" "+girl_trans[i])

		if year not in year_dict:
			year_dict[year] = {"M":{}, "F":{}}

		for girl_gram in girl_bigrams:
			if girl_gram in year_dict[year]["F"]:
				year_dict[year]["F"][girl_gram] += 1
			else:
				year_dict[year]["F"][girl_gram] = 1

out_file = open("bigrams.txt", 'w')
out_writer = csv.writer(out_file, delimiter = "\t")

for year in year_dict:
	for sex in year_dict[year]:
		for gram in year_dict[year][sex]:
			out_writer.writerow([year, sex, gram, year_dict[year][sex][gram]])



