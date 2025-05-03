import sys
import pandas as pd
df = pd.read_csv("Final-SQ-CREATE.txt", header = None)
#df.columns = ['PipelineReleaseID', 'ReleasePipelineName', 'ReleaseDate', 'ProjectName', 'Summary', 'ChangeTicket', 'RowsUpdated', 'SQLStatement', 'TimeStamp']
df.to_csv('log.csv',index = None)
'''
import pandas
txtFile="test-gen.txt"
outCsv="out.log"
in_txt=csv.reader
'''