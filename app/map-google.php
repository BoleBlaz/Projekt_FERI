<?php
    include_once('get_data.php');
?>

<!DOCTYPE html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    
    <link rel="shortcut icon" type="image/png" href="../img/logo.png">

    <!-- Facebook -->
    <meta property="og:url" content="https://beoflere.com/FERI_projekt">
    <meta property="og:title" content="Vozi varno">
    <meta property="og:description" content="Preveri svojo statistiko vožnje v prometu.">

    <meta property="og:image" content="http://themepixels.me/starlight/img/starlight-social.png">
    <meta property="og:image:secure_url" content="http://themepixels.me/starlight/img/starlight-social.png">
    <meta property="og:image:type" content="image/png">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="600">

    <!-- Meta -->
    <meta name="description" content="Preveri svojo statistiko vožnje v prometu.">
    <meta name="author" content="Vozi varno">

    <title>Vozi varno</title>

    <!-- vendor css -->
    <link href="../lib/font-awesome/css/font-awesome.css" rel="stylesheet">
    <link href="../lib/Ionicons/css/ionicons.css" rel="stylesheet">
    <link href="../lib/perfect-scrollbar/css/perfect-scrollbar.css" rel="stylesheet">
    <link href="../lib/rickshaw/rickshaw.min.css" rel="stylesheet">

    <!-- Starlight CSS -->
    <link rel="stylesheet" href="../css/starlight.css">
    
        <!-- Leafletjs -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.3/dist/leaflet.css" integrity="sha256-kLaT2GOSpHechhsozzB+flnD+zUyjE2LlfWPgU04xyI=" crossorigin="" />
    <script src="https://unpkg.com/leaflet@1.9.3/dist/leaflet.js" integrity="sha256-WBkoXOwTeyKclOHuWtc+i2uENFpDZ9YPdf5Hf+D7ewM=" crossorigin=""></script>
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/leaflet.css" integrity="sha512-3P2iNC5pLhncJt9dpjxZT7n3dQGwPp7fWtj7z2Qj7dCz9bB1QqNjVrLmcXAY15VRrIbjsfWxyq5DyGzZ/TkCg==" crossorigin=""/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet-routing-machine/3.2.12/leaflet-routing-machine.css" integrity="sha512-iTb6cqNZ7wnAupNFX6sD37bjJ1SC60oKt6Y/7cMQWjJnJ0N6XLDkGcfCkSt+3DN5VGo9YvpO7wwW+m6x+oZu5Q==" crossorigin=""/>
  
    <style>
        #map{
            position: fixed;
            margin-top: 60px;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
        }
        
        @keyframes flash {
            0% { opacity: 1; }
            50% { opacity: 0; }
            100% { opacity: 1; }
        }
    </style>
  </head>

  <body>

    <!-- ########## START: LEFT PANEL ########## -->
    <div class="sl-logo"><a href="index.php"><i class="icon ion-android-star-outline"></i> Vozi varno</a></div>
    <div class="sl-sideleft">
      <div class="input-group input-group-search">
        <h1 style="font-size: 12px;"> <?php
                             if (isset($_SESSION['username'])) {
                                $username = $_SESSION['username'];
                                $id = $_SESSION['id']; // retrieve the user_id from the session
                                echo "Pozdravjeni  $username!";
                            } 
                           ?></h1>
      </div><!-- input-group -->

      <label class="sidebar-label">navigacija</label>
      <div class="sl-sideleft-menu">
        <a href="index.php" class="sl-menu-link active">
          <div class="sl-menu-item">
            <i class="menu-item-icon icon ion-ios-home-outline tx-22"></i>
            <span class="menu-item-label">Statistična plošča</span>
          </div><!-- menu-item -->
        </a><!-- sl-menu-link -->
                <a href="get_road_data.php" class="sl-menu-link">
          <div class="sl-menu-item">
            <i class="menu-item-icon icon ion-ios-navigate-outline tx-24"></i>
            <span class="menu-item-label">Stanje cest (SLO)</span>
          </div><!-- menu-item -->
        </a><!-- sl-menu-link -->
        <br></br>
        <?php
            $username = $_SESSION['username'];
            $query = "SELECT id FROM users WHERE username='$username'";
            $result = $conn->query($query);
            $row = $result->fetch_assoc();
            $user_id = $row['id'];
        ?>
        
        <div class="select-container">
  <label class="select-label" for="routeSelect">Izberite vožnjo:</label>
  <select id="routeSelect" class="route-select" onchange="updateMapView()">
    <option value="">Izberite vožnjo</option>
    <?php
      $query = "SELECT DISTINCT route_num FROM locations WHERE user_id='$user_id'";
      $result = $conn->query($query);
      while ($row = $result->fetch_assoc()) {
        $routeNum = $row['route_num'];
        echo "<option value='$routeNum'>Vožnja $routeNum</option>";
      }
    ?>
  </select>
  <button onclick="deleteSelectedRoute()" >Izbriši</button>
