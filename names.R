#' ---
#' title: "Looking at Names"
#' author: "Josef Fruehwald"
#' ---


#' Important info
#' 
#' Names in cmudict: 4257
#'
#' Names out of cmudict: 2525 




library(plyr)
library(dplyr)
library(ggplot2)
library(directlabels)
library(knitr)

opts_chunk$set(fig.width = 8, fig.height = 5)


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
syl_top_3_m <- subset(syllables, sex == "boy" & 
                        syllable %in% syl_top_3$syllable[syl_top_3$sex == "boy"])
syl_top_3_f <- subset(syllables, sex == "girl" & 
                        syllable %in% syl_top_3$syllable[syl_top_3$sex == "girl"])
syl_top_3_full <- rbind.fill(syl_top_3_m, syl_top_3_f)


#+ dev = "svg"
ggplot(syl_top_3_full, aes(year, prop, color = syllable)) + 
  stat_smooth(se = F, span = 0.08)+
  facet_wrap(~sex) +
  geom_dl(aes(label = syllable), method = "last.qp")+
  geom_dl(aes(label = syllable), method = "first.qp")+
  xlim(1870,2020)+
  theme_bw()


#+ dev = "svg"
ggplot(syl_top_3_full, aes(year, rank, color = syllable)) + 
  geom_line() + 
  facet_wrap(~sex) +
  geom_dl(aes(label = syllable), method = "last.points")+
  expand_limits(x = 2020) + 
  scale_y_reverse()


Cuhn <- syllables %.%
  filter(sex == "boy" & grepl("@ N #", syllable)) %.%
  mutate(rank = rank(-prop))

Cuhn_3 <- Cuhn %.% filter(rank <= 3)
Cuhn_all_3<- subset(Cuhn, syllable %in% Cuhn_3$syllable)

#+ dev = "svg"
ggplot(Cuhn_all_3, aes(year, prop, color = syllable)) + 
  stat_smooth(se = F, span = 0.08)+
  geom_dl(aes(label = syllable), method = "last.qp")+
  geom_dl(aes(label = syllable), method = "first.qp")+
  xlim(1870,2020)


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


rime_top_5 <- rhymes %.% filter(rank <= 5)
rime_top_5_m <- subset(rhymes, sex == "boy" & 
                         rhyme %in% rime_top_5$rhyme[rime_top_5$sex == "boy"])
rime_top_5_f <- subset(rhymes, sex == "girl" & 
                         rhyme %in% rime_top_5$rhyme[rime_top_5$sex == "girl"])
rime_top_5_full <- rbind.fill(rime_top_5_m, rime_top_5_f)

#+ dev = "svg"
ggplot(rime_top_5_full, aes(year, rank, color = rhyme)) + 
  geom_line() + 
  facet_wrap(~sex) +
  geom_dl(aes(label = rhyme), method = "last.points")+
  expand_limits(x = 2020) + 
  scale_y_reverse()


#+ dev = "svg"
ggplot(rime_top_5_full, aes(year, prop, color = rhyme)) + 
  stat_smooth(span = 0.08, se = F) + 
  facet_wrap(~sex) +
  geom_dl(aes(label = rhyme), method = "last.qp")+
  geom_dl(aes(label = rhyme), method = "first.qp")+
  expand_limits(y=0)+
  xlim(1870,2020)


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
ons_top_3_m <- subset(onsets, sex == "boy" & 
                        onset %in% ons_top_3$onset[ons_top_3$sex == "boy"])
ons_top_3_f <- subset(onsets, sex == "girl" & 
                        onset %in% ons_top_3$onset[ons_top_3$sex == "girl"])
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

#' ## Codas

codas <- read.delim("codas.txt", header = F)
colnames(codas) <- c("year","sex","coda","count")

codas %.% 
  mutate(year = as.numeric(as.character(year))) %.%
  filter(is.finite(year), !coda %in% c("","#")) %.%
  group_by(year, sex) %.%
  mutate(prop = count/sum(count)) %.%
  arrange(-prop)%.%
  mutate(rank = rank(-prop)) -> codas



cod_top_3 <- codas %.% filter(rank <= 3)
cod_top_3_m <- subset(codas, sex == "boy" & 
                        coda %in% cod_top_3$coda[cod_top_3$sex == "boy"])
cod_top_3_f <- subset(codas, sex == "girl" & 
                        coda %in% cod_top_3$coda[cod_top_3$sex == "girl"])
cod_top_3_full <- rbind.fill(cod_top_3_m, cod_top_3_f)

#+ dev = "svg"
ggplot(cod_top_3_full, aes(year, rank, color = coda)) + 
  geom_line() + 
  facet_wrap(~sex) +
  geom_dl(aes(label = coda), method = "last.points")+
  expand_limits(x = 2020) + 
  scale_y_reverse()


#+ dev = "svg"
ggplot(cod_top_3_full, aes(year, prop, color = coda)) + 
  geom_line() + 
  facet_wrap(~sex) +
  geom_dl(aes(label = coda), method = "last.points")+
  expand_limits(y=0, x = 2020)


