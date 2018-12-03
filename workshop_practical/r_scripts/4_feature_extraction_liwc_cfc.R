# ---
# title: "Feature extraction 1: LIWC"
# subtitle: "EuroCSS workshop: LTTA"
# subtitle: creators for change data
# output: html_notebook
# author:  B Kleinberg https://github.com/ben-aaron188
# ---

rm(list = ls())

## load data
setwd('/Users/bennettkleinberg/Dropbox/workshop_eurocss/hackathon_data/main_data')
load('eurocss_cfc_data_full.RData')

## load deps
require(data.table)

## set id
dt.data$new_id_runner = 1:nrow(dt.data)

## write files
setwd('./individual_files/cfc')
lapply(seq(nrow(dt.data)), function(i){
  write.table(dt.data$text[i],
              file = paste(dt.data$new_id_runner[i]
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
liwc = fread('cfc.txt', header=T)

## merge
setDT(dt.data)
dt.data$Filename_liwc = paste(dt.data$new_id_runner, '.txt', sep="")
dt.data_liwc = merge(dt.data, liwc, by.x = 'Filename_liwc', by.y = 'Filename')

dt.data_liwc = dt.data_liwc[, -3]
save(dt.data_liwc
     , file='/Users/bennettkleinberg/Dropbox/workshop_eurocss/hackathon_data/features/eurocss_cfc_liwc.RData')

###END