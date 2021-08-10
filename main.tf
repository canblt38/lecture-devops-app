terraform {
    backend "remote" {
        organization = "SemesterabgabeDevOps"

        workspaces {
            name = "BulutDevOps"
        }
    }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.15.1"
}

provider "aws" {
  region  = "us-east-1"
    access_key = "ASIAYUOZXJF4S6XG3BP2"
    secret_key = "vJ6D1DO6g1FHl4pWXiFbamOGkkTjWdkQvvGxN2um"
    token = "FwoGZXIvYXdzELH//////////wEaDMoit1TwxBoItb5rCyLKAcX6rTI1kMZLOFvK0Z2+bZDysotJ90tBrCOIIe0VXZnIsUBhrQr91jTvsHFIp17SkB0saNFC6iqi17OMpD8bxGD6ER8hAJf4DGh1LIq7qMBSDqUqcHE1Cq1XdMGZnzCSOB/UAIPPDsdI3OzW8Hvb9CtBL7O+yClsR9ol7CHmAAsjOqF3iJCR0My7nIiFx1l5QlJMCBR9ZYYGF4HBkFQl96ufBJFt34fvj79cJ9uAVxU4CIchKMYA9tOKR/ILXogLjCmBpmKENtuiX1go0NTIiAYyLUPHPGYuJEPzYKj+yUSqGCwmcRSvbKVNNOzQPp/ExmV6Tgk1zCCmOjs/nmlKVw=="
}

resource "aws_instance" "app_server" {
    key_name   = aws_key_pair.deployer.key_name
    security_groups   = [aws_security_group.allow_ssh.name]
    ami           = "ami-0c2b8ca1dad447f8a"
    instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }

   user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo yum install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    cd /etc/yum.repos.d/
    sudo bash -c "echo -e \"[mongodb-org-5.0]\nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/\ngpgcheck=1\nenabled=1\ngpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc\" >> mongodb-org-5.0.repo"
    sudo yum install -y mongodb-org
    sudo systemctl start mongod
    sudo systemctl daemon-reload
    sudo systemctl status mongod
    sudo yum install git -y
    mkdir git
    git clone https://github.com/canblt38/lecture-devops-app.git
    cd lecture-devops-app
    docker build -t todoapp .
    docker run -p 3000:3000 -d todoapp
  EOF
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC34wEs0VITQvGRysbtzS1bDm65qIcJmhHWWvsdIvMHYAvaII6QMA5Nisbp+1pOm66XiQN516cTTfqZhlAcJnNLc2FgiUlzhv7gh28+QNYspyOjQb48F3CXs5jqAi3v+/m+f1rUnGFF6wufV3k+Rb58uF/Srwzb1XuzzQp2MEgnfX/6S7t1afIpVVBACEjndYbWViwNiFSmAT/eMsBBbT0eGJx+ZDMZFWEUkW0zzZbnXWaOmUaKgfcZL714z64v6fjcja8tnIrOJJU1PIY56COzIA2pEIqrWOPwbRlg0gv8E9+WHoFlyV+d11QzwVB+ds2/s4JbUzkgas4rhrqEpcdN can@DESKTOP-I4736MD"
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"

  ingress {
    description      = "ssh from VPC"
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
      ipv6_cidr_blocks = ["::/0"]
    }

}
