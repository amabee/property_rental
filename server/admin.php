<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
include("conn.php");

class PropertyRental
{

    #region DASHBOARD DATA

    function getDashboardData()
    {
        include("conn.php");

        $houseCountSql = "SELECT COUNT(*) as house_count FROM `houses`";
        $houseCountStmt = $conn->prepare($houseCountSql);
        $houseCountStmt->execute();
        $houseCount = $houseCountStmt->fetch(PDO::FETCH_ASSOC)['house_count'];

        $tenantCountSql = "SELECT COUNT(*) as tenant_count FROM `tenants`";
        $tenantCountStmt = $conn->prepare($tenantCountSql);
        $tenantCountStmt->execute();
        $tenantCount = $tenantCountStmt->fetch(PDO::FETCH_ASSOC)['tenant_count'];

        $currentMonth = date('Y-m');
        $paymentsSql = "SELECT SUM(`amount`) as total_payments 
                        FROM `payments` 
                        WHERE DATE_FORMAT(`date_created`, '%Y-%m') = :currentMonth";
        $paymentsStmt = $conn->prepare($paymentsSql);
        $paymentsStmt->bindParam(':currentMonth', $currentMonth);
        $paymentsStmt->execute();
        $totalPayments = $paymentsStmt->fetch(PDO::FETCH_ASSOC)['total_payments'] ?? 0;

        $dashboardData = [
            "house_count" => $houseCount,
            "tenant_count" => $tenantCount,
            "total_payments_this_month" => $totalPayments
        ];

        echo json_encode($dashboardData);
    }

    #endregion

    #region Categories

    function createCategory($json)
    {
        include("conn.php");
        $data = json_decode($json, true);

        if (!isset($data['name'])) {
            echo json_encode(["error" => "Missing category name"]);
            return;
        }

        $insert_sql = "INSERT INTO `categories` (`name`) VALUES (:name)";
        $insert_stmt = $conn->prepare($insert_sql);
        $insert_stmt->bindParam(':name', $data['name']);

        if ($insert_stmt->execute()) {
            echo json_encode(["success" => "Category created successfully"]);
        } else {
            echo json_encode(["error" => "Failed to create category"]);
        }
    }

    function getCategories()
    {
        include("conn.php");
        $select_sql = "SELECT `id`, `name` FROM `categories` WHERE 1";
        $select_stmt = $conn->prepare($select_sql);
        $select_stmt->execute();
        $row = $select_stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($row);
    }

    function updateCategory($json)
    {
        include("conn.php");
        $data = json_decode($json, true);

        if (!isset($data['id']) || !isset($data['name'])) {
            echo json_encode(["error" => "Missing parameters"]);
            return;
        }

        $update_sql = "UPDATE `categories` SET `name` = :name WHERE `id` = :id";
        $update_stmt = $conn->prepare($update_sql);
        $update_stmt->bindParam(':id', $data['id']);
        $update_stmt->bindParam(':name', $data['name']);

        if ($update_stmt->execute()) {
            echo json_encode(["success" => "Category updated successfully"]);
        } else {
            echo json_encode(["error" => "Failed to update category"]);
        }
    }

    function deleteCategory($json)
    {
        include("conn.php");
        $data = json_decode($json, true);

        if (!isset($data['id'])) {
            echo json_encode(["error" => "Missing parameters"]);
            return;
        }

        $delete_sql = "DELETE FROM `categories` WHERE `id` = :id";
        $delete_stmt = $conn->prepare($delete_sql);
        $delete_stmt->bindParam(':id', $data['id']);

        if ($delete_stmt->execute()) {
            echo json_encode(["success" => "Category deleted successfully"]);
        } else {
            echo json_encode(["error" => "Failed to delete category"]);
        }
    }

    #endregion

    #region Houses

    function getHouses()
    {
        include("conn.php");
        $select_sql = "SELECT houses.*, categories.name AS category_name
         FROM `houses` JOIN categories ON houses.category_id = categories.id";
        $select_stmt = $conn->prepare($select_sql);
        $select_stmt->execute();
        $row = $select_stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($row);
    }

