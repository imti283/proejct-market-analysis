from collections import defaultdict, Counter
import json
from itertools import chain

d = ''
d1 = ''
d1 = defaultdict(lambda: defaultdict(dict))
d2 = defaultdict(lambda: defaultdict(dict))


def CreateDataSet(koin, order, key, value):
    global d, d1, d2
    d = defaultdict(lambda: defaultdict(dict))
    d[koin][order][key] = value
    #d1 = {**d, **d1}
    d1 = dict(chain(d.items(), d1.items()))

CreateDataSet('BTC', 'Buy', 'BTZeB', 76000)
CreateDataSet('LTC', 'Buy', 'LTZeB', 6000)
CreateDataSet('OMG', 'Buy', 'OGDeB', 9000)
CreateDataSet('OMG', 'KoBuy', 'OGKoB', 9000)
print(json.dumps(d1))
