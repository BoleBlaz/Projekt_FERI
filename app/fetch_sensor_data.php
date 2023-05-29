<?php
    include_once('get_data.php');
?>
<?php
// Assuming you have established a database connection

$username = $_SESSION['username'];
$query = "SELECT id FROM users WHERE username='$username'";
$result = $conn->query($query);
$row = $result->fetch_assoc();
$user_id = $row['id'];

// Get the route number and user ID from the query parameters
$routeNum = $_GET['routeNum'];

// Query to fetch sensor data for the selected route and user
$query = "SELECT accelerometer_x, accelerometer_y, accelerometer_z, gyroscope_x, gyroscope_y, gyroscope_z FROM locations WHERE route_num='$routeNum' AND user_id='$user_id'";

$result = $conn->query($query);

if ($result->num_rows > 0) {
  $sensorData = array();

  // Fetch the sensor data rows
  while ($row = $result->fetch_assoc()) {
    // Add each row to the sensor data array
    $sensorData[] = $row;
  }

  // Convert the sensor data to JSON format and send the response
  echo json_encode($sensorData);
} else {
  // No sensor data found for the selected route and user
  echo json_encode(array());
}

// Close the database connection
$conn->close();
?>
