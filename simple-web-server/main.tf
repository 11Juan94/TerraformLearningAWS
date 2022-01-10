variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

provider "aws" {
    region = "us-east-2"
}

resource "aws_instance" "example" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance.id ]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p ${var.server_port} &
    EOF

  tags = {
    "Name" = "terraform-example"
  }
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  description = "Ingress rule for webserver"
  
  ingress = [ {
    description = "Ingress rule for hello world"
    security_groups = [ ]
    ipv6_cidr_blocks = [ ]
    prefix_list_ids = [ ]
    self = false
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  } ]

  egress = [{
    description = "Egress traffic"
    security_groups = [ ]
    self = false
    prefix_list_ids = [ ]
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }]
}