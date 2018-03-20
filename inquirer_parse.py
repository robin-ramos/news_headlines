import requests
import pandas as pd
import datetime as dt
import time
from bs4 import BeautifulSoup as bs4
import re

request_headers = {"User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"}
link = "http://www.inquirer.net/article-index?d="
headline_list = [] #table date,year,headline,link
years = [2017]
for y in range(len(years)):
    for d in range(1,365):
        x = str((dt.datetime.strptime(str(d) + "-" + str(years[y]), "%j-%Y")).date())
        r = requests.get("http://www.inquirer.net/article-index?d=" + x, headers=request_headers)
        soup = bs4(r.text, 'lxml')
        for a in soup.find('div', id='all-index-wrap').find_all('a', href=re.compile("http://business.inquirer.net")):
            headlines = {}
            headlines.update({'date':x,'year':years[y], 'link':a['href'], 'headline':a['title']})
            headline_list.append(headlines)
        print(d)
    print(years[y])

df = pd.DataFrame(data=headline_list)
df.to_csv("inquirer_headlines2017.csv")         