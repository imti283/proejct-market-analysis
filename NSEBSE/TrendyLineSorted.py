import urllib.parse
import urllib.request
import bs4 as bs
import pandas as ps
import collections

for i in range(1, 7):
    example_url = 'https://trendlyne.com/portfolio/superstar-shareholders/individual'
    form_values = {'page': i}
    example_data = urllib.parse.urlencode(form_values)
    final_url = example_url + '?' + example_data

    sauce = urllib.request.urlopen(final_url).read()
    soup = bs.BeautifulSoup(sauce,'html.parser')

    soup = soup.find("div", {"id": "allposts"})

    for url in soup.find_all('a'):
        urlvalue = url.get('href')
        if urlvalue is not None:
            if 'latest' in urlvalue:
                weburl = 'https://trendlyne.com'
                weburl += urlvalue

                try:
                    if not isinstance(weburl, type(None)):
                        dfs = ps.read_html(weburl)

                        for df in dfs:
                            if 'Change from Previous Qtr' in df:
                                df = df.set_index('Change from Previous Qtr')
                                if('NEW' in df.index):
                                    if 'Unnamed' not in df.loc['NEW']:
                                        #print(df.loc['NEW'])
                                        df = df.loc['NEW']
                                        count = len(df.axes[0])
                                        if(count == 9):
                                            print(df['Stock Name'], "||", df['Holders Name'])
                                        else:
                                            for index, row in df.iterrows():
                                                print(row['Stock Name'], "||", row['Holders Name'])


                except:
                    pass





