#aws resources

resource "aws_vpc" "Terraform_vpc" {
  cidr_block           = var.vpc_ip
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Dev"
  }
}

resource "aws_subnet" "Terraform_subnet" {
  vpc_id                  = aws_vpc.Terraform_vpc.id
  cidr_block              = var.subnet_ip
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Dev_public"
  }
}

resource "aws_internet_gateway" "Terraform_IGW" {
  vpc_id = aws_vpc.Terraform_vpc.id

  tags = {
    Name = "Dev_IGW"
  }
}

resource "aws_route_table" "Terraform_public_rt" {
  vpc_id = aws_vpc.Terraform_vpc.id

  tags = {
    Name = "Dev_public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.Terraform_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Terraform_IGW.id
}

resource "aws_route_table_association" "Terraform_public_association" {
  subnet_id      = aws_subnet.Terraform_subnet.id
  route_table_id = aws_route_table.Terraform_public_rt.id

}

resource "aws_security_group" "Terraform_sg" {
  name        = "Dev_sg"
  description = "Dev_security_group"
  vpc_id      = aws_vpc.Terraform_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.my_ip] #(/32 means I only want to use this address)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #allow subnet to access the open internet!
  }
}

resource "aws_key_pair" "Terraform_auth" {
  key_name   = "Terraform_key"
  public_key = file("~/.ssh/Terraform_key.pub")
}

resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.Terraform_server_ami.id
  key_name               = aws_key_pair.Terraform_auth.id
  vpc_security_group_ids = [aws_security_group.Terraform_sg.id]
  subnet_id              = aws_subnet.Terraform_subnet.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev_node"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname =self.public_ip, 
      user = "ubuntu",
      identityfile = "~/.ssh/Terraform_key"
    })
    interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["windows", "-command"]
  }
}