</div>

<div id="routeDuration" class="route-duration"></div>
<div id="roadCondition"></div>

        <script>
        function updateMapView() {
  var selectedRouteNum = document.getElementById('routeSelect').value;
  var selectedRoute = routes[selectedRouteNum];

  if (selectedRoute && selectedRoute.locations.length > 0) {
    var startLocation = selectedRoute.locations[0];
    map.setView(startLocation, 15);
    displayRouteDuration(selectedRoute);
    calculateAndDisplayRoadCondition(selectedRouteNum);

    // Reset color for all routes
    for (var routeNum in routes) {
      if (routes.hasOwnProperty(routeNum)) {
        var route = routes[routeNum];
        route.polyline.setStyle({ color: 'orange' });
      }
    }

    // Set selected route color to red
    selectedRoute.polyline.setStyle({ color: 'red' });
  }
}
        
        function displayRouteDuration(route) {
            var startDate = new Date(route.startDate);
            var endDate = new Date(route.endDate);
            var durationInSeconds = Math.floor((endDate - startDate) / 1000); // Duration in seconds

            var hours = Math.floor(durationInSeconds / 3600);
            var minutes = Math.floor((durationInSeconds % 3600) / 60);
            var seconds = durationInSeconds % 60;

            var formattedDuration = hours + 'h ' + minutes + 'm ' + seconds + 's';
            
            var startAddress = route.locations[0][2];
            var finishAddress = route.locations[route.locations.length - 1][2];

            var routeDurationElement = document.getElementById('routeDuration');
            routeDurationElement.innerHTML = '<br>' + 'Začetek: <span style="color: black;">' + startAddress + '</span>' + '<br>' + '<br>' +
                                    'Cilj: <span style="color: black;">' + finishAddress + '</span>' + '<br>' + '<br>' +
                                    'Trajanje: <span style="color: orange;">' + formattedDuration + '</span>';
        }
        
        function deleteSelectedRoute() {
    var selectedRouteNum = document.getElementById('routeSelect').value;
    var selectedRoute = routes[selectedRouteNum];

    if (selectedRoute) {
        // Delete the route from the database
        // Adjust the following code based on your database structure and delete query
        var routeToDelete = selectedRouteNum;
        var confirmation = confirm("Ali ste prepričani, da želite izbrisati izbrano vožnjo?");

        if (confirmation) {
            // Perform an AJAX request to delete the route from the database
            // Adjust the URL and parameters based on your backend implementation
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "delete_route.php", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    // Route successfully deleted from the database
                    // Remove the route from the map and update the dropdown
                    if (selectedRoute.polyline) {
                        selectedRoute.polyline.remove();
                    }
                    var firstMarker = selectedRoute.markers[0];
                    var lastMarker = selectedRoute.markers[selectedRoute.markers.length - 1];
                    if (firstMarker) {
                        firstMarker.remove();
                        selectedRoute.markers.splice(0, 1); // Remove the first marker from the array
                    }
                    if (lastMarker) {
                        lastMarker.remove();
                        selectedRoute.markers.splice(selectedRoute.markers.length - 1, 1); // Remove the last marker from the array
                    }
                    delete routes[selectedRouteNum];
                    document.getElementById('routeSelect').remove(selectedRouteNum);
                    document.getElementById('routeDuration').innerHTML = "";
                }
            };
            xhr.send("routeToDelete=" + routeToDelete);
        }
    }
}

function calculateAndDisplayRoadCondition(routeNum) {
  // Make an AJAX request to fetch the sensor data for the selected route from your backend
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
    if (xhr.readyState === XMLHttpRequest.DONE) {
      if (xhr.status === 200) {
        var sensorData = JSON.parse(xhr.responseText);
        var roadCondition = calculateRoadCondition(sensorData);
        var mean = calculateMean(sensorData);
        var stddev = calculateStandardDeviation(sensorData);
        displayRoadCondition(roadCondition);
      } else {
        // Handle error
      }
    }
  };

  xhr.open('GET', 'fetch_sensor_data.php?routeNum=' + routeNum); // Replace with the URL and parameters to fetch the sensor data
  xhr.send();
}


