library(readr)
library(tidyr)
library(dplyr)
library(tidytext)

# read csv files
h2012 <- read.csv('inquirer_headlines2012.csv', stringsAsFactors = FALSE)
h2013 <- read.csv('inquirer_headlines2013.csv', stringsAsFactors = FALSE)
h2014 <- read.csv('inquirer_headlines2014.csv', stringsAsFactors = FALSE)
h2015 <- read.csv('inquirer_headlines2015.csv', stringsAsFactors = FALSE)
h2016 <- read.csv('inquirer_headlines2016.csv', stringsAsFactors = FALSE)
h2017 <- read.csv('inquirer_headlines2017.csv', stringsAsFactors = FALSE)
h <- rbind(h2012, h2013, h2014, h2015, h2016, h2017) %>% select(-X, link) 
h$ID <- seq.int(nrow(h))
h$tag <- "no tag"

# tag companies
company_tag <- list(
  c('bdo', 'banco de oro'),
  c('san miguel'),
  c('bpi', 'bank of the philippine islands'),
  c('toyota'))
  
for (i in seq(company_tag)) {
  x <- filter(h, grepl(paste(company_tag[[i]], collapse='|'), headline, ignore.case = TRUE))
  h$tag <- if_else(!is.na(match(h$ID,x$ID)), 
                   if_else(h$tag=="no tag", company_tag[[i]][1], paste(company_tag[[i]][1],h$tag, sep = " ")),
                   h$tag)
}


h_summary <- h %>% group_by(tag) %>% 
  summarise(
    count = n()
  ) %>% 
  ungroup()

# remove untagged headlines
headlines <- filter(h, h$tag!="no tag")

# sentiment analysis
sentiments <- get_sentiments("afinn")
h_sentences <- tibble(headline = headlines$headline, ID = headlines$ID) %>% 
  unnest_tokens(word, headline) %>% 
  inner_join(sentiments) %>% 
  group_by(ID) %>% 
  mutate(word_num = n()) %>% 
  summarise(sentiment = (sum(score)))
h_sentiments <- left_join(h, h_sentences) %>% select(headline, sentiment)

sentiments2 <- get_sentiments("loughran")
h_sent2 <- tibble(headline = headlines$headline, ID = headlines$ID) %>% 
  unnest_tokens(word, headline) %>% 
  inner_join(sentiments2) %>% 
  mutate(dummy = 1, a = paste('x',sentiment)) %>% 
  spread(a,dummy, fill = 0) %>% 
  group_by(ID) %>% 
  summarise_at(vars(starts_with('x')), sum)

h_sentiments <- left_join(h, h_sent2) %>% select(headline,sentiment)

table(is.na(h_sentiments$sentiment))


save.image(file = "sentiment.RData")
