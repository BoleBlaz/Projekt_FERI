<?
// database credentials
$host = "212.44.101.98";
$username = "beofle38_blazbole";
$password = "Dropshipping2022";
$dbname = "beofle38_feri_projekt";

session_start();

//Seja poteče po 30 minutah - avtomatsko odjavi neaktivnega uporabnika
if(isset($_SESSION['LAST_ACTIVITY']) && time() - $_SESSION['LAST_ACTIVITY'] < 1800){
    session_regenerate_id(true);
}
$_SESSION['LAST_ACTIVITY'] = time();

// create connection
$conn = new mysqli($host, $username, $password, $dbname);

mysqli_set_charset($conn, "utf8");

// check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
?>