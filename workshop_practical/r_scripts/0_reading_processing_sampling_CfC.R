##############################################################################
##### EUROCSS 2018
##### LTTA workshop
##### dataset preprocessing: creators for change data
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
setwd('/Users/bennettkleinberg/GitHub/ltta_workshop/data_creators_for_change/')

## load function from GitHub repo
source('../workshop_data/r_deps/txt_df_from_dir.R')

### Creators for Change (CFC)
#### set to main raw data repo: https://github.com/maximilianmozes/ltta_workshop_data
setwd('./creators_for_change/output_dir/parsed')

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
df.meta = as.data.frame(fread('../../overview.txt'
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
reference_date = as.Date('2018-11-30')
df.meta$days_until_reference = as.numeric(reference_date - df.meta$date_posted)
df.meta$view_count_corrected = round(df.meta$view_count/df.meta$days_until_reference, 2)
df.meta = na.omit(df.meta)

## merge
df.data_cfc = merge(df.full_corpus, df.meta, by='channel_vlog_id', all.x = T)
df.data_cfc = na.omit(df.data_cfc)
df.data_cfc$type = 'CFC'

### matched data
setwd('../../../matched_vlogs/output_dir/parsed/')

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
df.meta = as.data.frame(fread('../../overview.txt'
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
reference_date = as.Date('2018-11-30')
df.meta$days_until_reference = as.numeric(reference_date - df.meta$date_posted)
df.meta$view_count_corrected = round(df.meta$view_count/df.meta$days_until_reference, 2)
df.meta = na.omit(df.meta)

## merge
df.data_matched = merge(df.full_corpus, df.meta, by='channel_vlog_id', all.x = T)
df.data_matched = na.omit(df.data_matched)
df.data_matched$type = 'matched_vlog'

### CLEAN TRANSCRIPTS
df.data = rbind(df.data_cfc, df.data_matched)
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

dt.data[, .N]
dt.data = dt.data[eng_prop > .50 & ascii > .90, ]
dt.data[, .N]

###fix channel names
dt.data$channel_name = as.factor(dt.data$file_parent)
dt.data = droplevels(dt.data)
levels(dt.data$channel_name)[39:54] = c('thatsbella'
                                        , 'jacksonodoherty'
                                        , 'beni'
                                        , 'tiana'
                                        , 'beleafinfatherhood'
                                        , 'allylaw'
                                        , 'safianygaard'
                                        , 'morgz'
                                        , 'saffronbarker'
                                        , 'loganpaulvlogs'
                                        , 'adiamor'
                                        , 'queennaija'
                                        , 'lelepons'
                                        , 'alissaviolet'
                                        , 'daviddobrik'
                                        , 'kierabridget')


### STORE
save(dt.data
     , file='/Users/bennettkleinberg/Dropbox/workshop_eurocss/hackathon_data/main_data/eurocss_cfc_data_full.RData')


###END