function displayRoadCondition(roadCondition) {
  var roadConditionElement = document.getElementById('roadCondition');

  // Set color based on road condition
  if (roadCondition === 'Slabo') {
    roadConditionElement.style.color = 'red';
  } else if (roadCondition === 'Normalno') {
    roadConditionElement.style.color = 'orange';
  } else if (roadCondition === 'Dobro') {
    roadConditionElement.style.color = 'green';
  }

  roadConditionElement.innerHTML = 'Stanje ceste: ' + roadCondition;
}




function calculateRoadCondition(sensorData) {
  // Extract sensor data from the fetched response
  var accelerometer_x_values = sensorData.map(function(data) {
    return parseFloat(data.accelerometer_x) || 0; // Validate and convert to number, default to 0 if not a valid number
  });

  var accelerometer_y_values = sensorData.map(function(data) {
    return parseFloat(data.accelerometer_y) || 0; // Validate and convert to number, default to 0 if not a valid number
  });

  var accelerometer_z_values = sensorData.map(function(data) {
    return parseFloat(data.accelerometer_z) || 0; // Validate and convert to number, default to 0 if not a valid number
  });

  var gyroscope_x_values = sensorData.map(function(data) {
    return parseFloat(data.gyroscope_x) || 0; // Validate and convert to number, default to 0 if not a valid number
  });

  var gyroscope_y_values = sensorData.map(function(data) {
    return parseFloat(data.gyroscope_y) || 0; // Validate and convert to number, default to 0 if not a valid number
  });

  var gyroscope_z_values = sensorData.map(function(data) {
    return parseFloat(data.gyroscope_z) || 0; // Validate and convert to number, default to 0 if not a valid number
  });

  // Calculate mean values
  var accelerometer_x_mean = calculateMean(accelerometer_x_values);
  var accelerometer_y_mean = calculateMean(accelerometer_y_values);
  var accelerometer_z_mean = calculateMean(accelerometer_z_values);
  var gyroscope_x_mean = calculateMean(gyroscope_x_values);
  var gyroscope_y_mean = calculateMean(gyroscope_y_values);
  var gyroscope_z_mean = calculateMean(gyroscope_z_values);

  // Calculate standard deviation values
  var accelerometer_x_stddev = calculateStandardDeviation(accelerometer_x_values);
  var accelerometer_y_stddev = calculateStandardDeviation(accelerometer_y_values);
  var accelerometer_z_stddev = calculateStandardDeviation(accelerometer_z_values);
  var gyroscope_x_stddev = calculateStandardDeviation(gyroscope_x_values);
  var gyroscope_y_stddev = calculateStandardDeviation(gyroscope_y_values);
  var gyroscope_z_stddev = calculateStandardDeviation(gyroscope_z_values);

  // Define the threshold values for determining the road condition
  var accelerometer_x_threshold = 0.8; // Adjust as per your requirement
  var accelerometer_y_threshold = 0.8; // Adjust as per your requirement
  var accelerometer_z_threshold = 0.8; // Adjust as per your requirement
  var gyroscope_x_threshold = 0.8; // Adjust as per your requirement
  var gyroscope_y_threshold = 0.8; // Adjust as per your requirement
  var gyroscope_z_threshold = 0.8; // Adjust as per your requirement

  // Determine the road condition based on the standard deviation values
  var roadCondition = 'Dobro';

  if (
    accelerometer_x_stddev > accelerometer_x_threshold ||
    accelerometer_y_stddev > accelerometer_y_threshold ||
    accelerometer_z_stddev > accelerometer_z_threshold ||
    gyroscope_x_stddev > gyroscope_x_threshold ||
    gyroscope_y_stddev > gyroscope_y_threshold ||
    gyroscope_z_stddev > gyroscope_z_threshold
  ) {
    roadCondition = 'Slabo';
  } else if (
    accelerometer_x_stddev > accelerometer_x_threshold / 2 ||
    accelerometer_y_stddev > accelerometer_y_threshold / 2 ||
    accelerometer_z_stddev > accelerometer_z_threshold / 2 ||
    gyroscope_x_stddev > gyroscope_x_threshold / 2 ||
    gyroscope_y_stddev > gyroscope_y_threshold / 2 ||
    gyroscope_z_stddev > gyroscope_z_threshold / 2
  ) {
    roadCondition = 'Normalno';
  }

  return roadCondition;
}

function calculateMean(values) {
  var sum = values.reduce(function(total, value) {
    return total + value;
  }, 0);

  return sum / values.length;
}

function calculateStandardDeviation(values) {
  var mean = calculateMean(values);

  var squaredDifferences = values.map(function(value) {
    var difference = value - mean;
    return difference * difference;
  });

  var variance = calculateMean(squaredDifferences);

  return Math.sqrt(variance);
}


