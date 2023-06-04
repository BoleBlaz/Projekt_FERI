<?php
    include_once('get_data.php');
    if (!isset($_SESSION['username'])) {
    header("Location: page-signin.php");
    exit();
}
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

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    
    
    
  </head>

  <body>

    
    <!-- ########## START: LEFT PANEL ########## -->
    <div class="sl-logo"><a href=""><i class="icon ion-android-star-outline"></i> Vozi varno</a></div>
    <div class="sl-sideleft">
      <div class="input-group input-group-search">
        <h1 style="font-size: 12px;">Pozdravljeni!</h1>
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
        <a href="#" class="sl-menu-link">
          <div class="sl-menu-item">
            <i class="menu-item-icon icon ion-ios-navigate-outline tx-24"></i>
            <span class="menu-item-label">Zemljevid</span>
            <i class="menu-item-arrow fa fa-angle-down"></i>
          </div><!-- menu-item -->
        </a><!-- sl-menu-link -->
        <ul class="sl-menu-sub nav flex-column">
          <li class="nav-item"><a href="map-google.php" class="nav-link">Statistika poti</a></li>
        </ul>
        <a href="#" class="sl-menu-link">
          <div class="sl-menu-item">
            <i class="menu-item-icon icon ion-ios-paper-outline tx-22"></i>
            <span class="menu-item-label">Uporabnik</span>
            <i class="menu-item-arrow fa fa-angle-down"></i>
          </div><!-- menu-item -->
        </a><!-- sl-menu-link -->
        <ul class="sl-menu-sub nav flex-column">
          <li class="nav-item"><a href="page-signin.php" class="nav-link">Prijava uporabnika</a></li>
          <li class="nav-item"><a href="page-signup.php" class="nav-link">Registracija uporabnika</a></li>
          <li class="nav-item"><a href="users.php" class="nav-link">Registrirani uporabniki</a></li>
        </ul>
      </div><!-- sl-sideleft-menu -->

      <br>
    </div><!-- sl-sideleft -->
    <!-- ########## END: LEFT PANEL ########## -->

    <!-- ########## START: HEAD PANEL ########## -->
    <div class="sl-header">
      <div class="sl-header-left">
        <div class="navicon-left hidden-md-down"><a id="btnLeftMenu" href=""><i class="icon ion-navicon-round"></i></a></div>
        <div class="navicon-left hidden-lg-up"><a id="btnLeftMenuMobile" href=""><i class="icon ion-navicon-round"></i></a></div>
      </div><!-- sl-header-left -->
      <div class="sl-header-right">
        <nav class="nav">
          <div class="dropdown">
            <a href="" class="nav-link nav-link-profile" data-toggle="dropdown">
              <span class="logged-name">
                          <?php
                             if (isset($_SESSION['username'])) {
                                $username = $_SESSION['username'];
                                $id = $_SESSION['id']; // retrieve the user_id from the session
                                echo "Pozdravjeni  $username!";
                            } 
                           ?>
            </a>
            <div class="dropdown-menu dropdown-menu-header wd-200">
              <ul class="list-unstyled user-profile-nav">
                <li><a href="page-logout.php"><i class="icon ion-power"></i>Odjava</a></li>
              </ul>
            </div><!-- dropdown-menu -->
          </div><!-- dropdown -->
        </nav>
      </div><!-- sl-header-right -->
    </div><!-- sl-header -->
    <!-- ########## END: HEAD PANEL ########## -->



    <!-- ########## START: MAIN PANEL ########## -->

    <div class="sl-mainpanel">
      <nav class="breadcrumb sl-breadcrumb">
        <a class="breadcrumb-item" href="index.php">Vozi varno</a>
        <span class="breadcrumb-item active">Satistična plošča</span>
      </nav>

      <div style="color: black;" class="sl-pagebody">
        <?php
        if (isset($_SESSION['username'])) {
            $username = $_SESSION['username'];
            echo "Statistika vožnje za uporabnika: $username";
        } 
        ?>
        <br></br>
        
        <?php
            $username = $_SESSION['username'];
            $query = "SELECT id FROM users WHERE username='$username'";
            $result = $conn->query($query);
            $row = $result->fetch_assoc();
            $user_id = $row['id'];
        ?>

