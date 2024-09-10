resource "aws_security_group" "ike_sg" {
  vpc_id = aws_vpc.ikec7.id
  description = "Allow inbound treffic"
  name        = "allow_tls"

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
 }

  egress  {
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    to_port = 0

  }

  tags = {
    Name = "private_sg"
  }
}

output "name" {
  value = "${aws_security_group.ike_sg.id}"
}


resource "aws_instance" "ikepub" {
  ami           = "ami-0182f373e66f89c85" # us-west-1a  
  instance_type = "t2.micro"
  subnet_id      = aws_subnet.ike_pub.id
  associate_public_ip_address = "true"
  vpc_security_group_ids  = ["${aws_security_group.ike_sg.id}"]
  key_name = "myaws"
  count = 1

 
  tags = {
    Name = "IkeC7_server"
  }

}

resource "aws_instance" "ikepriv" {
  ami           = "ami-0182f373e66f89c85" # us-west-1b
  instance_type = "t2.micro"
  subnet_id      = aws_subnet.ike_priv.id
  vpc_security_group_ids  = ["${aws_security_group.ike_sg.id}"]
  associate_public_ip_address = "false"


  key_name = "myaws"

 
  tags = {
    Name = "IkeC7_database"
  }

}