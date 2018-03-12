from collections import defaultdict
import re
import requests
import json

d = defaultdict(lambda: defaultdict(dict))


def CreateDataSet(koin, order, key, value):
    d[koin][order][key] = value


for item1 in ('BTC', 'XRP', 'LTC', 'BCH', 'ETH'):
    rz = requests.get("https://www.zebapi.com/api/v1/market/ticker-new/" + item1 + "/inr").json()
    ZebpayAltBuy = float(rz['buy'])
    ZebpayAltSell = float(rz['sell'])
    #print("Zebpay " + rz['virtualCurrency'].upper(), rz['buy'], rz['sell'])
    pushkeybuy = str(item1 + "ZeB")
    pushkeysell = str(item1 + "ZeS")
    CreateDataSet(item1, 'Buy', pushkeybuy, rz['buy'])
    CreateDataSet(item1, 'Sell', pushkeysell, rz['buy'])

print(json.dumps(d, indent=4))
