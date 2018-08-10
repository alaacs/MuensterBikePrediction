var bikemunpredapp = angular.module('bikemunpredapp', []);

bikemunpredapp.controller('BikeController', ['$scope','$http',function BikeController($scope,$http) {
  $scope.muensterLat = 51.9607
  $scope.muensterLong = 7.6261
  $scope.darkskyUrl =
    `https://api.darksky.net/forecast/e69d4b69b3569bcbce87cded65387ea7/51.9607,7.6261?units=si&exclude=currently,minutely,hourly,alerts,flags&lang=en`
  $scope.predictionServerUrl = `http://127.0.0.1:5000/`
  $scope.bikeStaions = [
  	{
  	  "id": 1,
  	  "name": "Neutor",
  	  "lat": 51.966837,
  	  "long": 7.616133
  	},
  		{
  	  "id": 2,
  	  "name": "Wolbecker Straße",
  	  "lat": 51.959266,
  	  "long": 7.6341553
  	},
  	{
  	  "id": 3,
  	  "name": "Hüfferstraße",
  	  "lat": 51.961261,
  	  "long": 7.608971
  	},
  	{
  	  "id": 4,
  	  "name": "Hammer Straße",
  	  "lat": 51.955046,
  	  "long": 7.626401
  	},
  	{
  	  "id": 5,
  	  "name": "Promenade",
  	  "lat": 51.960712,
  	  "long": 7.633314
  	},
  	{
  	  "id": 6,
  	  "name": "Gartenstraße",
  	  "lat": 51.971624,
  	  "long": 7.635826
  	},
  	{
  	  "id": 7,
  	  "name": "Warendorfer Straße",
  	  "lat": 51.961757,
  	  "long": 7.637633
  	},
  	{
  	  "id": 9,
  	  "name": "Weseler Straße",
  	  "lat": 51.950107,
  	  "long": 7.617267
  	},

    ]
  $scope.load = function() {
    $('#predDate').attr('min', $scope.formatDate(1));
    $('#predDate').attr('max', $scope.formatDate(7));
    $('#predDate').attr('value', $scope.formatDate(1));
    $scope.map = L.map('map').setView([30.0444, 31.2357], 2);
      var OpenStreetMap = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      })//.addTo($scope.map);
      $scope.layer = OpenStreetMap.addTo($scope.map);
      $scope.getWeatherForecast(function(){
        $scope.selectNowClicked()
        $scope.showStationsOnMap();
      });
  }
  $scope.buildMarkerIcon = function(bikeCount){
    var htmlContent = `<img class = 'marker-icon-img' src = 'imgs/bicycle.png'></img>`;
    if(bikeCount)
      htmlContent += `<span class = 'marker-bike-counter'>${bikeCount}</span>`
    var bikeIcon = L.divIcon({
        className: 'marker-icon-div',
        html: htmlContent,
        //iconUrl: 'imgs/bicycle.png',
        iconSize:     [32, 32]
    });
    return bikeIcon
  }
  $scope.showStationsOnMap = function(){
    var markerItems = []
    var bikeIcon = L.divIcon({
        className: 'marker-icon-div',
        html: `<img class = 'marker-icon-img' src = 'imgs/bicycle.png'></img><span class = 'marker-bike-counter'>154</span>`,
        //iconUrl: 'imgs/bicycle.png',
        iconSize:     [32, 32]
    });
    $scope.markersLayer = new L.LayerGroup();
    $scope.markersLayer.clearLayers();
    $scope.map.eachLayer(function (layer) {
      if(!layer._url)//don't remove tile layer(Basemap)
        $scope.map.removeLayer(layer);
    });

    for (station of $scope.bikeStaions) {
      //var bikeCount = Math.round(Math.random()*200);
      var marker = L.marker([station.lat, station.long], {icon: $scope.buildMarkerIcon(station.bikeCount)})
      var popupContent = station.name;
      if(station.bikeCount)
        popupContent += "<br/>" + station.bikeCount
      markerItems.push(marker)
      marker.bindPopup(popupContent)
      $scope.markersLayer.addLayer(marker);
    }
    $scope.markersLayer.addTo($scope.map);
    var group = new L.featureGroup(markerItems);
    $scope.map.fitBounds(group.getBounds());
  }
  $scope.getWeatherForecast = function(callback){
    $http({url:$scope.darkskyUrl}).
      then(function(data){
        $scope.weatherPredictions = data.data.daily.data;
        console.log(data.data.daily.data)
        callback();
    })
  }
  $scope.predictStationsBikeCount = function(date, time)
  {
    $("#loader").css("display", "block");
    var predictionParameters = {}
    predictionParameters.date = date
    predictionParameters.dayOfWeek = predictionParameters.date.getDay() + 1;
    predictionParameters.isWeekend = predictionParameters.dayOfWeek==1 || predictionParameters.dayOfWeek==7
    predictionParameters.isHoliday = false;
    predictionParameters.season = $scope.getSeason(predictionParameters.date);
    datePrediction = $scope.getWeatherPredictionForDate(predictionParameters.date)
    predictionParameters.temperature = (datePrediction.temperatureHigh + datePrediction.temperatureLow)/2
    predictionParameters.wind = datePrediction.windSpeed * 3.6;//convert from mps to kmph
    predictionParameters.precipitation = datePrediction.precipIntensity
    predictionParameters.hour = time;
    console.log(`dayofweek = ${predictionParameters.dayOfWeek}, isWeekend = ${predictionParameters.isWeekend}
      isHoliday = ${predictionParameters.isWeekend} and season = ${predictionParameters.season}`)
    $scope.weatherPredicTemp = `Temprature: ${Math.round(predictionParameters.temperature*100)/100} °c`
    $scope.weatherPredicPrecip = `Precipitation: ${Math.round(predictionParameters.precipitation*100)/100} mmph`
    $scope.weatherPredicWindSpeed = `Wind Speed: ${Math.round(predictionParameters.wind*100)/100} kmph`
    promises = [];
    for (station of $scope.bikeStaions) {
      promises.push($scope.httpRequestStationPrediction(station.id, predictionParameters))
    }
    Promise.all(promises).then(data => {
      for (stationData of data) {
        url = stationData.config.url;
        stationIdIdx = url.indexOf("?station_id")
        qmarkIdx = url.indexOf("&", stationIdIdx+1)
        stationId = url.substring(stationIdIdx+12, qmarkIdx);
        for (station of $scope.bikeStaions) {
          if(station.id == stationId)
            station.bikeCount = parseInt(stationData.data.replace("[", "").replace("]", ""))
        }
      }
      $scope.showStationsOnMap();
      $("#loader").css("display", "none");
    })
  }
  $scope.magicClicked = function(){
    //date = new Date();
    date = new Date($('#predDate')[0].value)
    time = $('#predTime')[0].value.split(":")[0]
    $scope.predictStationsBikeCount(date, time)
  }
  $scope.httpRequestStationPrediction = function(station_id, predictionParameters)
  {
    var predictionServerUrl += `?station_id=${station_id}`
    +`&season=${predictionParameters.season}&day_of_week=${predictionParameters.dayOfWeek}&`
    +`is_weekday=${!predictionParameters.isWeekend}&is_holiday=${predictionParameters.isHoliday}`
    +`&hour=${predictionParameters.hour}&temperature=${predictionParameters.temperature}`
    +`&wind=${predictionParameters.wind}&precipitation=${predictionParameters.precipitation}`;
    return $http({url:predictionServerUrl});
  }
  $scope.getWeatherPredictionForDate = function(date){
    for (pred of $scope.weatherPredictions) {
      predDate = new Date(0);
      predDate.setUTCSeconds(pred.time)
      if(predDate.getDate() == date.getDate() && predDate.getMonth() == date.getMonth())
        return pred;
    }
    return null;
  }
  $scope.getSeason = function(date)
  {
    //1 winter
    //2 spring
    //3 summer
    //4 fall

    //Months start from 0, 0 is Jan, 1 is Feb and so on
    day = date.getDate();
    month = date.getMonth();
    if(month == 3 || month == 4) return 2;
    if(month == 6 || month == 7) return 3;
    if(month == 9 || month == 10) return 4;
    if(month == 0 || month == 1) return 1;

    if (month == 2){
      if(day >= 21)
        return 2;
      else return 1
    }
    else if(month == 5)
    {
      if(day >= 21)
        return 3;
      else return 2
    }
    else if(month == 8)
    {
      if(day >= 21)
        return 4;
      else return 3
    }
    else if(month == 11)
    {
      if(day >= 21)
        return 1;
      else return 4
    }
  }
  $scope.selectPredictClicked = function(){
    $scope.predict = true;
  }
  $scope.selectNowClicked = function(){
    $scope.predict = false;
    date = new Date();
    time = new Date().getHours().toString();
    $scope.predictStationsBikeCount(date, time)
  }
  $scope.selectHistoryClicked = function(){
    window.open("timeseries2017.html");
  }
  $scope.formatDate = function(excessdays = 0) {
    var today = new Date(); // get the current date
    var date =  today;
    date.setDate(today.getDate() + excessdays)
    var dd = date.getDate() ; //get the day from today.
    var mm = date.getMonth()+1; //get the month from today +1 because january is 0!
    var yyyy = date.getFullYear(); //get the year from today

    //if day is below 10, add a zero before (ex: 9 -> 09)
    if(dd<10) {
        dd='0'+dd
    }

    //like the day, do the same to month (3->03)
    if(mm<10) {
        mm='0'+mm
    }

    //finally join yyyy mm and dd with a "-" between then
    return yyyy+'-'+mm+'-'+dd;
}
}]);
