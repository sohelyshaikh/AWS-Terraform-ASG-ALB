resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "local_file" "b_key" {
  filename          = "bastion_key.pem"
  sensitive_content = tls_private_key.key.private_key_pem
  file_permission   = "0400"
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = tls_private_key.key.public_key_openssh
}
