from collections import defaultdict
import re
import requests
import json

d = defaultdict(lambda: defaultdict(dict))

def CreateDataSet(koin, order, key, value):
    d[koin][order][key] = value


rk = requests.get("https://koinex.in/api/ticker").json()

for item in rk:
    if (item == 'stats'):
        for item1 in ('BTC', 'XRP', 'LTC', 'BCH', 'ETH' , 'OMG', 'REQ'):
            for k in rk[item][item1]:
                    if(k == 'lowest_ask'):
                        pushkey = str(item1 + "KoS")
                        #print(item1,pushkey,rk[item][item1]['lowest_ask'])
                        CreateDataSet(item1, 'Sell', pushkey, rk[item][item1]['lowest_ask'])
                    elif(k == 'highest_bid'):
                        pushkey = str(item1+"KoB")
                        #print(item1,pushkey, rk[item][item1]['highest_bid'])
                        CreateDataSet(item1,'Buy',pushkey, rk[item][item1]['highest_bid'])



print(json.dumps(d, indent=4))
