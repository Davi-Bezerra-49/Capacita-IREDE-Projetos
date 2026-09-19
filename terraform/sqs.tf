# sqs.tf
# Fila SQS que recebe os pedidos enviados pela API

resource "aws_sqs_queue" "pedidos" {
  name                      = "pedidos-a-processar"
  message_retention_seconds = 86400 # 1 dia

  tags = {
    Name = "${var.project_name}-fila-pedidos"
  }
}
