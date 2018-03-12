from collections import defaultdict
import re
import requests
import json

d = defaultdict(lambda: defaultdict(dict))

def CreateDataSet(koin, order, key, value):
    d[koin][order][key] = value


rk = requests.get("https://coindelta.com/api/v1/public/getticker/").json()

for item in rk:
    if (re.match('[a-z]*-inr', item['MarketName'])):
        # print(item['MarketName'])
        x = item['MarketName'][:3].upper()
        for k in item:
            if (k == 'Ask'):
                pushkey = str(x + "CDS")
                # print(item['MarketName'])
                CreateDataSet(x, 'Sell', pushkey, item['Ask'])
            elif (k == 'Bid'):
                pushkey = str(x + "CDB")
                CreateDataSet(x, 'Buy', pushkey, item['Bid'])
print(json.dumps(d, indent=4))