</script>

        <a href="widgets.html" class="sl-menu-link">
        </a><!-- sl-menu-link -->
          <!-- menu-item -->
          <br></br>
        <ul class="sl-menu-sub nav flex-column">
          <li class="nav-item"><a href="map-google.php" class="nav-link">Statistika poti</a></li>
        </ul>
    
      </div><!-- sl-sideleft-menu -->

      <br>
    </div><!-- sl-sideleft -->
    <!-- ########## END: LEFT PANEL ########## -->

    <!-- ########## START: HEAD PANEL ########## -->
    <div class="sl-header">
  <div class="sl-header-left">
    <div  class="navicon-left hidden-md-down"><a id="btnLeftMenu" href="index.php"><i style="color: orange;" class="icon ion-ios-home-outline tx-22"></i></a></div>
    <div class="navicon-left hidden-lg-up"><a id="btnLeftMenuMobile" href="index.php"><i style="color: orange;" class="icon ion-ios-home-outline tx-22"></i></a></div>
  </div><!-- sl-header-left -->
  <div class="sl-header-right">
    <nav class="nav">
      <div class="dropdown">
        <a href="get_road_data.php" class="nav-link nav-link-profile" data-toggle="dropdown">
          <span style="color: #2E2EFF; font-size:15px;" class="logged-name">
            Stanje cest (SLO)
            <span style="color: red; animation: flash 1s infinite;">V ŽIVO</span>
          </span>
        </a>
      </div>
    </nav>
  </div><!-- sl-header-right -->
</div>
        </nav>
      </div><!-- sl-header-right -->
    </div><!-- sl-header -->
    <!-- ########## END: HEAD PANEL ########## -->

    <!-- ########## START: MAIN PANEL ########## -->
    
<div id="map"></div>
<script>
    var map = L.map('map');
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

    // Marker
    var myIcon = L.icon({
        iconUrl: 'logo.png',
        iconSize: [40, 40]
    });

    // Fetch the current user's ID based on their username
    <?php
    $username = $_SESSION['username'];
    $query = "SELECT id FROM users WHERE username='$username'";
    $result = $conn->query($query);
    $row = $result->fetch_assoc();
    $user_id = $row['id'];
    ?>

    <?php
$query = "SELECT * FROM locations WHERE user_id='$user_id' ORDER BY route_num, date ASC";
$result = $conn->query($query);
?>

// Create an empty array to hold the location data for each route
var routes = [];

<?php while ($row = $result->fetch_assoc()) { ?>
    // Get the current route number
    var currentRouteNum = <?php echo $row['route_num']; ?>;

    // Check if the route exists in the array, if not, create it
    if (!routes[currentRouteNum]) {
        routes[currentRouteNum] = {
            locations: [],
            polyline: null,
            startDate: '<?php echo $row['date']; ?>',
            endDate: ''
        };
    }

    // Add the location data to the current route's location data array
    routes[currentRouteNum].locations.push([<?php echo $row['latitude']; ?>, <?php echo $row['longitude']; ?>, '<?php echo $row['address']; ?>']);

    // Update the end date for the current route
    routes[currentRouteNum].endDate = '<?php echo $row['date']; ?>';
<?php } ?>

// Create polylines and markers for each route
Object.keys(routes).forEach(function(routeNum) {
    var route = routes[routeNum];
    var locations = route.locations;

    // Create a polyline for the current route
    if (locations.length > 1) {
        route.polyline = L.polyline(locations, { color: 'orange' }).addTo(map);
    }

    // Create markers for the first and last locations of the current route
    if (locations.length > 0) {
        var firstLocation = locations[0];
        var lastLocation = locations[locations.length - 1];
        
        var firstMarker = L.marker(firstLocation.slice(0, 2), { icon: myIcon }).addTo(map);
        firstMarker.bindPopup('Route: ' + routeNum + '<br>' + firstLocation[2] + '<br>Začetek poti: ' + route.startDate);

        var lastMarker = L.marker(lastLocation.slice(0, 2), { icon: myIcon }).addTo(map);
        lastMarker.bindPopup('Route: ' + routeNum + '<br>' + lastLocation[2] + '<br>Konec poti: ' + route.endDate);
    }
});

    // Set the map view to the first location of the first route
    var firstRoute = routes[Object.keys(routes)[0]];
    if (firstRoute && firstRoute.locations.length > 0) {
        map.setView(firstRoute.locations[0], 15);
    } else {
        map.setView([46.1491664, 14.9860106], 8);
        alert("V vašem sistemu ni poti");
    }
</script>





  </body>
</html>