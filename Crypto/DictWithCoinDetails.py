from collections import defaultdict,Counter
import json

#d[a][b][c] = {}
d=''

def CreateDataSet(koin,order,key,value):
    global d
    d = defaultdict(lambda: defaultdict(dict))
    d[koin][order][key] = value
    print(json.dumps(d))

CreateDataSet('BTC','Buy','BTZeB',76000)
CreateDataSet('LTC','Buy','LTZeB',6000)
#print(d)