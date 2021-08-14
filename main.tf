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
    access_key = "ASIAYUOZXJF44SB3TQ5W"
    secret_key = "1e0yZlICJeastSnFmVNlQ+p5UIZlS/p4zTVl9dPV"
    token = "FwoGZXIvYXdzEBYaDKEqZSCkHyQ6SabVlCLKAd1SXAfVHtJHpS7NR/E9hh1lPyi2npAGWKtik7/qMlRxfbffhRUPdM6BU3sklr7Yk7HLMOWzJGfk61jLsIUNqMaHU8osRi24kch92mS9MQrfadMcZIlfRS1185xP3qLzUSOxD09DZWiTy7Yx3A10jq04t0hbKfKzWkeYQmb5RZruQfbm8uFHoNHgWQcOyhDex/OO6WWEBD1tWnIlZKkCwzQ/tkl12PSt7/x3qQl1H5+btXQeIZTVDGoVM6TLep7te1u6cUcWSee/7B8o7PHeiAYyLdrjASe9I8iTuUO3k0dkKsUI3+vdMZSfEswmCyTwftzUYo60MpHHuLP7low9Kw=="
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC34wEs0VITQvGRysbtzS1bDm65qIcJmhHWWvsdIvMHYAvaII6QMA5Nisbp+1pOm66XiQN516cTTfqZhlAcJnNLc2FgiUlzhv7gh28+QNYspyOjQb48F3CXs5jqAi3v+/m+f1rUnGFF6wufV3k+Rb58uF/Srwzb1XuzzQp2MEgnfX/6S7t1afIpVVBACEjndYbWViwNiFSmAT/eMsBBbT0eGJx+ZDMZFWEUkW0zzZbnXWaOmUaKgfcZL714z64v6fjcja8tnIrOJJU1PIY56COzIA2pEIqrWOPwbRlg0gv8E9+WHoFlyV+d11QzwVB+ds2/s4JbUzkgas4rhrqEpcdN can@DESKTOP-I4736MD"
}

/* output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
} */

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
resource "aws_security_group_rule" "port-tcp" {
  type              = "ingress"
  from_port         = 2998
  depends_on = [
    aws_security_group.allow_ssh
  ]
  to_port           = 3001
  description       = "open tcp test"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "sg-0a581cb7401eed5f0"
}

/* resource "aws_route53_zone" "easy_aws" {
    name ="easyaws.de"
    tags = {
        Enverioment="dev"
    }
}

resource "aws_route53_record" "www" {

  zone_id = aws_route53_zone.easy_aws.zone_id
  name    = "easyaws.de"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.eip.public_ip]
}

output "name_server" {
  value = aws_route53_zone.easy_aws.name_servers
}

resource "aws_eip" "eip" {
  instance = aws_instance.app_server.id
  vpc = true
}

output "public_ip" {
  value= aws_instance.app_server.public_ip
}
 */
data "aws_availability_zones" "available" {}

resource "aws_launch_configuration" "custom-launch-config" {
  name = "custom-launch-config"
  image_id = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.key_name
  security_groups   = [aws_security_group.allow_ssh.id]

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
    sudo mkdir test
    git clone https://github.com/canblt38/lecture-devops-app.git
    cd lecture-devops-app
    imageName=xx:my-image
    containerName=my-container
    sudo docker build -t $imageName -f Dockerfile  .
    sudo docker run  --network="host"  -d -p 3000:3000 --name $containerName $imageName
  EOF
}

resource "aws_autoscaling_group" "custom-group-autoscaling" {
    name = "custom-group-autoscaling"
    vpc_zone_identifier = [ "subnet-ad474ce0" ]
    launch_configuration = aws_launch_configuration.custom-launch-config.name
    min_size = 1
    max_size = 3
    health_check_grace_period = 100
    health_check_type = "EC2"
    force_delete = true

    tag {
        key="Name"
        value="ToDoAutoscaling"
        propagate_at_launch=true
    }
}

resource "aws_autoscaling_policy" "custom-cpu-policy" {
  name = "custom-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.custom-group-autoscaling.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = 3
  cooldown = 60
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "custom-cpu-alarm" {
  alarm_name = "custom-cpu-alarm"
  alarm_description = "alarm once cpu usage increses"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 20

  dimensions = {
      AutoscalingGroudName = aws_autoscaling_group.custom-group-autoscaling.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.custom-cpu-policy.arn]
}


