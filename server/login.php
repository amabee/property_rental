<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
include("conn.php");
class UserLogin
{

    public function login($json)
    {
        include("conn.php");
        $json = json_decode($json, true);
        $sql = "SELECT `id`, `name`, `username`,`type` FROM `users` WHERE username = :username AND password = :password";
        $stmt = $conn->prepare($sql);
        $password = md5($json['password']);
        $stmt->bindParam(":username", $json['username']);
        $stmt->bindParam(":password", $password);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row) {
            echo json_encode($row);
        } else {
            echo json_encode("0");
        }
    }

}

$api = new UserLogin();

if ($_SERVER["REQUEST_METHOD"] == "GET" || $_SERVER["REQUEST_METHOD"] == "POST") {
    if (isset($_REQUEST['operation']) && isset($_REQUEST['json'])) {
        $operation = $_REQUEST['operation'];
        $json = $_REQUEST['json'];

        switch ($operation) {
            case 'login':
                echo $api->login($json);
                break;

            default:
                echo json_encode(["error" => "Invalid operation"]);
                break;
        }
    } else {
        echo json_encode(["error" => "Missing parameters"]);
    }
} else {
    echo json_encode(["error" => "Invalid request method"]);
}
?>