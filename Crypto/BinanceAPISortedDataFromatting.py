import requests
import json
import urllib3
import re
r = requests.get("https://api.binance.com//api/v1/ticker/24hr").json()
#print(r)
for item in r:
    if(re.match('[A-Z]*BTC',item['symbol'])):
        UsdtPrice = float(item['bidPrice'])
        print(item['symbol'],"%4.2f" % (float(item['askPrice'])* float(UsdtPrice)),"%7.4f" % (float(item['bidPrice']) * float(UsdtPrice)))