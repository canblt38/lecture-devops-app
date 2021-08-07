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
/*     docker = {
      source  = "kreuzwerker/docker"
      version = "2.14.0"
    } */

  }

  required_version = ">= 0.15.1"
}

/* provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Pulls the image
resource "docker_image" "mongo" {
  name = "mongo:latest"
}

# Create a container
resource "docker_container" "foo" {
  image = docker_image.mongo.latest
  name  = "foo"
} */

provider "aws" {
  region  = "us-east-1"
    access_key = "ASIAYUOZXJF4YC7S4MLF"
    secret_key = "o1Uqtu/Ogg+mDTljLX8oeOEQFIJ15VwdkKFoACka"
    token = "FwoGZXIvYXdzEGwaDGspxeNk6hy3mwUOJyLKAS1F2wdLGTrz0TeuuOcmRb/RCNg2uRg4xZnxJ08TtwgobTmpU8MQ2OKJwCg3YDadLc561lGS5hZq9fLnGz1S0zQYX7uOdGVSEOPqg8k0kexEVSClTBdhc8O4HM3kAeC3F259CwgE3mX3L+gff6CFxnBX+LYqs4NsM1NgkJaPkqauIKsEauITbzEfeiBy09iktRgHD+xHZ4Z7XC3hteUtmz+mXDX/oClmFF+igiycv2TmegM8xFr6vDCKrXWCD+uT5DIWeB/xvNHA6dIovsO5iAYyLa77xg8gGrfgREY764Hvtbx+Q+/fuaF+whEksge81pHduGt01aiR4Z3XzGoWiw=="
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
}