<!-- HTML dropdown menu -->
<select name="route" class="form-control" onchange="showDuration(this.value)">
    <option value="">Izberi vožnjo</option>
    <?php
    // Fetch unique routes for the current user
    $query = "SELECT DISTINCT route_num FROM locations WHERE user_id = '$user_id'";
    $result = $conn->query($query);

    // Populate the dropdown with routes
    while ($row = $result->fetch_assoc()) {
        $routeNum = $row['route_num'];
        
        // Display the route in the dropdown
        echo "<option value='$routeNum'>$routeNum</option>";
    }
    ?>
</select>

<script>
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
  var roadConditionElement2 = document.getElementById('roadCondition2');

  // Set color based on road condition
  if (roadCondition === 'Slabo') {
    roadConditionElement.textContent = 'Stanje ceste: Slabo';
    roadConditionElement.style.color = 'red';
    roadConditionElement2.textContent = 'Slabo';
    roadConditionElement2.style.color = 'red';
  } else if (roadCondition === 'Normalno') {
    roadConditionElement.textContent = 'Stanje ceste: Normalno';
    roadConditionElement.style.color = 'orange';
    roadConditionElement2.textContent = 'Normalno';
    roadConditionElement2.style.color = 'orange';
  } else if (roadCondition === 'Dobro') {
    roadConditionElement.textContent = 'Stanje ceste: Dobro';
    roadConditionElement.style.color = 'green';
    roadConditionElement2.textContent = 'Dobro';
    roadConditionElement2.style.color = 'green';
  }
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
  var accelerometer_x_threshold = 2.8; // Adjust as per your requirement
  var accelerometer_y_threshold = 2.8; // Adjust as per your requirement
  var accelerometer_z_threshold = 2.8; // Adjust as per your requirement
  var gyroscope_x_threshold = 2.8; // Adjust as per your requirement
  var gyroscope_y_threshold = 2.8; // Adjust as per your requirement
  var gyroscope_z_threshold = 2.8; // Adjust as per your requirement

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

    function showDuration(value) {
        // Add your code to handle the selected value
        console.log(value);
    }

    function showDuration(routeNum) {
    if (routeNum === '') {
        // Clear the content of the elements
        document.getElementById('duration').textContent = '';
        document.getElementById('duration2').textContent = '';
        document.getElementById('firstDate').textContent = '';
        document.getElementById('lastDate').textContent = '';
        document.getElementById('firstAddress').textContent = '';
        document.getElementById('lastAddress').textContent = '';
        document.getElementById('lastAddress2').textContent = '';
        document.getElementById('maxSpeed').textContent = '';
        document.getElementById('maxSpeed2').textContent = '';
        document.getElementById('avgSpeed').textContent = '';
        document.getElementById('minSpeed').textContent = '';
        document.getElementById('roadCondition').textContent = '';
        document.getElementById('senzorji').textContent = '';
        document.getElementById('numRoutes').textContent = '';
    } else {
        fetch('get_duration.php?routeNum=' + routeNum)
            .then(response => response.json())
            .then(data => {
                document.getElementById('duration').textContent = data.duration;
                document.getElementById('duration2').textContent = data.duration;
                document.getElementById('firstDate').textContent = data.firstDate;
                document.getElementById('lastDate').textContent = data.lastDate;
                document.getElementById('firstAddress').textContent = data.firstAddress;
                document.getElementById('lastAddress').textContent = data.lastAddress;
                document.getElementById('lastAddress2').textContent = data.lastAddress;
                document.getElementById('maxSpeed').textContent = data.maxSpeed + "km/h";
                document.getElementById('maxSpeed2').textContent = data.maxSpeed + "km/h";
                document.getElementById('avgSpeed').textContent = data.avgSpeed + "km/h";
                document.getElementById('minSpeed').textContent = data.minSpeed + "km/h";
                document.getElementById('senzorji').textContent = "žiroskop in pospeškometer";
                document.getElementById('numRoutes').textContent = data.numRoutes;
                
                calculateAndDisplayRoadCondition(routeNum);
                showGraph(data.accelerometerData);
                document.getElementById('routeCount').textContent = data.routeCount;
            })
            .catch(error => console.log(error));
    }
}

function showDurationGraph(routeNum) {
    fetch('get_graph_data.php?routeNum=' + routeNum)
        .then(response => response.json())
        .then(data => {
            showGraph(data.accelerometerData);
        })
        .catch(error => console.log(error));
}
    
