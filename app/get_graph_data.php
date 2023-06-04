<?php
include_once('get_data.php');

$username = $_SESSION['username'];
$query = "SELECT id FROM users WHERE username='$username'";
$result = $conn->query($query);
$row = $result->fetch_assoc();
$user_id = $row['id'];

$routeNum = $_GET['routeNum'];





$routeQuery = "SELECT accelerometer_x, accelerometer_y, accelerometer_z, date FROM locations WHERE user_id = ? AND route_num = ?";
$routeStatement = $conn->prepare($routeQuery);
$routeStatement->bind_param('is', $user_id, $routeNum);
$routeStatement->execute();
$routeResult = $routeStatement->get_result();

$response = array();

if ($routeResult->num_rows > 0) {
    $accelerometerData = array();
        while ($row = $routeResult->fetch_assoc()) {
        $accelerometerData[] = array(
            'accelerometer_x' => $row['accelerometer_x'],
            'accelerometer_y' => $row['accelerometer_y'],
            'accelerometer_z' => $row['accelerometer_z'],
            'date' => $row['date']
        );
    }
    $response['accelerometerData'] = $accelerometerData;
}

echo json_encode($response);
?>