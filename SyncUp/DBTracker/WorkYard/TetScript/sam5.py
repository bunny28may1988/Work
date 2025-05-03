import csv
rows=[]
with open("test-gen.csv",'r') as file:
    csvreader= csv.reader(file)
    header=next(csvreader)
    for row in csvreader:
        rows.append(row)
print(header)
print(rows)