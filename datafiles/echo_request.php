<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
$miniFiles = [];
foreach ($_FILES as $fileKey => $file) {
  $miniFiles[$fileKey] = [
    'name' => $file['name'],
    'type' => $file['type'],
    'error' => $file['error'],
    'size' => $file['size'],
    'md5' => md5_file($file['tmp_name']),
  ];
}
echo json_encode(['GET' => $_GET, 'POST' => $_POST, 'FILES' => $miniFiles]);
