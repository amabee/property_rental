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

    #region Tenants

    function getTenants()
    {
        include("conn.php");

        $select_sql = "
        SELECT 
            t.*, 
            CONCAT(t.lastname, ', ', t.firstname, ' ', t.middlename) AS name, 
            h.house_no, 
            h.price AS monthly_rent,
            t.date_in,
            CASE 
                WHEN t.status = 1 THEN 'Active'
                WHEN t.status = 0 THEN 'Inactive'
                ELSE 'Unknown'
            END AS status_text
        FROM 
            tenants t 
        LEFT JOIN 
            houses h ON t.house_id = h.id
        ORDER BY 
            h.house_no DESC
    ";


        $select_stmt = $conn->prepare($select_sql);
        $select_stmt->execute();
        $rows = $select_stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($rows as &$row) {
            $months = abs(strtotime(date('Y-m-d') . " 23:59:59") - strtotime($row['date_in'] . " 23:59:59"));
            $months = floor($months / (30 * 60 * 60 * 24));

            $payable = $row['monthly_rent'] * $months;

            $paid_sql = "SELECT SUM(amount) as paid FROM payments WHERE tenant_id = :tenant_id";
            $paid_stmt = $conn->prepare($paid_sql);
            $paid_stmt->execute(['tenant_id' => $row['id']]);
            $paid = $paid_stmt->fetch(PDO::FETCH_ASSOC)['paid'] ?? 0;

            $last_payment_sql = "SELECT date_created FROM payments WHERE tenant_id = :tenant_id ORDER BY UNIX_TIMESTAMP(date_created) DESC LIMIT 1";
            $last_payment_stmt = $conn->prepare($last_payment_sql);
            $last_payment_stmt->execute(['tenant_id' => $row['id']]);
            $last_payment = $last_payment_stmt->fetch(PDO::FETCH_ASSOC)['date_created'] ?? 'N/A';
            $last_payment = $last_payment !== 'N/A' ? date("M d, Y", strtotime($last_payment)) : 'N/A';

            $outstanding = $payable - $paid;

            $row['payable'] = $payable;
            $row['paid'] = $paid;
            $row['last_payment'] = $last_payment;
            $row['outstanding'] = $outstanding;
        }

        echo json_encode($rows);
    }

    function addTenant($json)
    {
        include("conn.php");
        try {
            $data = json_decode($json, true);

            $insert_sql = "INSERT INTO `tenants`(`firstname`, `middlename`, `lastname`, `email`, `contact`, 
                                                    `house_id`, `date_in`) 
                           VALUES (:firstname, :middlename, :lastname, :email, :contact, :house_id, NOW())";
            $insert_stmt = $conn->prepare($insert_sql);
            $insert_stmt->bindParam(':firstname', $data['firstname']);
            $insert_stmt->bindParam(':middlename', $data['middlename']);
            $insert_stmt->bindParam(':lastname', $data['lastname']);
            $insert_stmt->bindParam(':email', $data['email']);
            $insert_stmt->bindParam(':contact', $data['contact']);
            $insert_stmt->bindParam(':house_id', $data['house_id']);


            if ($insert_stmt->execute()) {
                echo json_encode("1");
            } else {
                echo json_encode("0");
            }
        } catch (Exception $e) {
            echo json_encode("0");
        }

    }

    function updateTenant($json)
    {
        include("conn.php");
        $data = json_decode($json, true);

        $update_sql = "UPDATE `tenants` 
                       SET `firstname` = :firstname, 
                           `middlename` = :middlename,
                           `lastname` = :lastname, 
                           `email` = :email, 
                           `contact` = :contact, 
                           `house_id` = :house_id
                       WHERE `id` = :id";

        $update_stmt = $conn->prepare($update_sql);
        $update_stmt->bindParam(':id', $data['id']);
        $update_stmt->bindParam(':firstname', $data['firstname']);
        $update_stmt->bindParam(':middlename', $data['middlename']);
        $update_stmt->bindParam(':lastname', $data['lastname']);
        $update_stmt->bindParam(':email', $data['email']);
        $update_stmt->bindParam(':contact', $data['contact']);
        $update_stmt->bindParam(':house_id', $data['house_id']);


        if ($update_stmt->execute()) {
            echo json_encode("1");
        } else {
            echo json_encode("0");
        }
    }

    function deleteTenant($json)
    {
        include("conn.php");
        $data = json_decode($json, true);

        $delete_sql = "DELETE FROM `tenants` WHERE `id` = :id";
        $delete_stmt = $conn->prepare($delete_sql);
        $delete_stmt->bindParam(':id', $data['id']);

        if ($delete_stmt->execute()) {
            echo json_encode("1");
        } else {
            echo json_encode("0");
        }
    }

    #endregion

    #region Payments

    function getPayments()
    {
        include("conn.php");
        $select_sql = "SELECT payments.*, tenants.* FROM `payments` JOIN tenants ON payments.tenant_id = tenants.id";
        $select_stmt = $conn->prepare($select_sql);
        $select_stmt->execute();
        $row = $select_stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($row);
    }

    function addPayment($json)
    {
        include("conn.php");
        $data = json_decode($json, true);

        $insert_sql = "INSERT INTO `payments`(`tenant_id`, `amount`, invoice, date_created) VALUES (:tenant_id, :amount, :invoice, NOW())";
        $insert_stmt = $conn->prepare($insert_sql);
        $insert_stmt->bindParam(':tenant_id', $data['tenant_id']);
        $insert_stmt->bindParam(':amount', $data['amount']);
        $insert_stmt->bindParam(':invoice', $data['invoice']);

        if ($insert_stmt->execute()) {
            echo json_encode("1");
        } else {
            echo json_encode("0");
        }
    }

    function updatePayment($json)
    {
        include("conn.php");
        $data = json_decode($json, true);

        $update_sql = "UPDATE `payments` SET `tenant_id` = :tenant_id, `amount` = :amount, `invoice` = :invoice WHERE `id` = :id";
        $update_stmt = $conn->prepare($update_sql);
        $update_stmt->bindParam(':id', $data['id']);
        $update_stmt->bindParam(':tenant_id', $data['tenant_id']);
        $update_stmt->bindParam(':amount', $data['amount']);
        $update_stmt->bindParam(':invoice', $data['invoice']);

        if ($update_stmt->execute()) {
            echo json_encode("1");
        } else {
            echo json_encode("0");
        }
    }

    function deletePayment($json)
    {
        include("conn.php");
        $data = json_decode($json, true);

        $delete_sql = "DELETE FROM `payments` WHERE `id` = :id";
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
            case 'viewTenants':
                $api->getTenants();
                break;
            case 'addTenant':
                $api->addTenant($json);
                break;
            case 'updateTenant':
                $api->updateTenant($json);
                break;
            case 'deleteTenant':
                $api->deleteTenant($json);
                break;
            case 'viewPayments':
                $api->getPayments();
                break;
            case 'addPayment':
                $api->addPayment($json);
                break;
            case 'updatePayment':
                $api->updatePayment($json);
                break;
            case 'deletePayment':
                $api->deletePayment($json);
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