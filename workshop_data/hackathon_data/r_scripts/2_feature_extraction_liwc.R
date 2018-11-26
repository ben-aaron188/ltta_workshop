# ---
# title: "Feature extraction 1: LIWC"
# subtitle: "EuroCSS workshop: LTTA"
# output: html_notebook
# author:  B Kleinberg https://github.com/ben-aaron188
# ---

rm(list = ls())

## load data
setwd('SOMETHING/ltta_workshop/ltta_workshop_data')
load('eurocss_ltta_workshop_data_sampled.RData')

## load deps
require(data.table)

## set id
dt.sampled_balanced$new_id_runner = 1:nrow(dt.sampled_balanced)

## write files
setwd('../raw_data/individual_files_sampled')
lapply(seq(nrow(dt.sampled_balanced)), function(i){
  write.table(dt.sampled_balanced$text[i],
              file = paste(dt.sampled_balanced$new_id_runner[i]
                           , '.txt'
                           , sep=''),
              col.names = FALSE,
              row.names = FALSE,
              append=F,
              sep = '\t',
              quote = FALSE)
})

## merge LIWC by id
setwd('./liwc_output')
liwc_batch1 = fread('./batch1.txt', header=T)
liwc_batch2 = fread('./batch2.txt', header=T)
liwc_batch3 = fread('./batch3.txt', header=T)
liwc_batch4 = fread('./batch4.txt', header=T)

liwc = do.call('rbind', list(liwc_batch1, liwc_batch2, liwc_batch3, liwc_batch4))


## merge
setDT(dt.sampled_balanced)
dt.sampled_balanced$Filename_liwc = paste(dt.sampled_balanced$new_id_runner, '.txt', sep="")
dt.data_liwc = merge(dt.sampled_balanced, liwc, by.x = 'Filename_liwc', by.y = 'Filename')

# save(dt.data_liwc
#      , file='../eurocss_ltta_workshop_data_LIWC.RData')

dt.data_liwc_notext = dt.data_liwc[, -3]
# save(dt.data_liwc_notext
#      , file='../eurocss_ltta_workshop_data_LIWC_NOTEXT.RData')

###END