    function addHouse($json)
    {
        include("conn.php");
        $data = json_decode($json, true);
        $imageFileName = $imageFileName ?? 'https://placehold.co/800x600/85c1e9/FFFFFF?font=roboto&text=NO%20IMAGE%20CAPITAL';


        if (!empty($_FILES['image']['name'])) {
            $targetDir = "uploads/";
            $imageFileName = basename($_FILES['image']['name']);
            $targetFilePath = $targetDir . $imageFileName;

            if (!is_dir($targetDir)) {
                mkdir($targetDir, 0777, true);
            }

            if (!move_uploaded_file($_FILES['image']['tmp_name'], $targetFilePath)) {
                echo json_encode(["error" => "Failed to upload image"]);
                return;
            }
        }

        $insert_sql = "INSERT INTO `houses` (`house_no`, `category_id`, `description`, `price`, `image`) 
                       VALUES (:house_no, :category_id, :description, :price, :image)";
        $insert_stmt = $conn->prepare($insert_sql);
        $insert_stmt->bindParam(':house_no', $data['house_no']);
        $insert_stmt->bindParam(':category_id', $data['category_id']);
        $insert_stmt->bindParam(':description', $data['description']);
        $insert_stmt->bindParam(':price', $data['price']);
        $insert_stmt->bindParam(':image', $imageFileName);

        if ($insert_stmt->execute()) {
            echo json_encode("1");
        } else {
            echo json_encode("0");
        }
    }


    function updateHouse($json)
    {
        include("conn.php");
        $data = json_decode($json, true);
        $imageFileName = $data['image'] ?? 'https://placehold.co/800x600/85c1e9/FFFFFF?font=roboto&text=NO%20IMAGE%20CAPITAL';

        if (!empty($_FILES['image']['name'])) {
            $targetDir = "uploads/";
            $imageFileName = basename($_FILES['image']['name']);
            $targetFilePath = $targetDir . $imageFileName;

            if (!is_dir($targetDir)) {
                mkdir($targetDir, 0777, true);
            }

            if (!move_uploaded_file($_FILES['image']['tmp_name'], $targetFilePath)) {
                echo json_encode(["error" => "Failed to upload image"]);
                return;
            }
        }

        $update_sql = "UPDATE `houses` 
                       SET `house_no` = :house_no, 
                           `category_id` = :category_id,
                           `description` = :description, 
                           `price` = :price, 
                           `image` = :image 
                       WHERE `id` = :id";

        $update_stmt = $conn->prepare($update_sql);
        $update_stmt->bindParam(':id', $data['id']);
        $update_stmt->bindParam(':house_no', $data['house_no']);
        $update_stmt->bindParam(':category_id', $data['category_id']);
        $update_stmt->bindParam(':description', $data['description']);
        $update_stmt->bindParam(':price', $data['price']);
        $update_stmt->bindParam(':image', $imageFileName);

        if ($update_stmt->execute()) {
            echo json_encode("1");
        } else {
            echo json_encode("0");
        }
    }


    function deleteHouse($json)
    {
        include("conn.php");
        $data = json_decode($json, true);

        $delete_sql = "DELETE FROM `houses` WHERE `id` = :id";
        $delete_stmt = $conn->prepare($delete_sql);
        $delete_stmt->bindParam(':id', $data['id']);

        if ($delete_stmt->execute()) {
            echo json_encode("1");
        } else {
            echo json_encode("0");
        }
    }

    #endregion
}

$api = new PropertyRental();

if ($_SERVER["REQUEST_METHOD"] == "GET" || $_SERVER["REQUEST_METHOD"] == "POST") {
    if (isset($_REQUEST['operation']) && isset($_REQUEST['json'])) {
        $operation = $_REQUEST['operation'];
        $json = $_REQUEST['json'];

        switch ($operation) {
            case 'getDashboardData':
                $api->getDashboardData();
                break;
            case 'getCategories':
                $api->getCategories();
                break;
            case 'createCategory':
                $api->createCategory($json);
                break;
            case 'updateCategory':
                $api->updateCategory($json);
                break;
            case 'deleteCategory':
                $api->deleteCategory($json);
                break;
            case 'viewHouses':
                $api->getHouses();
                break;
            case 'addHouse':
                $api->addHouse($json);
                break;
            case 'updateHouse':
                $api->updateHouse($json);
                break;
            case 'deleteHouse':
                $api->deleteHouse($json);
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