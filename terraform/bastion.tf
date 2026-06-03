# =====================================================================
# Bastion (jump) host in a PUBLIC subnet.
# The app instances live in private subnets and have no public IP, so the
# GitHub Actions runner cannot SSH to them directly. Ansible connects to
# this bastion first, then hops to each private instance (ProxyJump).
# Same key pair (vockey) and user (ec2-user) as the app instances.
# =====================================================================

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-bastion"
    Role = "bastion"
  }
}
