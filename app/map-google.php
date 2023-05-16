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
        <a href="widgets.html" class="sl-menu-link">
        </a><!-- sl-menu-link -->
        <a href="#" class="sl-menu-link">
          <!-- menu-item -->
        </a><!-- sl-menu-link -->
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
        <div class="navicon-left hidden-md-down"><a id="btnLeftMenu" href="index.php"><i class="icon ion-navicon-round"></i></a></div>
        <div class="navicon-left hidden-lg-up"><a id="btnLeftMenuMobile" href="index.php"><i class="icon ion-navicon-round"></i></a></div>
      </div><!-- sl-header-left -->
      <div class="sl-header-right">
        <nav class="nav">
          <div class="dropdown">
            <a href="index.php" class="nav-link nav-link-profile" data-toggle="dropdown">
              <span style="color: orange;" class="logged-name">
                  
                          Nadzorna plošča
            </a>
          </div><!-- dropdown -->
        </nav>
      </div><!-- sl-header-right -->
    </div><!-- sl-header -->
    <!-- ########## END: HEAD PANEL ########## -->

    <!-- ########## START: MAIN PANEL ########## -->
    
<div id="map"></div>
<script>
    var map = L.map('map');
    L.tileLayer('https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=of4FHIwAhyH3oUuBaBUs', {
        attribution: '<a href="https://www.maptiler.com/copyright/" target="_blank">&copy; MapTiler</a> <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap contributors</a>'
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