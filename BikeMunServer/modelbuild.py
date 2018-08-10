from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.externals import joblib
from math import sqrt
import pandas as pd
import os

# Set working directory
wd = r'C:\Users\meer\Documents\Master GeoTech\Block Course\Final Project'

# Define function to build the models
def buildmodel(inputfile, output_model, output_results):
	## --------------------- DATA --------------------------
	# Import the preprocessed data
	path = os.path.join(wd, 'Data', inputfile)
	data = pd.read_csv(path)	

	## -------------- PARAMETER TESTING --------------------
	# Create a training and test set
	train = data.sample(frac = 0.7)
	test = data.drop(train.index)	

	# Define the values to be tested for
	values = [10, 20, 40, 60, 80, 100, 150, 200, 250, 300, 400, 500, 750, 1000]	

	# Create an empty list to store the rmse values in
	rmse_list = []	

	# Build a Random Forest Regression model with each of the values
	# Predict the test set with the model and calculate the rmse
	# Store the rmse in the rmse_list
	for x in values:
		model = RandomForestRegressor(n_estimators = x)
		model.fit(train.iloc[:,2:], train.iloc[:,1])	

		rmse = sqrt(mean_squared_error(test.iloc[:,1], model.predict(test.iloc[:,2:])))	

		rmse_list.append(rmse)	

	# Select the value that leads to the lowest error
	min_index = rmse_list.index(min(rmse_list))
	ntrees = values[min_index]	

	## ------------------ FINAL MODEL -----------------------
	# Create a new training and test set
	train = data.sample(frac = 0.7)
	test = data.drop(train.index)	

	# Run the model and predict
	model = RandomForestRegressor(n_estimators = ntrees)
	model.fit(train.iloc[:,2:], train.iloc[:,1])
	prediction = model.predict(test.iloc[:,2:])	

	# Calculate evaluation measures
	mae = mean_absolute_error(test.iloc[:,1], prediction)
	rmse = sqrt(mean_squared_error(test.iloc[:,1], prediction))
	rsquared = r2_score(test.iloc[:,1], prediction)	

	# Calculate variable importance
	var = list(model.feature_importances_)	

	# Store results
	names = ['ntree', 'mae', 'rmse', 'rsquared', 'day', 'hour', 'weekday', 'holiday', 'season', 'temperature', 'wind', 'precipitation']
	values = [ntrees, mae, rmse, rsquared, var[0], var[1], var[2], var[3], var[4], var[5], var[6], var[7]]
	results = pd.DataFrame({'names': names, 'values': values})	

	# Save results
	path = os.path.join(wd, 'Models', output_results)
	results.to_csv(path, index = False)	

	# Save model
	path = os.path.join(wd, 'Models', output_model)
	joblib.dump(model, path)

	print(results)
	
# Run the function for each dataset
buildmodel(inputfile = 'id01w.csv', output_results = 'id01w_results.csv', output_model = 'id01w_model.pkl')
buildmodel(inputfile = 'id02w.csv', output_results = 'id02w_results.csv', output_model = 'id02w_model.pkl')
buildmodel(inputfile = 'id03w.csv', output_results = 'id03w_results.csv', output_model = 'id03w_model.pkl')
buildmodel(inputfile = 'id04w.csv', output_results = 'id04w_results.csv', output_model = 'id04w_model.pkl')
buildmodel(inputfile = 'id05w.csv', output_results = 'id05w_results.csv', output_model = 'id05w_model.pkl')
buildmodel(inputfile = 'id06w.csv', output_results = 'id06w_results.csv', output_model = 'id06w_model.pkl')
buildmodel(inputfile = 'id07w.csv', output_results = 'id07w_results.csv', output_model = 'id07w_model.pkl')
buildmodel(inputfile = 'id09w.csv', output_results = 'id09w_results.csv', output_model = 'id09w_model.pkl')

