#' ---
#' title: "Looking at Names"
#' author: "Josef Fruehwald"
#' ---


#' Important info
#' 
#' Names in cmudict: 3013
#'
#' Names out of cmudict: 1717 
#' 
#' Histogram of entries per name: {1: 2783, 2: 213, 3: 14, 4: 3}




library(plyr)
library(dplyr)
library(ggplot2)
library(directlabels)
library(knitr)

opts_chunk$set(fig.width = 8, fig.height = 5)

#' ## Bigrams first
bigrams <- read.delim("bigrams.txt", header = F)
colnames(bigrams) <- c("year", "sex","bigram","count")

bigrams %.% 
  mutate(year = as.numeric(as.character(year))) %.%
  filter(is.finite(year)) %.%
  group_by(year, sex) %.%
  mutate(prop = count/sum(count)) %.%
  arrange(-prop)%.%
  mutate(rank = rank(-prop)) -> bigrams

bigram_top_3 <- bigrams %.% filter(rank <= 3)
bigram_top_3_m <- subset(bigrams, sex == "M" &  
                         bigram %in% bigram_top_3$bigram[bigram_top_3$sex == "M"])
bigram_top_3_f <- subset(bigrams, sex == "F" &  
                         bigram %in% bigram_top_3$bigram[bigram_top_3$sex == "F"])
bigram_top_3_full <- rbind.fill(bigram_top_3_m, bigram_top_3_f)

bigram_top_3_full$bigram <- reorder(bigram_top_3_full$bigram, bigram_top_3_full$prop, mean)

#+ dev = "svg"
ggplot(bigram_top_3_full, aes(year, prop, color = bigram)) + 
  geom_line() + 
  geom_dl(aes(label = bigram), method = "last.points")+
  expand_limits(y =0, x = 2020)+
  facet_wrap(~sex)+
  guides(color = guide_legend(reverse = T))

#+ dev = "svg"
ggplot(bigram_top_3_full, aes(year, rank, color = bigram)) + 
  geom_line() + 
  geom_dl(aes(label = bigram), method = "last.points")+
  scale_y_reverse()+
  expand_limits(x = 2020)+
  facet_wrap(~sex)+
  guides(color = guide_legend(reverse = T))


#' ## Syllables


syllables <- read.delim("syllables.txt", header = F)
colnames(syllables) <- c("year","sex","syllable","count")

syllables %.% 
  mutate(year = as.numeric(as.character(year))) %.%
  filter(is.finite(year)) %.%
  group_by(year, sex) %.%
  mutate(prop = count/sum(count)) %.%
  arrange(-prop)%.%
  mutate(rank = rank(-prop)) -> syllables


syl_top_3 <- syllables %.% filter(rank <= 3)
syl_top_3_m <- subset(syllables, sex == "M" & 
                        syllable %in% syl_top_3$syllable[syl_top_3$sex == "M"])
syl_top_3_f <- subset(syllables, sex == "F" & 
                        syllable %in% syl_top_3$syllable[syl_top_3$sex == "F"])
syl_top_3_full <- rbind.fill(syl_top_3_m, syl_top_3_f)


#+ dev = "svg"
ggplot(syl_top_3_full, aes(year, prop, color = syllable)) + 
  geom_line() + 
  facet_wrap(~sex) +
  geom_dl(aes(label = syllable), method = "last.points")+
  expand_limits(x = 2020)


#+ dev = "svg"
ggplot(syl_top_3_full, aes(year, rank, color = syllable)) + 
  geom_line() + 
  facet_wrap(~sex) +
  geom_dl(aes(label = syllable), method = "last.points")+
  expand_limits(x = 2020) + 
  scale_y_reverse()


Cuhn <- syllables %.%
  filter(sex == "M" & grepl("@ N #", syllable)) %.%
  mutate(rank = rank(-prop))

Cuhn_3 <- Cuhn %.% filter(rank <= 3)
Cuhn_all_3 <- subset(Cuhn, syllable %in% Cuhn_3$syllable)

#+ dev = "svg"
ggplot(Cuhn_all_3, aes(year, prop, color = syllable)) + 
  geom_line()+
  geom_dl(aes(label = syllable), method = "last.points")+
  expand_limits(x = 2020)


#+ dev = "svg"
ggplot(Cuhn_all_3, aes(year, -rank, color = syllable)) + 
  geom_line()+
  geom_dl(aes(label = syllable), method = "last.points")+
  expand_limits(x = 2020)

#' ## Rhymes

rhymes <- read.delim("rhymes.txt", header = F)
colnames(rhymes) <- c("year","sex","rhyme","count")

rhymes %.% 
  mutate(year = as.numeric(as.character(year))) %.%
  filter(is.finite(year)) %.%
  group_by(year, sex) %.%
  mutate(prop = count/sum(count)) %.%
  arrange(-prop)%.%
  mutate(rank = rank(-prop)) -> rhymes


rime_top_3 <- rhymes %.% filter(rank <= 3)
rime_top_3_m <- subset(rhymes, sex == "M" & 
                         rhyme %in% rime_top_3$rhyme[rime_top_3$sex == "M"])
rime_top_3_f <- subset(rhymes, sex == "F" & 
                         rhyme %in% rime_top_3$rhyme[rime_top_3$sex == "F"])
rime_top_3_full <- rbind.fill(rime_top_3_m, rime_top_3_f)

#+ dev = "svg"
ggplot(rime_top_3_full, aes(year, rank, color = rhyme)) + 
  geom_line() + 
  facet_wrap(~sex) +
  geom_dl(aes(label = rhyme), method = "last.points")+
  expand_limits(x = 2020) + 
  scale_y_reverse()


#+ dev = "svg"
ggplot(rime_top_3_full, aes(year, prop, color = rhyme)) + 
  geom_line() + 
  facet_wrap(~sex) +
  geom_dl(aes(label = rhyme), method = "last.points")+
  expand_limits(y=0, x = 2020)


#' ## Onsets

onsets <- read.delim("onset.txt", header = F)
colnames(onsets) <- c("year","sex","onset","count")

onsets %.% 
  mutate(year = as.numeric(as.character(year))) %.%
  filter(is.finite(year), !onset %in% c("","#")) %.%
  group_by(year, sex) %.%
  mutate(prop = count/sum(count)) %.%
  arrange(-prop)%.%
  mutate(rank = rank(-prop)) -> onsets



ons_top_3 <- onsets %.% filter(rank <= 3)
ons_top_3_m <- subset(onsets, sex == "M" & 
                        onset %in% ons_top_3$onset[ons_top_3$sex == "M"])
ons_top_3_f <- subset(onsets, sex == "F" & 
                        onset %in% ons_top_3$onset[ons_top_3$sex == "F"])
ons_top_3_full <- rbind.fill(ons_top_3_m, ons_top_3_f)

#+ dev = "svg"
ggplot(ons_top_3_full, aes(year, rank, color = onset)) + 
  geom_line() + 
  facet_wrap(~sex) +
  geom_dl(aes(label = onset), method = "last.points")+
  expand_limits(x = 2020) + 
  scale_y_reverse()


#+ dev = "svg"
ggplot(ons_top_3_full, aes(year, prop, color = onset)) + 
  geom_line() + 
  facet_wrap(~sex) +
  geom_dl(aes(label = onset), method = "last.points")+
  expand_limits(y=0, x = 2020)
