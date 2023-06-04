<?php
include_once('get_data.php');

$username = $_SESSION['username'];
$query = "SELECT id FROM users WHERE username='$username'";
$result = $conn->query($query);
$row = $result->fetch_assoc();
$user_id = $row['id'];

$routeNum = $_GET['routeNum'];

$numRoutesQuery = "SELECT COUNT(DISTINCT route_num) AS num_routes FROM locations WHERE user_id = ?";
$numRoutesStatement = $conn->prepare($numRoutesQuery);
$numRoutesStatement->bind_param('i', $user_id);
$numRoutesStatement->execute();
$numRoutesResult = $numRoutesStatement->get_result();
$numRoutesData = $numRoutesResult->fetch_assoc();
$numRoutes = $numRoutesData['num_routes'];

// Get the maximum speed across all routes for the user
$maxSpeedQuery = "SELECT MAX(speed) AS max_speed FROM locations WHERE user_id = ?";
$maxSpeedStatement = $conn->prepare($maxSpeedQuery);
$maxSpeedStatement->bind_param('i', $user_id);
$maxSpeedStatement->execute();
$maxSpeedResult = $maxSpeedStatement->get_result();
$maxSpeedData = $maxSpeedResult->fetch_assoc();
$maxSpeed = $maxSpeedData['max_speed'];

$routeQuery = "SELECT MIN(date) AS first_date, MAX(date) AS last_date, AVG(accelerometer_x) AS avg_x, AVG(accelerometer_y) AS avg_y, AVG(accelerometer_z) AS avg_z, MAX(speed) AS max_speed, AVG(speed) AS avg_speed, MIN(speed) AS min_speed FROM locations WHERE user_id = ? AND route_num = ?";
$routeStatement = $conn->prepare($routeQuery);
$routeStatement->bind_param('is', $user_id, $routeNum);
$routeStatement->execute();
$routeResult = $routeStatement->get_result();

$response = array();

if ($routeResult->num_rows > 0) {
    $routeData = $routeResult->fetch_assoc();
    $firstDate = date_create($routeData['first_date']);
    $lastDate = date_create($routeData['last_date']);
    
    $duration = date_diff($firstDate, $lastDate)->format('%H:%I:%S');
    $formattedFirstDate = $firstDate->format('Y-m-d H:i:s');
    $formattedLastDate = $lastDate->format('Y-m-d H:i:s');
    $avgX = number_format($routeData['avg_x'], 4);
    $avgY = number_format($routeData['avg_y'], 4);
    $avgZ = number_format($routeData['avg_z'], 4);
    $maxSpeed = number_format($routeData['max_speed'], 2);
    $avgSpeed = number_format($routeData['avg_speed'], 2);
    $minSpeed = number_format($routeData['min_speed'], 2);
    
    $response['duration'] = $duration;
    $response['firstDate'] = $formattedFirstDate;
    $response['lastDate'] = $formattedLastDate;
    $response['avgX'] = $avgX;
    $response['avgY'] = $avgY;
    $response['avgZ'] = $avgZ;
    $response['maxSpeed'] = $maxSpeed;
    $response['avgSpeed'] = $avgSpeed;
    $response['minSpeed'] = $minSpeed;
    $response['numRoutes'] = $numRoutes;
    
    
    
    // Retrieve the first and last address
    $addressQuery = "SELECT address FROM locations WHERE user_id = ? AND route_num = ? ORDER BY date ASC LIMIT 1";
    $addressStatement = $conn->prepare($addressQuery);
    $addressStatement->bind_param('is', $user_id, $routeNum);
    $addressStatement->execute();
    $addressResult = $addressStatement->get_result();
    
    if ($addressResult->num_rows > 0) {
        $addressData = $addressResult->fetch_assoc();
        $firstAddress = $addressData['address'];
        $response['firstAddress'] = $firstAddress;
    }
    
    $addressQuery = "SELECT address FROM locations WHERE user_id = ? AND route_num = ? ORDER BY date DESC LIMIT 1";
    $addressStatement = $conn->prepare($addressQuery);
    $addressStatement->bind_param('is', $user_id, $routeNum);
    $addressStatement->execute();
    $addressResult = $addressStatement->get_result();
    
    if ($addressResult->num_rows > 0) {
        $addressData = $addressResult->fetch_assoc();
        $lastAddress = $addressData['address'];
        $response['lastAddress'] = $lastAddress;
    }
}

echo json_encode($response);
?>