var chart = null; // Declare a variable to store the chart instance

function showGraph(accelerometerData) {
    var labels = accelerometerData.map(function(data) {
        return data.date;
    });

    var xData = accelerometerData.map(function(data) {
        return data.accelerometer_x;
    });

    var yData = accelerometerData.map(function(data) {
        return data.accelerometer_y;
    });

    var zData = accelerometerData.map(function(data) {
        return data.accelerometer_z;
    });

    var ctx = document.getElementById('accelerometerChart').getContext('2d');
    
    // Destroy previous chart instance if it exists
    if (chart !== null) {
        chart.destroy();
    }
    
    // Resize the chart container element
    var container = document.getElementById('accelerometerChart').parentElement;
    container.style.width = '100%';
    container.style.height = '300px';

    chart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Accelerometer X',
                data: xData,
                borderColor: 'red',
                fill: false
            }, {
                label: 'Accelerometer Y',
                data: yData,
                borderColor: 'green',
                fill: false
            }, {
                label: 'Accelerometer Z',
                data: zData,
                borderColor: 'blue',
                fill: false
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });
}


    
    
</script>


<!-- Duration display -->

        <br></br>
        <div class="row row-sm">
          <div class="col-sm-6 col-xl-3">
            <div class="card pd-20 bg-primary">
              <div class="d-flex justify-content-between align-items-center mg-b-10">
                <h6 class="tx-11 tx-uppercase mg-b-0 tx-spacing-1 tx-white">Trajanje poti</h6>
                <a href="" class="tx-white-8 hover-white"><i class="icon ion-android-more-horizontal"></i></a>
              </div><!-- card-header -->
              <div class="d-flex align-items-center justify-content-between">
                <div style="font-size: 22px;" class="mg-b-0 tx-white tx-lato tx-bold" id="duration"></div>
              </div><!-- card-body -->
              <div class="d-flex align-items-center justify-content-between mg-t-15 bd-t bd-white-2 pd-t-10">
                <div>
                  <span style="font-size: 12px;" class="tx-11 tx-white-6">Začetek poti</span>
                  <div class="tx-white mg-b-0" id="firstDate"></div>
                </div>
                <div>
                  <span style="font-size: 12px;" class="tx-11 tx-white-6">Konec poti</span>
                  <div class="tx-white mg-b-0" id="lastDate"></div>
                </div>
              </div><!-- -->
            </div><!-- card -->
          </div><!-- col-3 -->
          <div class="col-sm-6 col-xl-3 mg-t-20 mg-sm-t-0">
            <div class="card pd-20 bg-info">
              <div class="d-flex justify-content-between align-items-center mg-b-10">
                <h6 class="tx-11 tx-uppercase mg-b-0 tx-spacing-1 tx-white">Ciljne informacije poti</h6>
                <a href="" class="tx-white-8 hover-white"><i class="icon ion-android-more-horizontal"></i></a>
              </div><!-- card-header -->
              <div class="d-flex align-items-center justify-content-between">
                <div style="font-size: 22px;" class="mg-b-0 tx-white tx-lato tx-bold" id="lastAddress2"></div>
              </div><!-- card-body -->
              <div class="d-flex align-items-center justify-content-between mg-t-15 bd-t bd-white-2 pd-t-10">
                <div>
                  <span style="font-size: 12px;" class="tx-11 tx-white-6">Začetni naslov</span>
                  <div class="tx-white mg-b-0" id="firstAddress"></div>
                </div>
                <div>
                  <span style="font-size: 12px;" class="tx-11 tx-white-6">Končni naslov</span>
                  <div class="tx-white mg-b-0" id="lastAddress"></div>
                </div>
              </div><!-- -->
            </div><!-- card -->
          </div><!-- col-3 -->
          <div class="col-sm-6 col-xl-3 mg-t-20 mg-xl-t-0">
            <div class="card pd-20 bg-purple">
              <div class="d-flex justify-content-between align-items-center mg-b-10">
                <h6 class="tx-11 tx-uppercase mg-b-0 tx-spacing-1 tx-white">Povprečna hitrost na poti:</h6>
                <a href="" class="tx-white-8 hover-white"><i class="icon ion-android-more-horizontal"></i></a>
              </div><!-- card-header -->
              <div class="d-flex align-items-center justify-content-between">
                <div style="font-size: 22px;" class="mg-b-0 tx-white tx-lato tx-bold" id="avgSpeed"></div>
              </div><!-- card-body -->
              <div class="d-flex align-items-center justify-content-between mg-t-15 bd-t bd-white-2 pd-t-10">
                <div>
                  <span class="tx-11 tx-white-6">Najmanjša hitrost:</span>
                  <div class="tx-white mg-b-0" id="minSpeed"></div>
                </div>
                <div>
                  <span class="tx-11 tx-white-6">Največja hitrost:</span></span>
                  <div class="tx-white mg-b-0" id="maxSpeed"></div>
                </div>
              </div><!-- -->
            </div><!-- card -->
          </div><!-- col-3 -->
          <div class="col-sm-6 col-xl-3 mg-t-20 mg-xl-t-0">
            <div class="card pd-20 bg-sl-primary">
              <div class="d-flex justify-content-between align-items-center mg-b-10">
                <h6 class="tx-11 tx-uppercase mg-b-0 tx-spacing-1 tx-white">Stanje ceste poti</h6>
                <a href="" class="tx-white-8 hover-white"><i class="icon ion-android-more-horizontal"></i></a>
              </div><!-- card-header -->
              <div class="d-flex align-items-center justify-content-between">
                <div style="font-size: 22px;" class="mg-b-0 tx-white tx-lato tx-bold" id="roadCondition"></div>
              </div><!-- card-body -->
              <div class="d-flex align-items-center justify-content-between mg-t-15 bd-t bd-white-2 pd-t-10">
                <div>
                  <span class="tx-11 tx-white-6">Na poti ste bili</span>
                  <div class="tx-white mg-b-0" id="duration2"></div>
                </div>
                <div>
                  <span class="tx-11 tx-white-6">Pridobljeno na podlagi senzorjev</span>
                  <div class="tx-white mg-b-0" id="senzorji"></div>
                </div>
              </div><!-- -->
            </div><!-- card -->
          </div><!-- col-3 -->
        </div><!-- row -->

        <div class="row row-sm mg-t-20">
          <div class="col-xl-8">
            <div class="card overflow-hidden">
              <div class="card-header bg-transparent pd-y-20 d-sm-flex align-items-center justify-content-between">
                <div class="mg-b-20 mg-sm-b-0">
                  <h6 class="card-title mg-b-5 tx-16 tx-uppercase tx-bold tx-spacing-1">Informacije</h6>
                  <p id="dateDisplay" class="d-block tx-12"></p>
                </div>
                <div class="btn-group" role="group" aria-label="Basic example">
                  <div class="btn btn-secondary tx-12 active">Pregled Voženj</div>
                </div>
              </div><!-- card-header -->
              <div class="card-body pd-0 bd-color-gray-lighter">
                <div class="row no-gutters tx-center">
                  <div class="col-12 col-sm-4 pd-y-20 tx-left">
                    <p class="pd-l-20 tx-12 lh-8 mg-b-0">Prikaz satistike vseh voženj na podlagi pridobljenih senzorskih podatkov.</p>
                  </div><!-- col-4 -->
                  <div class="col-6 col-sm-2 pd-y-20">
                    <h4 class="tx-inverse tx-lato tx-bold mg-b-5" id="numRoutes"></h4>
                    <p class="tx-11 mg-b-0 tx-uppercase">Vse poti</p>
                  </div><!-- col-2 -->
                  <div class="col-6 col-sm-2 pd-y-20 bd-l">
                    <h4 class="tx-inverse tx-lato tx-bold mg-b-5" id="maxSpeed2"></h4>
                    <p class="tx-11 mg-b-0 tx-uppercase">Največja hitrost</p>
                  </div><!-- col-2 -->
                  <div class="col-6 col-sm-2 pd-y-20 bd-l">
                    <h4 class="tx-inverse tx-lato tx-bold mg-b-5"><?php
                             if (isset($_SESSION['username'])) {
                                echo "$username";
                            } 
                           ?></h4>
                    <p class="tx-11 mg-b-0 tx-uppercase">Uporabnik</p>
                  </div><!-- col-2 -->
                  <div class="col-6 col-sm-2 pd-y-20 bd-l">
                    <h4 class="tx-inverse tx-lato tx-bold mg-b-5" id="roadCondition2"></h4>
                    <p class="tx-11 mg-b-0 tx-uppercase">Kondicija ceste</p>
                  </div><!-- col-2 -->
                </div><!-- row -->
              </div><!-- card-body -->
              <div class="card-body pd-0">
                <div id="rickshaw2" class="wd-100p ht-200"></div>
              </div><!-- card-body -->
            </div><!-- card -->

            

          </div><!-- col-8 -->
            <div class="col-xl-4 mg-t-20 mg-xl-t-0">
  <div class="card pd-20 pd-sm-25">
    <h6 class="card-body-title">Pridobivanje senzorskih podatkov</h6>
    <p class="mg-b-20 mg-sm-b-30">Senzosrke podatke, katere prikažemo tukaj pridobimo na mobini aplikaciji.</p>
    
    <div class="ht-200 ht-sm-250 d-flex justify-content-center align-items-center">
      <img src="image.png" alt="Image" style="max-width: 100%; max-height: 100%;">
    </div>
  </div><!-- card -->
  <div class="card widget-messages mg-t-20">
  </div><!-- card -->
