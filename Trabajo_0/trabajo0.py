import pandas as pd

data = pd.read_csv('UCS-Satellite-Database-1-1-2021.csv', encoding = "ISO-8859-1",usecols= ['Name of Satellite, Alternate Names','Launch Mass (kg.)','Dry Mass (kg.)'])

print(data)
