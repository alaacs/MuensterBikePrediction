"# MuensterBikePrediction"

Using Muenster City bike counter data publicly available [here](https://www.stadt-muenster.de/verkehrsplanung/verkehr-in-zahlen/radverkehrszaehlungen.html).

Analysis was executed on the CSV files available on Stadt Muenster website to Predict the number of bikes that can pass by certain points around the city where there exist the bike counter poles.

* First the data were cleaned and preprocessed using R. R code files are included in BikeMunServer/preprocessing folder
* Random Forest data mining prediction models were created using Python the models were created taking into consideration different parameters including:
  * Hour of day
  * Day of week
  * Weekday/Weekend
  * Holiday
  * Season
  * Temperature
  * Wind
  * Precipitation

 >The models are not included in the repository because they are high in size, however, the models can be recreated using the model.py file available in BikeMunServer folder.
* Python server code was developed using [Flask Restful](https://flask-restful.readthedocs.io/) which handles the incoming http requests from the web client and in turn executes the models for prediction and return the number of bikes for the desired station
* A web application was created to predict the number of bikes for each station around the city of Muenster, doing HTTP request to the restful flask python application passing the parameters for the model and visualize the number of bikes on a [leaflet map](https://leafletjs.com/)

The team worked on this project:
* [Alaa B. Abdelfattah](https://github.com/alaacs) - alaa.cs@hotmail.com
* Lorena Abad - lore.abad6@gmail.com
* Luuk van der Meer - luukvandermeertx@gmail.com

Please contact us for further information or if you have difficulties to install the application.
