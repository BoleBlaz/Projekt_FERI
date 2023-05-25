<?php
    include_once('get_data.php');
?>

<!DOCTYPE html>
<html>
<head>
    <title>Stanje slovenskih cest</title>
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="shortcut icon" type="image/png" href="../img/logo.png">
    <style>
        body {
            background-color: #f2f2f2;
            color: #333333;
            font-family: Arial, sans-serif;
            padding-top: 20px;
        }

        form {
            margin-bottom: 20px;
        }

        table {
            border-collapse: collapse;
            width: 100%;
            margin-bottom: 20px;
        }

        th {
            background-color: #e9e9e9;
            padding: 8px;
            text-align: left;
        }

        td {
            background-color: #ffffff;
            padding: 8px;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        tr.highlight {
            background-color: yellow;
        }

        @keyframes flashing {
            0% { color: red; }
            50% { color: transparent; }
            100% { color: red; }
        }

        .flashing-text {
            animation: flashing 2s infinite;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="text-center"><b>Stanje slovenskih cest <span class="flashing-text">V ŽIVO</span></b></h1>
        <br></br>
        <form class="form-inline" method="GET" action="">
            <div class="form-group">
                <input type="text" class="form-control" name="search" placeholder="Išči po lokaciji">
            </div>
            <button type="submit" class="btn btn-primary ml-2">Izberi</button>
        </form>

        <form method="GET" action="">
            <div class="form-group">
                <select class="form-control" name="condition_filter">
                    <option value="">Filtriraj prikaz</option>
                    <option value="Normalen promet">Normalen promet</option>
                    <option value="Povečan promet">Povečan promet</option>
                    <option value="Zgoščen promet">Zgoščen promet</option>
                    <option value="Gost promet">Gost promet</option>
                    <option value="Gost promet z zastoji">Gost promet z zastoji</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">Izberi</button>
        </form>

        <div class="d-flex justify-content-between">
            <a href="get_road_data.php" class="btn btn-link">Prikaži vse</a>
            <a href="map-google.php" class="btn btn-link">Nazaj na zemljevid</a>
        </div>

        <div class="table-responsive">
            <?php
            // Build the SQL query to retrieve all data
            $sql = "SELECT * FROM scrapedData";

            // Check if a search query is submitted
            if (isset($_GET['search'])) {
                $search = $_GET['search'];
                $sql .= " WHERE road LIKE '%$search%' OR location LIKE '%$search%'";
            }

            // Check if a condition filter is selected
            if (isset($_GET['condition_filter']) && !empty($_GET['condition_filter'])) {
                $conditionFilter = $_GET['condition_filter'];
                if (isset($_GET['search'])) {
                    $sql .= " AND conditions LIKE '%$conditionFilter%'";
                } else {
                    $sql .= " WHERE conditions LIKE '%$conditionFilter%'";
                }
            }

            // Assuming you have established a database connection and assigned it to the variable $conn
            $result = $conn->query($sql);

            if ($result->num_rows > 0) {
                echo "<table class='table'>
                        <tr>
                            <th>Št</th>
                            <th>Cesta</th>
                            <th>Lokacija</th>
                            <th>Smer</th>
                            <th>Število vozil</th>
                            <th>Hirost</th>
                            <th>Prostor</th>
                            <th>Zapolnjenost</th>
                            <th>Čas</th>
                            <th>Stanje</th>
                        </tr>";

                while ($row = $result->fetch_assoc()) {
                    $id = $row['id'] - 1;
                    if ($row['id'] == 1) {
                        continue;
                    }
                    // Check if the road or location matches the search text
                    $highlightClass = '';
                    if (isset($_GET['search']) && (stripos($row['road'], $search) !== false || stripos($row['location'], $search) !== false)) {
                        $highlightClass = 'highlight';
                    }

                    // Check if the condition matches the filter
                    if (isset($_GET['condition_filter']) && !empty($_GET['condition_filter']) && stripos($row['conditions'], $conditionFilter) !== false) {
                        $highlightClass .= ' highlight';
                    }

                    echo "<tr class='".$highlightClass."'>
                            <td>".$id."</td>
                            <td>".$row['road']."</td>
                            <td>".$row['location']."</td>
                            <td>".$row['direction']."</td>
                            <td>".$row['numVehicles']."</td>
                            <td>".$row['speed']."</td>
                            <td>".$row['space']."</td>
                            <td>".$row['filled']."</td>
                            <td>".$row['time']."</td>
                            <td>".$row['conditions']."</td>
                        </tr>";
                }
                echo "</table>";
            } else {
                echo "No data available.";
            }

            $conn->close();
            ?>
        </div>
    </div>

    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
</body>
</html>
