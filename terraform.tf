provider "aws" {
  region = "${var.AWS_REGION}"
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
}
#create vpc
resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
}
}
#create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.first-vpc.id

}

#create custom route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

#create subnet
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.first-vpc.id
  #cidr_block       = "10.0.1.0/24"
  cidr_block        = var.subnet_prefix[0].cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = var.subnet_prefix[0].name
  }
}

#create associate route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.prod-route-table.id
}

#create security group
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.first-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

#create network interface
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.my_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

#create instance ec2
resource "aws_instance" "first-server" {
  ami           = "ami-005de95e8ff495156"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "main-key"
  security_groups = ["${aws_security_group.allow_web.name"}"]

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
              #! /bin/bash
              sudo apt update -y
              sudo apt-get install python3
              python -m venv .
              python -m venv exvenv
              . exven/bin/activate
              pip install flask
              pip install -r requirements.txt
              python3 app.py
              python3 test_hello.py
              docker build -t dina2022/flaskdocker .
              docker push
              docker run -d -p 9999:9999 --name new-app dina2022/flaskdocker
              kubectl apply -f flask-deployment.yaml
              kubectl apply -f node-port.yaml
              EOF
  tags = {
    Name = "ubuntu"
  }
}
