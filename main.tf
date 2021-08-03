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
    access_key = "ASIAYUOZXJF4SMHQ6BU7"
    secret_key = "gCCfK1UvRIthvwpQcjmU5E6bAVPAMNYK8Dz9uMYl"
    token = "FwoGZXIvYXdzEA8aDBSxzDRKt4FEFJivAiLKAXecaq9WjcqbPSjqQW0KC9XWJfEPEqHK21GuSbeksap59DfqxN5GQkJrAXcWD8+FtlwEcEr2QVJHv+RMcVHCNe+hEeb2azMMuTyQbzfVQaLaf2tvjWsKAswNlNc2EhYxyN5JEMIOf9NsC+q3/BOswGS20JJi5jOixhHzvLVxKG9xFreSfnoYxuAQ0gZofxO27u5mmllb23z+inbGiP82A5VAJK+CMhrk0+sfFwXS/ZiW3+902PQAkvu2BygWT4g4a+o8VXmS+/+RbtQop42liAYyLZQ1wuB8E618vlgQ3lq23e1q1i+kTkFJwQh5IZ2lmL742qqFa7OVaUWOc26cHQ=="
}

resource "aws_instance" "app_server" {
    key_name   = aws_key_pair.deployer.key_name
    security_groups   = [aws_security_group.allow_ssh.name]
    ami           = "ami-0db6c6238a40c0681"
    instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "AAAAB3NzaC1yc2EAAAADAQABAAABAQC34wEs0VITQvGRysbtzS1bDm65qIcJmhHWWvsdIvMHYAvaII6QMA5Nisbp+1pOm66XiQN516cTTfqZhlAcJnNLc2FgiUlzhv7gh28+QNYspyOjQb48F3CXs5jqAi3v+/m+f1rUnGFF6wufV3k+Rb58uF/Srwzb1XuzzQp2MEgnfX/6S7t1afIpVVBACEjndYbWViwNiFSmAT/eMsBBbT0eGJx+ZDMZFWEUkW0zzZbnXWaOmUaKgfcZL714z64v6fjcja8tnIrOJJU1PIY56COzIA2pEIqrWOPwbRlg0gv8E9+WHoFlyV+d11QzwVB+ds2/s4JbUzkgas4rhrqEpcdN"
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
}
