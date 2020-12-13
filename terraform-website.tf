provider "aws" {
  region = "us-east-2"
}

#Create the Security Group
resource "aws_security_group" "webserver_sg" {
  name        = "Ports 22-80"
  description = "Ports 22-80"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create An EC2 Instance
resource "aws_instance" "web-server" {
  ami                    = "ami-09558250a3419e7d0"
  instance_type          = "t2.micro"
  key_name               = "terraform2"
  vpc_security_group_ids = ["${aws_security_group.webserver_sg.id}"]

  tags = {
    Name = "WebServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install git -y",
      "sudo yum install httpd -y",
      "sudo service httpd start",
      "sudo chkconfig httpd on",
      "cd /var/www/html/",
      "sudo git clone https://github.com/cawoodruff/SimpleWebsite.git",
      "cd ./SimpleWebsite",
      "sudo cp -R * ../"
    ]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("terraform2.pem")
    }
  }
}

output "instance_ip_addr" {
  value       = aws_instance.web-server.public_ip
  description = "Web Server IP Address: "
}