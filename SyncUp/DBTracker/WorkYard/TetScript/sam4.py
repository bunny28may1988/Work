import os 
import glob
import pandas as pd
sourceFiles=glob.glob('Final*.csv')
print(sourceFiles)
df_sample1 = pd.read_csv("Final-SQ-CREATE.csv")
#print(df_sample1)
df_sample2 = pd.read_csv("Final-SQ-\\EXEC.csv")
#print(df_sample2)
list = ["PipelineReleaseID","ReleasePipelineName","ReleaseDate","ProjectName","Summary","ChangeTicket","RowsUpdated","SQLStatement"]
df_master = df_sample1.merge(df_sample2)
print(df_master)