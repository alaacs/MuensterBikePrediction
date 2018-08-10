from flask import Flask
from flask_restful import Resource, Api
from flask_restful import reqparse
from sklearn.ensemble import RandomForestRegressor
from sklearn.externals import joblib
import pandas as pd
import json

app = Flask(__name__)
api = Api(app)

class BikeController(Resource):
    def get(self):
      parser = reqparse.RequestParser()
      parser.add_argument('station_id', type=int, help='')
      parser.add_argument('season', type=int, help='')
      parser.add_argument('day_of_week', type=int, help='')
      parser.add_argument('is_holiday', type=bool, help='')
      parser.add_argument('is_weekday', type=bool, help='')
      parser.add_argument('hour', type=int, help='')
      parser.add_argument('temperature', type=float, help='')
      parser.add_argument('wind', type=float, help='')
      parser.add_argument('precipitation', type=float, help='')
      args = parser.parse_args()
      dayoftheweek = [int(args.day_of_week)]
      houroftheday = [int(args.hour)]
      weekday = [[1,0][args.is_weekday == "true"]]
      holiday = [[1,0][args.is_holiday == "true"]]
      season = [int(args.season)]
      temperature = [float(args.temperature)]
      wind = [float(args.wind)]
      precipitation = [float(args.precipitation)]
      
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
      path = f'id0{args.station_id}w_model.pkl'
      model = joblib.load(path)

      # Predcit
      prediction = model.predict(data)
      prediction = prediction.tolist()
      prediction = json.dumps(prediction, separators=(',',':'))
      return prediction

api.add_resource(BikeController, '/')

if __name__ == '__main__':
    app.run(debug=True)