library(httr)
library(rvest)
library(readr)
library(stringr)
library(jsonlite)

downloadSector = function(mktId, trdDd) {
  #OTP 발급
  gen_otp_url =
    'http://data.krx.co.kr/comm/fileDn/GenerateOTP/generate.cmd'
  gen_otp_data = list(
    mktId = mktId,
    trdDd = trdDd,
    money = '1',
    csvxls_isNo = 'false',
    name = 'fileDown',
    url = 'dbms/MDC/STAT/standard/MDCSTAT03901'
  )
  otp = POST(gen_otp_url, query = gen_otp_data) %>%
    read_html() %>%
    html_text()
  
  # 업종분류 데이터 다운로드
  down_url = 'http://data.krx.co.kr/comm/fileDn/download_csv/download.cmd'
  down_sector = POST(down_url, query = list(code = otp), add_headers(referer = gen_otp_url)) %>%
    read_html(encoding = 'EUC-KR') %>%
    html_text() %>%
    read_csv()
  return (down_sector)
}

downloadSectorAll = function(trdDd) {
  kosdaq = "KSQ"
  kospi = "STK"
  
  down_sector_KQ = downloadSector(kosdaq, trdDd)
  down_sector_KS = downloadSector(kospi, trdDd)
  
  down_sector = rbind(down_sector_KQ, down_sector_KS)
  
  ifelse(dir.exists('data'), FALSE, dir.create('data'))
  write.csv(down_sector, 'data/krx_sector.csv')
  return (down_sector)
}

downloadInd = function(trdDd) {
  #OTP 발급
  gen_otp_url =
    'http://data.krx.co.kr/comm/fileDn/GenerateOTP/generate.cmd'
  gen_otp_data = list(
    searchType = '1',
    mktId = 'ALL',
    trdDd = trdDd,
    csvxls_isNo = 'false',
    name = 'fileDown',
    url = 'dbms/MDC/STAT/standard/MDCSTAT03501'
  )
  otp = POST(gen_otp_url, query = gen_otp_data) %>%
    read_html() %>%
    html_text()
  
  # 개별종목 지표 데이터 다운로드
  down_url = 'http://data.krx.co.kr/comm/fileDn/download_csv/download.cmd'
  down_ind = POST(down_url, query = list(code = otp), add_headers(referer = gen_otp_url)) %>%
    read_html(encoding = 'EUC-KR') %>%
    html_text() %>%
    read_csv()
  
  write.csv(down_ind, 'data/krx_ind.csv')
  
  return (down_ind)
}

getBizDay = function() {
  url = 'https://finance.naver.com/sise/sise_deposit.nhn'
  
  biz_day = GET(url) %>%
    read_html(encoding = 'EUC-KR') %>%
    html_nodes(xpath = '//*[@id="type_1"]/div/ul[2]/li/span') %>%
    html_text() %>%
    str_match(('[0-9]+.[0-9]+.[0-9]+') ) %>%
    str_replace_all('\\.', '')
  
  return (biz_day)
}

tidyData = function() {
  # row.names = 1 첫번째 열을 행 이름으로 지정.
  # stringsAsFactors 문자열 데이터가 팩터 형태로 변형되지 않게
  down_sector = read.csv('data/krx_sector.csv', row.names = 1, stringsAsFactors = FALSE)
  down_ind = read.csv('data/krx_ind.csv',  row.names = 1, stringsAsFactors = FALSE)
  
  # 
  KOR_ticker = merge(down_sector, down_ind, by = intersect(names(down_sector), names(down_ind)), all = FALSE)
  # 시가총액 기준 내림차순 정렬
  KOR_ticker = KOR_ticker[order(-KOR_ticker$'시가총액'), ]
  
  # 스펙, 우선주 종목 제외
  KOR_ticker = KOR_ticker[!grepl('스팩', KOR_ticker[, '종목명']), ]
  KOR_ticker = KOR_ticker[str_sub(KOR_ticker[, '종목코드'], -1, -1) == 0, ]
  
  rownames(KOR_ticker) = NULL
  write.csv(KOR_ticker, 'data/KOR_ticker.csv')
  
  return (KOR_ticker)
}

downloadWICS = function(biz_day) {
  sector_code = c('G25', 'G35', 'G50', 'G40', 'G10',
                  'G20', 'G55', 'G30', 'G15', 'G45')
  
  data_sector = list()
  
  for (i in sector_code) {
    
    url = paste0(
      'http://www.wiseindex.com/Index/GetIndexComponets',
      '?ceil_yn=0&dt=',biz_day,'&sec_cd=',i)
    data = fromJSON(url)
    data = data$list
    
    data_sector[[i]] = data
    
    print(paste0('sector : ', i, ' complete'))
    Sys.sleep(1)
  }
  
  data_sector = do.call(rbind, data_sector)
  
  write.csv(data_sector, 'data/KOR_sector.csv')
  
  print('KOR_sector complete')
  return (data_sector)
}

main = function() {
  # 최근 영업일 구하기
  biz_day = getBizDay()
  
  # 코스피, 코스닥 업종분류 데이터 다운로드
  down_sector = downloadSectorAll(biz_day);
  
  # 개별종목 지표 데이터 다운로드
  down_ind = downloadInd(biz_day)
  
  # 데이터 정리
  KOR_ticker = tidyData()
  
  # WICS 기준 섹터정보 다운로드
  data_sector = downloadWICS(biz_day)
}

main()