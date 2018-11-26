# ---
# title: "Feature extraction 1: NCS sentiment window"
# subtitle: "EuroCSS workshop: LTTA"
# output: html_notebook
# author:  B Kleinberg https://github.com/ben-aaron188
# ---

rm(list = ls())

## load data
setwd('SOMETHING/ltta_workshop/ltta_workshop_data/hackathon_data/main_data')
load('eurocss_ltta_workshop_data_sampled.RData')

require(stringr)
require(rlist)
source('../r_deps/r_deps/txt_df_from_dir.R')

a = ncs_full(txt_input_col = dt.sampled_balanced$text[1:20]
             , txt_id_col = dt.sampled_balanced$channel_vlog_id[1:20]
             , low_pass_filter_size = 5
             , transform_values = T
             , normalize_values = F
             , min_tokens = 10
             , cluster_lower = 3
             , cluster_upper = 3
)


## Do not run.
#non-parallel
##simple loop with memory cleaning
# setwd('../../raw_data/loop_run_ncs')
# seq_max = nrow(dt.sampled_balanced)
# #seq_max = 12000
# seq_min = 14201
# seq_batch = seq(seq_min, seq_max, 200)
# for(i in seq_batch){
#   print(i)
#   seq_index = which(i == seq_batch)
#   if(seq_index < length(seq_batch)){
#     new_index = seq_batch[seq_index]:(seq_batch[seq_index+1]-1)
#   } else {
#     new_index = seq_batch[seq_index]:seq_max
#   }
#   df.sentiment = ncs_full(txt_input_col = dt.sampled_balanced$text[new_index]
#                , txt_id_col = dt.sampled_balanced$channel_vlog_id[new_index]
#                , low_pass_filter_size = 5
#                , transform_values = T
#                , normalize_values = F
#                , min_tokens = 10
#                , cluster_lower = 3
#                , cluster_upper = 3
#                )
#   savename = paste(paste('batch', min(new_index), max(new_index), sep="_"), '.RData', sep="")
#   save(df.sentiment
#        , file = savename)
#   rm(df.sentiment)
# }
## End do not run.

#cbind all from directory
files = list.files()
temp_list = list()
for(i in files){
  seq_index = which(i == files)
  load(i)
  temp_list[[seq_index]] = df.sentiment
  rm(i)
}

df.sentiments = list.cbind(temp_list)

#remove duplicated columns
if(length(which(duplicated(names(df.sentiments)))) > 0){
  df.sentiments = df.sentiments[, -which(duplicated(names(df.sentiments)))]
}
## this excludes columns where there are only NAs


#remove NA columns
df.sentiments = df.sentiments[colSums(is.na(df.sentiments)) == 0]

df.t_sentiments = t(df.sentiments)
dt.sentiment = data.frame(df.t_sentiments)
names(dt.sentiment) = paste('snt_', 1:100, sep="")

dt.sentiment$Filename = row.names(dt.sentiment)
dt.sentiment = setDT(dt.sentiment)

#merge
dt.data_sentiment = merge(dt.sampled_balanced, dt.sentiment, by.x = 'channel_vlog_id', by.y = 'Filename')

dt.data_sentiment_notext = dt.data_sentiment[, -2]
# save(dt.data_sentiment
#      , file='../eurocss_ltta_workshop_data_sentiment.RData')
# 
# save(dt.data_sentiment_notext
#      , file='../eurocss_ltta_workshop_data_sentiment_notext.RData')

#END