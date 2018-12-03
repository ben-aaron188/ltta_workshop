# ---
# title: "Feature extraction 1: LIWC"
# subtitle: "EuroCSS workshop: LTTA"
# subtitle: media data
# output: html_notebook
# author:  B Kleinberg https://github.com/ben-aaron188
# ---

rm(list = ls())

## load data
setwd('/Users/bennettkleinberg/Dropbox/workshop_eurocss/hackathon_data/main_data')
load('eurocss_media_data_sampled.RData')

## load deps
require(data.table)

## set id
dt.sampled_balanced$new_id_runner = 1:nrow(dt.sampled_balanced)

## write files
setwd('./individual_files/mediadata')
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
setwd('../liwc_output')
liwc = fread('mediadata.txt', header=T)

## merge
setDT(dt.sampled_balanced)
dt.sampled_balanced$Filename_liwc = paste(dt.sampled_balanced$new_id_runner, '.txt', sep="")
dt.data_liwc = merge(dt.sampled_balanced, liwc, by.x = 'Filename_liwc', by.y = 'Filename')

dt.data_liwc = dt.data_liwc[, -3]
save(dt.data_liwc
     , file='/Users/bennettkleinberg/Dropbox/workshop_eurocss/hackathon_data/features/eurocss_mediadata_liwc.RData')

###END