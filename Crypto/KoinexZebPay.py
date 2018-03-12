from __future__ import division
import requests
import urllib.request
import urllib.parse

finalmes = ''


def StoreMessage(Mesg):
    global finalmes
    finalmes = str(Mesg) + "\n" + str(finalmes)


def sendSMS(apikey, group_id, message):
    data = urllib.parse.urlencode({'apikey': apikey, 'group_id': group_id,
                                   'message': message})
    data = data.encode('utf-8')
    request = urllib.request.Request("https://api.textlocal.in/send/?")
    f = urllib.request.urlopen(request, data)
    fr = f.read()
    return (fr)


def ZebpayToKoinex(koin, zebpaybuy, koinexsell):
    percentageDiff = float(((koinexsell - zebpaybuy) / zebpaybuy) * 100)
    # print("There is an Opprt from Zebpay to Koinex for Crypt: " + koin + " For a percentage of " "%4.2f" %percentageDiff)
    Mesg = str("Z2K-" + koin + "-->%4.2f" % percentageDiff)
    StoreMessage(Mesg)


def KoinexToZebpay(koin, zebpaysell, koinexbuy):
    percentageDiff = float(((zebpaysell - koinexbuy) / koinexbuy) * 100)
    # print("There is an Opprt from Koinex to Zebpay for Crypt: " + koin + " For a percentage of " "%4.2f" %percentageDiff1)
    Mesg = str("K2Z-" + koin + "-->%4.2f" % percentageDiff)
    StoreMessage(Mesg)


rk = requests.get("https://koinex.in/api/ticker").json()
for item in rk:
    for item1 in ('BTC', 'XRP', 'LTC', 'BCH', 'ETH', 'OMG', 'REQ', 'GNT', 'AE', 'ZRX', 'BAT'):
        if (item == 'prices'):
            KoinexAlt = float(rk[item][item1])
            print("Koinex " + item1, rk[item][item1])
            rz = requests.get("https://www.zebapi.com/api/v1/market/ticker-new/" + item1 + "/inr").json()
            try:
                ZebpayAltBuy = float(rz['buy'])
                ZebpayAltSell = float(rz['sell'])
                print("Zebpay " + rz['virtualCurrency'].upper(), rz['buy'], rz['sell'])
                if (KoinexAlt > ZebpayAltBuy):
                    ZebpayToKoinex(item1, ZebpayAltBuy, KoinexAlt)
                elif (ZebpayAltSell > KoinexAlt):
                    KoinexToZebpay(item1, ZebpayAltSell, KoinexAlt)
            except:
                pass


print(finalmes)
# resp = sendSMS('ruEbUk/ke5E-JSJpReoDwxQJTHA3KkKcPy7QNTPxgP', '807590', finalmes)
# print(resp)
