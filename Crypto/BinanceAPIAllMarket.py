from __future__ import division
import requests
import json
import urllib3
import re

r = requests.get("https://api.binance.com/api/v1/ticker/price").json()


# data1 =r.content.decode('utf-8')
# print(r)

def BtcBasePrice():
    for item2 in r:
        # print(item2['symbol'])
        if (item2['symbol'] == 'ETHBTC'):
            # print(item2['price'])
            return item2['price']


def BnbBasePrice():
    for item3 in r:
        # print(item2['symbol'])
        if (item3['symbol'] == 'BNBBTC'):
            # print(item2['price'])
            return item3['price']



def findCoinPrice(Coin):
    global PriceBnb
    global HighPrice
    global MinPrice
    global PriceBtc
    global PriceEth
    res = Coin + "*"
    # print(res)
    for item1 in r:
        if (re.match(res, item1['symbol'])):
            if (item1['symbol'] == Coin + 'BTC'):
                # print(re.sub('[A-Z]*BTC', item['symbol']))
                PriceBtc = item1['price']
                print("Price of "+item1['symbol'],"in Actual BTC: " +item1['price'])
            # print(item1['price'])
            elif (item1['symbol'] == Coin + 'ETH'):
                # print(float(BtcBasePrice()))
                data = float(BtcBasePrice()) * float(item1['price'])
                PriceEth = data
                print("Price of "+item1['symbol'],"in BTC Base for ETH: " '%10.8f' % data)
            elif (item1['symbol'] == Coin + 'BNB'):
                # print(float(BtcBasePrice()))
                data1 = float(BnbBasePrice()) * float(item1['price'])
                PriceBnb = data1
                print("Price Of "+item1['symbol'],"in BTC bace for BNB: " '%10.8f' % data1)
            else:
                continue


   # print("PriceBTC " '%10.8f' %PriceBtc)
    #print("PriceETH " '%10.8f' %PriceEth)

for item in r:
    if (re.match('[A-Z]*ETH', item['symbol'])):
        d = item['symbol']
        d1 = re.findall('^[A-Z]{3}', item['symbol'])
        # print(d1[0])
        findCoinPrice(d1[0])

if (PriceBtc < PriceEth):
    percentageDiff = float(((PriceEth - PriceBtc) / PriceBtc) * 100)
else:
    percentageDiff = float(((PriceBtc - PriceEth) / PriceEth) * 100)
print(percentageDiff)
