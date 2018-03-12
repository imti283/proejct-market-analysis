import urllib3
from bs4 import BeautifulSoup
import json
import http
import requests
urllib3.disable_warnings()

http = urllib3.PoolManager()
# new url
url = 'https://www.stockaxis.com/top50-stock'

# read all data
page = http.request('GET', url)

# convert json text to python dictionary
#data1 = page.read().decode('utf-8')
obj = json.loads((page).read())
print(obj)