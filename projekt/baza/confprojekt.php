<?php
foreach (glob("models/*.php") as $filename) {
  require_once $filename;
}

$host = "212.44.101.98";
$username = "beofle38_blazbole";
$password = "Dropshipping2022";
$dbname = "beofle38_feri_projekt";

// Create connection
$connection = new mysqli($host, $username, $password, $dbname);
if (!$connection) {
  echo "ERROR";
  exit(1);
}
mysqli_set_charset($connection, "utf8");

$in_data = json_decode($_GET['data'], true);

switch ($in_data['command']) {
  case "add_user":
    add_user($in_data, $connection);
    break;
  case "get_login_info":
    get_login_info($in_data, $connection);
    break;
  case "delete_user":
    delete_user($in_data, $connection);
    break;
  case "find_user_by_username":
    find_user_by_username($in_data, $connection);
    break;
    //-----LOCATION-----
  case "add_location":
    add_location($in_data, $connection);
    break;
  case "get_routeNum_fromUser":
    get_routeNum_fromUser($in_data, $connection);
    break;
  case "add_image":
    add_image($in_data, $connection);
    break;
  default:
    http_response_code(400);
    exit;
}

// -------------------------START OF USER SCOPE--------------------------

function add_user($data, $connection)
{
  $username = mysqli_real_escape_string($connection, $data['username']);
  $password = mysqli_real_escape_string($connection, $data['password']);
  $password = password_hash($password, PASSWORD_DEFAULT);

  // Check if username already exists
  $check_query = mysqli_query($connection, "SELECT * FROM users WHERE username='$username'");
  if (mysqli_num_rows($check_query) > 0) {
    http_response_code(409);
    echo "ERROR";
    return;
  }

  // Insert new user if username does not exist
  $result = mysqli_query($connection, "INSERT INTO users (username, password) VALUES ('$username', '$password');");
  if ($result) {
    http_response_code(201);
    echo "OK";
  } else {

    echo "ERROR";
  }
}

function get_login_info($data, $connection)
{
  $username = mysqli_real_escape_string($connection, $data['username']);
  $password = mysqli_real_escape_string($connection, $data['password']);

  // Retrieve the hashed password and the username from the database
  $result = mysqli_query($connection, "SELECT username, password FROM users WHERE username='$username'");
  if (mysqli_num_rows($result) == 1) {
    $row = mysqli_fetch_assoc($result);
    $hash = $row['password'];
    $stored_username = $row['username'];
    // Verify the username and password
    if ($username === $stored_username && password_verify($password, $hash)) {
      // Username and password are correct
      echo "OK";
    } else {
      // Username or password is incorrect
      echo "ERROR";
    }
  } else {
    // Username does not exist in the database
    echo "ERROR";
  }
}

// Delete user
function delete_user($data, $connection)
{
  $user_id = mysqli_real_escape_string($connection, $data['user_id']);

  // Delete user from database
  $result = mysqli_query($connection, "DELETE FROM users WHERE id=$user_id;");
  if ($result) {

    echo "OK";
  } else {

    echo "ERROR";
  }
}

// Find user by ID
function find_user_by_username($in_data, $connection)
{
  $username = mysqli_real_escape_string($connection, $in_data['username']);
  $query = "SELECT * FROM users WHERE username='$username'";
  $result = mysqli_query($connection, $query);

  if (mysqli_num_rows($result) > 0) {
    $row = mysqli_fetch_assoc($result);
    $data = array($row); // wrap the result in an array
    http_response_code(200); // set the response code to 200
    echo json_encode($data); // send back a JSON response
  } else {
    http_response_code(404); // set the response code to 404
    echo "ERROR";
  }
}

// -------------------------END OF USER SCOPE--------------------------

// -------------------------START OF LOCATION SCOPE--------------------------

function add_location($data, $connection)
{
  $latitude =  mysqli_real_escape_string($connection, $data['latitude']);
  $longitude =  mysqli_real_escape_string($connection, $data['longitude']);
  $address =  mysqli_real_escape_string($connection, $data['address']);
  $date =  mysqli_real_escape_string($connection, $data['date']);
  $route_num =  mysqli_real_escape_string($connection, $data['route_num']);
  $user_id =  mysqli_real_escape_string($connection, $data['user_id']);
  $accelerometer_x =  mysqli_real_escape_string($connection, $data['accelerometer_x']);
  $accelerometer_y =  mysqli_real_escape_string($connection, $data['accelerometer_y']);
  $accelerometer_z =  mysqli_real_escape_string($connection, $data['accelerometer_z']);

  // Insert new location
  $result = mysqli_query($connection, "INSERT INTO locations (latitude, longitude, address, date, route_num, user_id, accelerometer_x, accelerometer_y, accelerometer_z) VALUES ('$latitude', '$longitude','$address', '$date', '$route_num', '$user_id', '$accelerometer_x', '$accelerometer_y', '$accelerometer_z');");
  if ($result) {
    http_response_code(201);
    echo "OK";
  } else {
    echo "ERROR";
  }
}

function get_routeNum_fromUser($in_data, $connection)
{
  $user_id =  mysqli_real_escape_string($connection, $in_data['user_id']);

  $query = "SELECT MAX(route_num) AS max_route_number FROM locations WHERE user_id = $user_id";
  $result = mysqli_query($connection, $query);
  if (mysqli_num_rows($result) > 0) {
    $row = mysqli_fetch_assoc($result);
    $data = array($row); // wrap the result in an array
    http_response_code(200); // set the response code to 200
    echo json_encode($data); // send back a JSON response
  } else {
    http_response_code(404); // set the response code to 404
    echo "ERROR";
  }
}

// -------------------------END OF LOCATION SCOPE--------------------------

// -------------------------START OF IMAGE SCOPE--------------------------

function add_image($data, $connection)
{
  $name =  mysqli_real_escape_string($connection, $data['name']);
  $path =  mysqli_real_escape_string($connection, $data['path']);
  $user_id =  mysqli_real_escape_string($connection, $data['user_id']);

  // Insert new image
  $result = mysqli_query($connection, "INSERT INTO faces (name, path, user_id) VALUES ('$name', '$path', '$user_id');");
  if ($result) {
    http_response_code(201);
    echo "OK";
  } else {
    echo "ERROR";
  }
}

// -------------------------END OF IMAGE SCOPE--------------------------

