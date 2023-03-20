#aws data
data "aws_ami" "Terraform_server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] #I could put an "*" in place of the date so that any date qualifies
  }
}
