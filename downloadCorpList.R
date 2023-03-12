library(httr)
library(rvest)
library(xml2)

downloadCorpList = function() {
  dart_api = Sys.getenv("dart_api_key")
  
  codezip_url = paste0(
    'https://opendart.fss.or.kr/api/corpCode.xml?crtfc_key=',dart_api)
  
  codezip_data = GET(codezip_url)
  
  tf = tempfile(fileext = '.zip')
  
  writeBin(
    content(codezip_data, as = "raw"),
    file.path(tf)
  )
  
  nm = unzip(tf, list = TRUE)
  
  code_data = read_xml(unzip(tf, nm$Name))
  
  corp_code = code_data %>% html_nodes('corp_code') %>% html_text()
  corp_name = code_data %>% html_nodes('corp_name') %>% html_text()
  corp_stock = code_data %>% html_nodes('stock_code') %>% html_text()
  
  corp_list = data.frame(
    'code' = corp_code,
    'name' = corp_name,
    'stock' = corp_stock,
    stringsAsFactors = FALSE
  )
  
  corp_list = corp_list[corp_list$stock != " ", ]
  
  write.csv(corp_list, 'data/corp_list.csv') 
}

main = function() {
  downloadCorpList()
}

main()