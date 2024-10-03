# Get latest Windows Server 2019 AMI
data "aws_ami" "windows-2019" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }
}

resource "aws_instance" "web" {
  ami                  = data.aws_ami.windows-2019.id
  instance_type        = var.ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  subnet_id            = var.ec2_subnet

  tags = {
    "Name" = "test-scripts-server"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}