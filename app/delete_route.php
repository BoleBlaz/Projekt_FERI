<?php
    include_once('get_data.php');
?>

<?php
    $username = $_SESSION['username'];
    $query = "SELECT id FROM users WHERE username='$username'";
    $result = $conn->query($query);
    $row = $result->fetch_assoc();
    $user_id = $row['id'];
?>

<?php
// Assuming you have already established a database connection

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['routeToDelete'])) {
  $routeToDelete = $_POST['routeToDelete'];

  // Perform the deletion query
  $deleteQuery = "DELETE FROM locations WHERE route_num='$routeToDelete' AND user_id='$user_id'";
  $result = $conn->query($deleteQuery);

  if ($result) {
    // Deletion successful
    echo "Izbrana pot uspešno odstranjena";
  } else {
    // Deletion failed
    echo "Error deleting route: " . $conn->error;
  }
} else {
  // Invalid request or missing parameter
  echo "Invalid request";
}

// Close the database connection
$conn->close();
?>