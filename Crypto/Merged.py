try:
    from collections import defaultdict
    import re
    import requests
    import json
except:
    print("FailTest1")

d = defaultdict(lambda: defaultdict(dict))


def CreateDataSet(koin, order, key, value):
    d[koin][order][key] = value


rc = requests.get("https://coindelta.com/api/v1/public/getticker/").json()

for item in rc:
    if (re.match('[a-z]*-inr', item['MarketName'])):
        # print(item['MarketName'])
        x = item['MarketName'][:3].upper()
        for k in item:
            if k == 'Ask':
                pushkey = str(x + "CDS")
                # print(item['MarketName'])
                CreateDataSet(x, 'Sell', pushkey, item['Ask'])
            elif k == 'Bid':
                pushkey = str(x + "CDB")
                CreateDataSet(x, 'Buy', pushkey, item['Bid'])

rk = requests.get("https://koinex.in/api/ticker").json()

for item in rk:
    if (item == 'stats'):
        for item1 in ('BTC', 'XRP', 'LTC', 'BCH', 'ETH', 'OMG', 'REQ'):
            for k in rk[item][item1]:
                if (k == 'lowest_ask'):
                    pushkey = str(item1 + "KoS")
                    # print(item1,pushkey,rk[item][item1]['lowest_ask'])
                    CreateDataSet(item1, 'Sell', pushkey, rk[item][item1]['lowest_ask'])
                elif (k == 'highest_bid'):
                    pushkey = str(item1 + "KoB")
                    # print(item1,pushkey, rk[item][item1]['highest_bid'])
                    CreateDataSet(item1, 'Buy', pushkey, rk[item][item1]['highest_bid'])

for item1 in ('BTC', 'XRP', 'LTC', 'BCH', 'ETH'):
    rz = requests.get("https://www.zebapi.com/api/v1/market/ticker-new/" + item1 + "/inr").json()
    ZebpayAltBuy = float(rz['buy'])
    ZebpayAltSell = float(rz['sell'])
    # print("Zebpay " + rz['virtualCurrency'].upper(), rz['buy'], rz['sell'])
    pushkeybuy = str(item1 + "ZeB")
    pushkeysell = str(item1 + "ZeS")
    CreateDataSet(item1, 'Buy', pushkeybuy, rz['buy'])
    CreateDataSet(item1, 'Sell', pushkeysell, rz['buy'])

print(json.dumps(d, indent=2))
# print(max(d.items(), key=operator.itemgetter(1))[0])
