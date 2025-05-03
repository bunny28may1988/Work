import glob
import pandas as pd
sourceFiles=glob.glob('*.csv')
'''
dataframes=[]
for file in sourceFiles:
    df = pd.read_csv(file)
    dataframes.append(df)
df =pd.concat(dataframes,axis=1)   
print(df) >lloog.csv
'''
def csvToDf(file):
    df = pd.read_csv(file)
    return df
df = pd.concat([csvToDf(files) for files in sourceFiles], axis=1)
df_all = df.loc[:,~df.columns.duplicated()]