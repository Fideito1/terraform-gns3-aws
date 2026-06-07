#!/bin/bash

apt update -y
apt install -y apache2 curl

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Servidor WEB SRI</title>
</head>
<body>
  <h1>Servidor WEB SRI</h1>
  <p>Servidor desplegado automaticamente mediante Terraform.</p>
</body>
</html>
EOF

systemctl enable apache2
systemctl start apache2

echo "Servidor WEB SRI desplegado correctamente" > /etc/motd