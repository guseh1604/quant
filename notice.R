library(lubridate)
library(stringr)
library(jsonlite)

# 최근 7일 전체 공시
getNoticeAll = function() {
  dart_api = Sys.getenv("dart_api_key")
  bgn_date = (Sys.Date() - days(7)) %>% str_remove_all('-')
  end_date = (Sys.Date() ) %>% str_remove_all('-')
  print(bgn_date)
  print(end_date)
  notice_url = paste0('https://opendart.fss.or.kr/api/list.json?crtfc_key=',dart_api,'&bgn_de=',
                      bgn_date,'&end_de=',end_date,'&page_no=1&page_count=100')
  
  notice_data = fromJSON(notice_url) 
  notice_data = notice_data[['list']]
  
  head(notice_data)
  print(notice_data)
  print("complete")
}

main = function() {
  getNoticeAll()
}

main()