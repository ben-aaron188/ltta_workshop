# ---
# title: "Feature extraction 1: ngrams
# subtitle: "EuroCSS workshop: LTTA"
# subtitle: dataset preprocessing: creators for change data
# output: html_notebook
# author:  B Kleinberg https://github.com/ben-aaron188
# ---

rm(list = ls())

## load data
setwd('/Users/bennettkleinberg/Dropbox/workshop_eurocss/hackathon_data/main_data')
load('eurocss_cfc_data_full.RData')

## load deps
require(quanteda)

# feature extraction: ngrams
## set identifier
dt.data[, doc_id := paste('text', 1:.N, sep="")]

## set sparsity
param_sparsity = .95

ngrams_1 = dfm(x = dt.data$text
               , ngrams = 1
               , verbose = T
               , remove_punct = T
               , remove = stopwords("english")
               , stem = F
)

ngrams_2 = dfm(x = dt.data$text
               , ngrams = 2
               , verbose = T
               , remove_punct = T
               , remove = stopwords("english")
               , stem = F
)

ngrams_3 = dfm(x = dt.data$text
               , ngrams = 3
               , verbose = T
               , remove_punct = T
               , remove = stopwords("english")
               , stem = F
)


ngrams_2[1:10, 1:10]

ngrams_1_trimmed = dfm_trim(ngrams_1, sparsity = param_sparsity)
ngrams_2_trimmed = dfm_trim(ngrams_2, sparsity = param_sparsity)
ngrams_3_trimmed = dfm_trim(ngrams_3, sparsity = param_sparsity)

tfidf_ngrams_1 = dfm_tfidf(ngrams_1_trimmed)
tfidf_ngrams_2 = dfm_tfidf(ngrams_2_trimmed)
tfidf_ngrams_3 = dfm_tfidf(ngrams_3_trimmed)

#rm(ngrams_3)

df.tfidf_ngrams_1 = as.data.frame(tfidf_ngrams_1)
df.tfidf_ngrams_2 = as.data.frame(tfidf_ngrams_2)
df.tfidf_ngrams_3 = as.data.frame(tfidf_ngrams_3)

dt.data_min = dt.data[, -2]

df.tfidf_ngrams_1 = merge(dt.data_min, df.tfidf_ngrams_1
                          , by.x='doc_id'
                          , by.y='document')
df.tfidf_ngrams_2 = merge(dt.data_min, df.tfidf_ngrams_2
                          , by.x='doc_id'
                          , by.y='document')
df.tfidf_ngrams_3 = merge(dt.data_min, df.tfidf_ngrams_3
                          , by.x='doc_id'
                          , by.y='document')

save(df.tfidf_ngrams_1
     , file='../features/eurocss_cfc_data_unigrams.RData')
save(df.tfidf_ngrams_2
     , file='../features/eurocss_cfc_data_bigrams.RData')
save(df.tfidf_ngrams_3
     , file='../features/eurocss_cfc_data_trigrams.RData')

###END