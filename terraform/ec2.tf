# =====================================================================
# App EC2 instances (in PRIVATE subnets) + ALB target group attachment.
# AMI is resolved dynamically (latest Amazon Linux 2) so it works in any
# region without hardcoding an AMI ID. Outbound internet is via the NAT
# gateways, so Ansible can yum-install Docker and pull images.
# =====================================================================

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  count                  = var.instance_count
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.private[count.index % length(aws_subnet.private)].id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  tags = {
    Name = "${var.project_name}-web-${count.index + 1}"
    Role = "web"
  }
}

resource "aws_lb_target_group_attachment" "web" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}
