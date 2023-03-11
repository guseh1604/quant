pkg = c('magrittr', 'quantmod', 'rvest', 'httr', 'jsonlite',
        'readr', 'readxl', 'stringr', 'lubridate', 'dplyr',
        'tidyr', 'ggplot2', 'corrplot', 'dygraphs',
        'highcharter', 'plotly', 'PerformanceAnalytics',
        'nloptr', 'quadprog', 'RiskPortfolios', 'cccp',
        'timetk', 'broom', 'stargazer', 'timeSeries')
print("package list")
print(pkg)

new.pkg = pkg[!(pkg %in% installed.packages()[, "Package"])]

print("new package list")
print(new.pkg)

if (length(new.pkg)) {
  install.packages(new.pkg, dependencies = TRUE)
}

print("complete")