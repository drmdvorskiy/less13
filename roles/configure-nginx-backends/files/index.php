<?php
//DEBUGGING
//phpinfo();
ini_set('display_errors', '1');
error_reporting(E_ALL);


//DB SETTINGS
define('address', "192.168.6.7");
define('username', "root");
define('password', "root");
define('schema', "mysql");
$res = '';


header($_SERVER["SERVER_PROTOCOL"]." 200 OK");
    echo '<!doctype html><html lang="ru"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'."\n";
    echo '<title>LIST OF DATABASES</title></head><body><div class="container">'."\n";



$mysqli = mysqli_connect(address, username, password, schema);
$result = mysqli_query($mysqli, "SHOW DATABASES;");

while ($row = mysqli_fetch_array($result, MYSQLI_NUM)) {
printf("%s<br>\n", $row[0]);
}

?>
