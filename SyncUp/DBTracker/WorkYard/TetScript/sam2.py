import re
import os 
from os import system
import glob
import pandas as pd

for f in glob.glob("Final*"):
      print(f'Removing the File:', f)
      os.remove(f)


print("############")
system(' bash DBTracker.sh')
print("############")
           

sourceFiles=glob.glob('Final*.txt')
for files in sourceFiles:
    tFile=files.strip('.txt')
    ext='.csv'
    GeneratedCsv=tFile+ext
    print(GeneratedCsv)
    print(f'{files} converted as {tFile}')
    with open(files,'r') as reader:
        text = reader.read()
        text = re.sub(r"(...)\n", r"\1,", text)
        #print(text)
    with open(GeneratedCsv, 'w') as writer:
      writer.write(text)
csv_Files=glob.glob('Final*.csv')
df_concat = pd.concat([pd.read_csv(f) for f in csv_Files ], ignore_index=True)
print(df_concat)
'''
df_append = pd.DataFrame()
for file in csv_Files:
            df_temp = pd.read_csv(file)
            df_append = df_append.append(df_temp, ignore_index=True)
df_append
'''
'''        
with open('files', 'r') as reader:
  text = reader.read()
  text = re.sub(r"(...)\n", r"\1,", text)
  print(text)
with open('{tFile}.csv', 'w') as writer:
 writer.write(text)
'''
