import pandas as ps
import csv
import os
import re

patt = '(([A-Z]*)(\s){2})|(([A-Z]*)(\s){2})'
dfs = ps.read_html('https://coinmarketcap.com/', index_col = False)
df = ps.DataFrame(dfs)
#print(dfs)
#outFile = open('C:\\Users\\imtiyaz.alam\\PycharmProjects\\Practice\\Stock50\\CoinMarket.csv', 'w')
for df in dfs:
    dfNew = df['Name']
    print(dfNew)
    #dfNew.to_csv(outFile, sep=' ', encoding='utf-8')
    #dfNewmod = re.sub(patt, '', dfNew)
    #print(dfNewmod)

