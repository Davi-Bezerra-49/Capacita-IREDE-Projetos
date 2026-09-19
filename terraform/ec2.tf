# ec2.tf
# Instância EC2 que roda as APIs (Produtos e Pedidos)

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "api_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    app_py_content = file("${path.module}/../api/app.py")
    aws_region     = var.aws_region
    sqs_queue_url  = aws_sqs_queue.pedidos.url
  })

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
