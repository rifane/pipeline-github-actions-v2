resource "aws_key_pair" "kye" {
  key_name   = "aws-key-pipelines"
  public_key = var.aws_key_pub
}

resource "aws_instance" "vm" {
  ami                         = "ami-03250b0e01c28d196" # Ubuntu 20.04 LTS
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.kye.key_name
  subnet_id                   = data.terraform_remote_state.vpc.outputs.subnet_id
  vpc_security_group_ids      = [data.terraform_remote_state.vpc.outputs.security_group_id]
  associate_public_ip_address = true

  tags = {
    Name = "vm-terraform"
  }
}