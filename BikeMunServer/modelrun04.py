from sklearn.ensemble import RandomForestRegressor
from sklearn.externals import joblib
import pandas as pd
import os

# Set working directory
wd = r'C:\Users\meer\Documents\Master GeoTech\Block Course\Final Project'

# Load the input data
dayoftheweek = [6]
houroftheday = [11]
weekday = [0]
holiday = [1]
season = [3]
temperature = [20]
wind = [10]
precipitation = [2]

data = pd.DataFrame({
	'day': dayoftheweek,
	'hour': houroftheday,
	'weekday': weekday,
	'holiday': holiday,
	'season': season,
	'temp': temperature,
	'wind': wind,
	'prec': precipitation
	})

# Load the model
path = os.path.join(wd, 'Models', 'id04w_model.pkl')
model = joblib.load(path)

# Predcit
prediction = model.predict(data)

# Print
print(prediction)