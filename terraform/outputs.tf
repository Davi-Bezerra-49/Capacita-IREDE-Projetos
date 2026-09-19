# outputs.tf
# Informações mostradas ao final do "terraform apply"

output "ec2_public_ip" {
  description = "IP público da EC2 onde a API está rodando"
  value       = aws_instance.api_server.public_ip
}

output "sqs_queue_url" {
  description = "URL da fila SQS"
  value       = aws_sqs_queue.pedidos.url
}

output "lambda_function_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.processa_pedido.function_name
}
