#!/bin/bash
# Este script roda automaticamente quando a EC2 sobe (via Terraform)
# Instala Python, Flask, boto3 e inicia a API já configurada com a fila SQS.

yum update -y
yum install -y python3 python3-pip

mkdir -p /home/ec2-user/app
cat > /home/ec2-user/app/app.py << 'PYEOF'
${app_py_content}
PYEOF

pip3 install flask boto3

cat > /etc/systemd/system/api.service << 'SERVICEEOF'
[Unit]
Description=API Capacita iRede
After=network.target

[Service]
Environment=AWS_REGION=${aws_region}
Environment=SQS_QUEUE_URL=${sqs_queue_url}
WorkingDirectory=/home/ec2-user/app
ExecStart=/usr/bin/python3 /home/ec2-user/app/app.py
Restart=always
User=ec2-user

[Install]
WantedBy=multi-user.target
SERVICEEOF

systemctl daemon-reload
systemctl enable api.service
systemctl start api.service
