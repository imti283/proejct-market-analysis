import bs4 as bs
import urllib.request
import types

import pandas as ps

# sauce = urllib.request.urlopen('https://trendlyne.com/portfolio/superstar-shareholders/53757/latest/dolly-khanna-portfolio/').read()
#
# soup = bs.BeautifulSoup(sauce,'html.parser')
# #print (soup.get_text())
#
# table = soup.table;
#
# table_rows = table.find_all('tr')
#
# for tr in table_rows:
#     td = tr.find_all('td')
#     for i in td:
#         print (i.text)

#dfs = ps.read_html('https://trendlyne.com/portfolio/superstar-shareholders/53757/latest/dolly-khanna-portfolio/')
# dfs = ps.read_html('https://trendlyne.com/portfolio/superstar-shareholders/53802/latest/suresh-kumar-agarwal-portfolio/')
dfs = ps.read_html('https://trendlyne.com/portfolio/superstar-shareholders/53756/latest/dipak-kanayalal-shah-portfolio/')

for df in dfs:
    df = df.set_index('Change from Previous Qtr')
        # print(df.loc[df['Change from Previous Qtr'] == 'NEW'])
    df = df.loc['NEW']
    ps.set_option('display.width', 320)
    df.fillna(value=0, inplace=True)
    print(df)
    # count = len(df)
    # print(count)
    # for index, row in df.iterrows():
    #     print(row['Stock Name'], "||", row['Holders Name'])


