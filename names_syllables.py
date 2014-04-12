import sys
sys.path.append('./syllabify')
from syllabify import syllabify

import csv
import re
from nltk.corpus import cmudict
import string

names_file = open("top_names_since_1950.csv", 'rb')
names_list = csv.reader(names_file)

the_dict = cmudict.dict()

syllable_dict = {}
rhyme_dict = {}
coda_dict = {}
onset_dict = {}


def process_name(row, the_dict, sex, syllable_dict, rhyme_dict, coda_dict, onset_dict):
	year = row[0]
	name_dict = {"M":row[2].lower(), "F":row[3].lower()}	
	name = name_dict[sex]

	trans = the_dict[name][0]
	syls = syllabify(trans)
	mutable_syls = []
	for syl in syls:
		mutable_syl = [x for x in syl]
		mutable_syls.append(mutable_syl)
	mutable_syls[0][0] = ["#"] + mutable_syls[0][0]
	mutable_syls[-1][-1] = mutable_syls[-1][-1] + ["#"]		

	if year not in syllable_dict:
		syllable_dict[year] = {"M":{}, "F":{}}

	if year not in rhyme_dict:
		rhyme_dict[year] = {"M":{}, "F":{}}

	if year not in coda_dict:
		coda_dict[year] = {"M":{}, "F":{}}

	if year not in onset_dict:
		onset_dict[year] = {"M":{}, "F":{}}


	for syl in mutable_syls:
		syl[1] = [x.replace("AH0", "@") for x in syl[1]]
		rhyme_list = syl[1] + syl[2]
		rhyme_string = string.join(rhyme_list, " ")

		if rhyme_string in rhyme_dict[year][sex]:
			rhyme_dict[year][sex][rhyme_string] += 1
		else:
			rhyme_dict[year][sex][rhyme_string] = 1

		coda_string = string.join(syl[2], " ")
		if coda_string in coda_dict[year][sex]:
			coda_dict[year][sex][coda_string] += 1
		else:
			coda_dict[year][sex][coda_string] = 1


		onset_string = string.join(syl[0], " ")
		if onset_string in onset_dict[year][sex]:
			onset_dict[year][sex][onset_string] += 1
		else:
			onset_dict[year][sex][onset_string] = 1

		syllable_list = [item for sublist in syl for item in sublist]
		syllable_string = string.join(syllable_list, " ")
		if syllable_string in syllable_dict[year][sex]:
			syllable_dict[year][sex][syllable_string] += 1
		else:
			syllable_dict[year][sex][syllable_string] = 1

	return (syllable_dict, rhyme_dict, coda_dict, onset_dict)

for row in names_list:
	boy = row[2].lower()
	if boy in the_dict:
		syllable_dict, rhyme_dict, coda_dict,\
		onset_dict = process_name(row, the_dict, "M",\
								  syllable_dict, rhyme_dict, coda_dict, onset_dict)

	girl = row[3].lower()
	if girl in the_dict:
		syllable_dict, rhyme_dict, coda_dict,\
		onset_dict = process_name(row, the_dict, "F",\
								  syllable_dict, rhyme_dict, coda_dict, onset_dict)


def dict_writer(out_dict, output):
	''' Writes the dictionaries from this script to csv '''
	out_file = open(output, 'w')
	out_writer = csv.writer(out_file, delimiter = "\t")

	for year in out_dict:
		for sex in out_dict[year]:
			for gram in out_dict[year][sex]:
				out_writer.writerow([year, sex, gram, out_dict[year][sex][gram]])

	out_file.close()

dict_writer(syllable_dict, "syllables.txt")
dict_writer(rhyme_dict, "rhymes.txt")
dict_writer(coda_dict, "codas.txt")
dict_writer(onset_dict, "onset.txt")