</div><!-- col-3 -->
</div><!-- row -->
<br></br>

        
        <select name="route" class="form-control" onchange="showDurationGraph(this.value)">
        <option value="">Prikaži graf pospeškometra izbrane poti</option>
        <?php
        // Fetch unique routes for the current user
        $query = "SELECT DISTINCT route_num FROM locations WHERE user_id = '$user_id'";
        $result = $conn->query($query);

        // Populate the dropdown with routes
        while ($row = $result->fetch_assoc()) {
            $routeNum = $row['route_num'];
        
            // Display the route in the dropdown
            echo "<option value='$routeNum'>$routeNum</option>";
        }
        ?>
        </select>
  
        <div style = "margin-top: 5px; height: 0px;" class="card pd-20 pd-sm-25">
              <canvas id="accelerometerChart"></canvas>

        </div><!-- card -->

      </div><!-- sl-pagebody -->
      
      <footer class="sl-footer">
        <div class="footer-left">
          <div class="mg-b-2">Vse pravice pridržane &copy; 2023. Vozi varno. Izdelava spletne strani: FERI študentje.</div>
          <div>Aljaž Eferl, Nino Franci, Blaž Bole.</div>
        </div>
        <div class="footer-right d-flex align-items-center">
          <span class="tx-uppercase mg-r-10">Deli:</span>
          <a target="_blank" class="pd-x-5" href="https://www.facebook.com/sharer/sharer.php?u=http%3A//https://beoflere.com/FERI_projekt"><i class="fa fa-facebook tx-20"></i></a>
        </div>
      </footer>
      <div id ="map"></div>
    </div><!-- sl-mainpanel -->
    
      <script>
    // Get the current date
    var today = new Date();

    // Format the date as desired (e.g., "MM/DD/YYYY")
    var formattedDate = today.getDate() + '. ' + (today.getMonth() + 1) + '. ' + today.getFullYear();

    // Set the formatted date as the content of the element with id "dateDisplay"
    document.getElementById("dateDisplay").textContent = formattedDate;
  </script>
    
    
    
    <!-- ########## END: MAIN PANEL ########## -->

    <script src="../lib/jquery/jquery.js"></script>
    <script src="../lib/popper.js/popper.js"></script>
    <script src="../lib/bootstrap/bootstrap.js"></script>
    <script src="../lib/jquery-ui/jquery-ui.js"></script>
    <script src="../lib/perfect-scrollbar/js/perfect-scrollbar.jquery.js"></script>
    <script src="../lib/jquery.sparkline.bower/jquery.sparkline.min.js"></script>
    <script src="../lib/d3/d3.js"></script>
    <script src="../lib/rickshaw/rickshaw.min.js"></script>
    <script src="../lib/chart.js/Chart.js"></script>
    <script src="../lib/Flot/jquery.flot.js"></script>
    <script src="../lib/Flot/jquery.flot.pie.js"></script>
    <script src="../lib/Flot/jquery.flot.resize.js"></script>
    <script src="../lib/flot-spline/jquery.flot.spline.js"></script>

    <script src="../js/starlight.js"></script>
    <script src="../js/ResizeSensor.js"></script>
    <script src="../js/dashboard.js"></script>
  </body>
</html>