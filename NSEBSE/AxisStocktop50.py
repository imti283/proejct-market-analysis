import pandas as ps
import csv
import os

NewFile = 'C:\\Users\\imtiyaz.alam\\PycharmProjects\\Practice\\Stock50\\updateNew.csv'
OldFile = 'C:\\Users\\imtiyaz.alam\\PycharmProjects\\Practice\\Stock50\\updateOld.csv'
'''
dfs = ps.read_html('https://www.stockaxis.com/top50-stock', header=0)
df = ps.DataFrame(dfs)
outFile = open('C:\\Users\\imtiyaz.alam\\PycharmProjects\\Practice\\Stock50\\updateNew.csv', 'w')
for df in dfs:
    dfNew = df['Company Name']
    dfNew.to_csv(outFile, sep=' ', encoding='utf-8')
'''
def CompareFile( NewFile,OldFile,str ):
    with open(OldFile, 'r') as t1, open(NewFile, 'r') as t2:
        fileone = t1.readlines()
        filetwo = t2.readlines()

    with open('C:\\Users\\imtiyaz.alam\\PycharmProjects\\Practice\\Stock50\\update.csv', 'a') as outFile:
        outFile.write(str)
        for line in filetwo:
            if line not in fileone:
                #if outFile.closed:
                    outFile.write(line)

CompareFile(NewFile,OldFile,"Whats In \n")
CompareFile(OldFile,NewFile, "Whats Out \n")
#os.close('update.csv')
os.remove('C:\\Users\\imtiyaz.alam\\PycharmProjects\\Practice\\Stock50\\updateOld.csv')
os.rename('updateNew.csv','updateOld.csv')