var bikemunpredapp = angular.module('bikemunpredapp', []);

bikemunpredapp.controller('BikeController', function BikeController($scope) {
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
    $('#myDate').attr('min', $scope.todayDate(1));
    $('#myDate').attr('max', $scope.todayDate(7));
    $('#myDate').attr('value', $scope.todayDate(1));
    $scope.map = L.map('map').setView([30.0444, 31.2357], 2);
      var OpenStreetMap = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      })//.addTo($scope.map);
      $scope.layer = OpenStreetMap.addTo($scope.map);
      $scope.showStationsOnMap();
  }
  $scope.buildMarkerIcon = function(bikeCount){
    var bikeIcon = L.divIcon({
        className: 'marker-icon-div',
        html: `<img class = 'marker-icon-img' src = 'imgs/bicycle.png'></img><span class = 'marker-bike-counter'>${bikeCount}</span>`,
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
    for (station of $scope.bikeStaions) {
      bikeCount = Math.round(Math.random()*200);
      var marker = L.marker([station.lat, station.long], {icon: $scope.buildMarkerIcon(bikeCount)})
      markerItems.push(marker)
      marker.addTo($scope.map)
        .bindPopup(station.name + "<br/>" + bikeCount)
    }
    var group = new L.featureGroup(markerItems);
    $scope.map.fitBounds(group.getBounds());
  }
  $scope.selectPredictClicked = function(){
    $scope.predict = true;
  }
  $scope.selectRealtimeClicked = function(){
    $scope.predict = false;
  }
  $scope.todayDate = function(excessdays = 0) {
    var today = new Date(); // get the current date
    var dd = today.getDate() + excessdays; //get the day from today.
    var mm = today.getMonth()+1; //get the month from today +1 because january is 0!
    var yyyy = today.getFullYear(); //get the year from today

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
});
