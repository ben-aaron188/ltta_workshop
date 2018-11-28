##############################################################################
##### EUROCSS 2018
##### LTTA workshop
##### dataset preprocessing
##### author: B Kleinberg https://github.com/ben-aaron188
###############################################################################

# PREPARATION
## clear ws
rm(list = ls())

## load deps
require(tm)
require(data.table)
require(splitstackshape)

## set dir
setwd('/Users/bennettkleinberg/GitHub/ltta_workshop/raw_data')

## load function from GitHub repo
source('../workshop_data/r_deps/txt_df_from_dir.R')

### left
#### set to main raw data repo: https://github.com/maximilianmozes/ltta_workshop_data
setwd('./output_dir/left/parsed/')

#LOAD DATA
## read raw data
t1 = Sys.time()
df.full_corpus = txt_df_from_dir(dirpath = './'
                                 , recursive = T
                                 , to_lower = F
                                 , include_processed = F)
t2 = Sys.time()
t2-t1

## set variable for merge with meta data
df.full_corpus$vlog_id = sub('(.*)\\..*','\\1', df.full_corpus$file_id)
df.full_corpus$channel_vlog_id = tolower(paste(df.full_corpus$file_parent, df.full_corpus$vlog_id, sep="_"))

df.full_corpus = df.full_corpus[nchar(df.full_corpus$text) > 0, ]
df.full_corpus = droplevels(df.full_corpus)

nrow(df.full_corpus)

## load meta file
df.meta = as.data.frame(fread('../../../overview_left.txt'
                              , sep = ","
                              , header=F))
names(df.meta) = c('channel_id'
                   , 'file_id'
                   , 'url'
                   , 'view_count'
                   , 'date_posted'
                   , 'landing_url'
                   , 'upvotes'
                   , 'downvotes')

df.meta$channel_id = sub('(.*)\\..*','\\1', df.meta$channel_id)
df.meta$channel_vlog_id = tolower(paste(df.meta$channel_id, df.meta$file_id, sep="_"))
df.meta$view_count = as.numeric(gsub("[.]", "", as.character(df.meta$view_count)))
df.meta$upvotes = as.numeric(gsub("[.]", "", as.character(df.meta$upvotes)))
df.meta$downvotes = as.numeric(gsub("[.]", "", as.character(df.meta$downvotes)))
df.meta$date_posted = as.Date(df.meta$date_posted)
reference_date = as.Date('2018-10-30')
df.meta$days_until_reference = as.numeric(reference_date - df.meta$date_posted)
df.meta$view_count_corrected = round(df.meta$view_count/df.meta$days_until_reference, 2)
df.meta = na.omit(df.meta)

## merge
df.data_left = merge(df.full_corpus, df.meta, by='channel_vlog_id', all.x = T)
df.data_left = na.omit(df.data_left)
df.data_left$pol = 'l'

### right
setwd('../../right/parsed/')

#LOAD DATA
## read raw data
t1 = Sys.time()
df.full_corpus = txt_df_from_dir(dirpath = './'
                                 , recursive = T
                                 , to_lower = F
                                 , include_processed = F)
t2 = Sys.time()
t2-t1

## set variable for merge with meta data
df.full_corpus$vlog_id = sub('(.*)\\..*','\\1', df.full_corpus$file_id)
df.full_corpus$channel_vlog_id = tolower(paste(df.full_corpus$file_parent, df.full_corpus$vlog_id, sep="_"))

df.full_corpus = df.full_corpus[nchar(df.full_corpus$text) > 0, ]
df.full_corpus = droplevels(df.full_corpus)

nrow(df.full_corpus)

## load meta file
df.meta = as.data.frame(fread('../../../overview_right.txt'
                              , sep = ","
                              , header=F))
names(df.meta) = c('channel_id'
                   , 'file_id'
                   , 'url'
                   , 'view_count'
                   , 'date_posted'
                   , 'landing_url'
                   , 'upvotes'
                   , 'downvotes')

df.meta$channel_id = sub('(.*)\\..*','\\1', df.meta$channel_id)
df.meta$channel_vlog_id = tolower(paste(df.meta$channel_id, df.meta$file_id, sep="_"))
df.meta$view_count = as.numeric(gsub("[.]", "", as.character(df.meta$view_count)))
df.meta$upvotes = as.numeric(gsub("[.]", "", as.character(df.meta$upvotes)))
df.meta$downvotes = as.numeric(gsub("[.]", "", as.character(df.meta$downvotes)))
df.meta$date_posted = as.Date(df.meta$date_posted)
reference_date = as.Date('2018-10-30')
df.meta$days_until_reference = as.numeric(reference_date - df.meta$date_posted)
df.meta$view_count_corrected = round(df.meta$view_count/df.meta$days_until_reference, 2)
df.meta = na.omit(df.meta)

## merge
df.data_right = merge(df.full_corpus, df.meta, by='channel_vlog_id', all.x = T)
df.data_right = na.omit(df.data_right)
df.data_right$pol = 'r'

### CLEAN TRANSCRIPTS
df.data = rbind(df.data_left, df.data_right)
dt.data = setDT(df.data)

##exclude too short transcripts and non-English ones
dt.data[, .N]
dt.data = dt.data[nwords > 100, ]
dt.data[, .N]

#english check?
source('/Users/bennettkleinberg/GitHub/r_helper_functions/english_word_match/match_english.R')

t1 = Sys.time()
dt.data[, eng_prop := match_english(dt.data$text, 'match', 'prop')]
t2 = Sys.time()
print(t2-t1)

t1 = Sys.time()
dt.data[, ascii := match_english(dt.data$text, 'ascii', 'prop')]
t2 = Sys.time()
print(t2-t1)

### STORE
# save(dt.data
#      , file='../../../eurocss_ltta_workshop_data.RData')

### sampling
table(dt.data$pol)

### only channels with at least 2000 videos
selected_channels = dt.data[, .N, by=file_parent][N > 2000, file_parent]

dt.sub = dt.data[file_parent %in% selected_channels, ]

set.seed(123)
dt.sampled = stratified(dt.sub, c("file_parent", "pol"), 2000)
selected_channels_left = sample(x = unique(dt.sampled$file_parent[dt.sampled$pol == 'l'])
                                , size = 4
                                , replace = F
                                )
final_channels = c(unique(dt.sampled$file_parent[dt.sampled$pol == 'r'])
                   , selected_channels_left)

dt.sampled_balanced = dt.sampled[file_parent %in% final_channels, ]

###fix channel names
dt.sampled[file_parent == 'UCaeO5vkdj5xOQHp4UmIN6dw', ]

dt.sampled_balanced$channel_name = as.factor(dt.sampled_balanced$file_parent)
levels(dt.sampled_balanced$channel_name)[7:8] = c('thedailywire', 'rebelmedia')

# save(dt.sampled_balanced
#      , file='../../../eurocss_ltta_workshop_data_sampled.RData')

###END