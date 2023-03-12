library(stringr)
library(xts)
library(magrittr)
library(dplyr)

cleanUpPrice = function() {
  KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1)
  KOR_ticker$'종목코드' =
    str_pad(KOR_ticker$'종목코드', 6, side = c('left'), pad = '0')
  
  price_list = list()
  
  for (i in 1 : nrow(KOR_ticker)) {
    name = KOR_ticker[i, '종목코드']
    print(name)
    
    price_list[[i]] =
      read.csv(paste0('data/KOR_price/', name,
                      '_price.csv'),row.names = 1) %>%
      as.xts()
    
    print(paste0(name, " complete"))
  }
  
  price_list = do.call(cbind, price_list) %>% na.locf()
  colnames(price_list) = KOR_ticker$'종목코드'
  
  write.csv(data.frame(price_list), 'data/KOR_price.csv')
  print("complete all")
}

main = function() {
  cleanUpPrice()
}

main()