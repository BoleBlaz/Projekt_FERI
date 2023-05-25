<?php
  error_reporting(E_ALL);
  ini_set('display_errors', 1);

include_once('get_data.php');

if(isset($_POST['login'])) {
	$username = $_POST['username'];
	$password = $_POST['password'];

	$sql = "SELECT * FROM users WHERE username='$username'";
	$result = $conn->query($sql);

	if ($result->num_rows == 1) {
		$user = $result->fetch_assoc();
		$hashed_password = $user['password'];
		if (password_verify($password, $hashed_password)) {
			$_SESSION['username'] = $username;
			header("Location: index.php");
			echo "<div style='color:green;'>Prijava uspešna</div>";
			echo "Pozdravljeni, " . $username . "!";
		} else {
			echo "<div style='color:red;'>Napačno ime ali geslo</div>";
		}
	} else {
		echo "<div style='color:red;'>Napačno ime ali geslo</div>";
	}
}
?>

<!DOCTYPE html>
<html>
<head>
  <title>Login Form</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="shortcut icon" type="image/png" href="../img/logo.png">
  
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js"></script>
  <style>
body {
  background-image: url('road-leading-mountain-range-with-blue-sky-clouds.jpg');
  background-size: cover;
  background-repeat: no-repeat;
  margin-top: 50px;
  animation-name: bounce;
  animation-duration: 1s;
  animation-iteration-count: infinite;
  animation-direction: alternate;
}

@keyframes bounce {
  from { transform: translateY(0); }
  to { transform: translateY(-20px); }
}

.login-form {
  margin: 100px auto;
  max-width: 400px;
  background-color: rgba(0, 0, 0, 0.6); /* Set the background color with opacity */
  border-radius: 10px;
  box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.2);
  padding: 30px;
}

.login-form h2 {
  color: #fff;
  font-weight: bold;
  margin-bottom: 30px;
  text-align: center;
  text-transform: uppercase;
}

.login-form label {
  color: #fff;
  font-weight: bold;
  margin-bottom: 10px;
}

.login-form input[type="text"],
.login-form input[type="password"] {
  background-color: rgba(255, 255, 255, 0.7); /* Set the input background color with opacity */
  border: none;
  border-radius: 5px;
  box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.2);
  color: #495057;
  padding: 10px;
  width: 100%;
}

.login-form input[type="submit"] {
  background-color: #007bff;
  border: none;
  border-radius: 5px;
  color: #fff;
  cursor: pointer;
  font-weight: bold;
  margin-top: 20px;
  padding: 10px;
  width: 100%;
}

.login-form input[type="submit"]:hover {
  background-color: #0062cc;
}

.error-message {
  color: red;
  font-weight: bold;
  margin-top: 20px;
  text-align: center;
}

.success-message {
  color: green;
  font-weight: bold;
  margin-top: 20px;
  text-align: center;
}

  </style>
</head>
<body>

<div class="container">
  <div class="row">
    <div class="col-md-8 offset-md-2 login-form" style="display: none;">
      <form method="post">
        <h2>Prijavite se</h2>

        <?php if (isset($success_message)): ?>
          <div class="success-message"><?php echo $success_message; ?></div>
        <?php endif; ?>

        <?php if (isset($error_message)): ?>
          <div class="error-message"><?php echo $error_message; ?></div>
        <?php endif; ?>

        <label>Uporabniško ime:</label>
        <input type="text" name="username" required>

        <label>Geslo:</label>
        <input type="password" name="password" required>

        <input type="submit" name="login" value="Prijava">
        <br></br>
        <p style="color: white;">S klikom na spodnji gumb za prijavo se strinjate z našo politiko zasebnosti in pogoji uporabe naše spletne strani.</p>
        <div style="text-align: center;">
            <a href="https://beoflere.com/FERI_projekt/app/page-signup.php" style="color: orange;">Še nimate računa? Registrirajte se</a>
        </div>
      </form>
    </div>
  </div>
</div>
<script>
  $(document).ready(function() {
    // Fade in the login form
    $(".login-form").fadeIn(1000);
  });
</script>

</body>
</html>