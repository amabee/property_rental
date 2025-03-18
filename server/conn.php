<?php
$server = "localhost";
$username = "root";
$password = "";
$database = "house_rental_db";


try {
    $conn = new PDO("mysql:host=$server;dbname=$database", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $ex) {
    echo json_encode(array('error' => $ex->getMessage()));
    exit();
}

?>