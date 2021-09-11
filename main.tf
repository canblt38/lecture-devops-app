provider "aws" {
  region  = "us-east-1"
    access_key = "ASIAYUOZXJF4X4RMJSIU"
    secret_key = "45hWMNiO0ft6onBVLuS3vSlhj+D+9kq0s4HhuIZS"
    token = "FwoGZXIvYXdzELT//////////wEaDN3lk7eOjxde30itRiLKAamjYXoF+ynTM9cpMZerujRPrmNRdNHtN/xMqbQbvNG6Q5krkhVLgi0vQUwDQqZ/mhr1JePyxmK2x7ML7vwOn6uDpuYqEWb1Dpoos7D+1a3uBChkt/gPHJMg6tX3nT5sze1I2YiNw7qejt3lh5i9adhCNe/Hsj0ajegShpv1JTP9nOHiDQ11pxAIy4TrR2vVecmadVP96VBFsvqMK6sQVgT225iUjofFi0u8Ha32k0vQ/HExn+uYLbxZPQ5pEjlubOjpTSmi+xQNGy0o4ZDyiQYyLUnqKGukJVMs2zQ4dfO4R71tlSx90cmZj/UDUSTspZeJ2K+M5gtBQZemlZJ4Xg=="
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC34wEs0VITQvGRysbtzS1bDm65qIcJmhHWWvsdIvMHYAvaII6QMA5Nisbp+1pOm66XiQN516cTTfqZhlAcJnNLc2FgiUlzhv7gh28+QNYspyOjQb48F3CXs5jqAi3v+/m+f1rUnGFF6wufV3k+Rb58uF/Srwzb1XuzzQp2MEgnfX/6S7t1afIpVVBACEjndYbWViwNiFSmAT/eMsBBbT0eGJx+ZDMZFWEUkW0zzZbnXWaOmUaKgfcZL714z64v6fjcja8tnIrOJJU1PIY56COzIA2pEIqrWOPwbRlg0gv8E9+WHoFlyV+d11QzwVB+ds2/s4JbUzkgas4rhrqEpcdN can@DESKTOP-I4736MD"
}

output "mongo_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.mongo.public_ip
}

resource "aws_instance" "mongo" {
  ami = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.key_name

    user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo amazon-linux-extras install epel -y
    sudo yum install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker run --network="host" --name some-mongo -d mongo:latest
  EOF

  tags = {
    "Name" = "MogoDB"
  }
}

resource "aws_security_group_rule" "http-connection" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "sg-cd9a44ca"
}

resource "aws_security_group_rule" "ssh-connection" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "sg-cd9a44ca"
}

# security group for instances
resource "aws_security_group" "custom-instance-sg" {
  vpc_id = aws_vpc.custom-vpc.id
  name        = "custom-instance-sg"
  description = "Allow ssh inbound traffic"

  ingress {
        description      = "ssh from VPC"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        security_groups = [aws_security_group.custom-elb-sg.id]
    }

    ingress {
        description      = "ssh from VPC"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks       = ["0.0.0.0/0"]
    }

    ingress {
        description      = "ssh from VPC"
        from_port        = 3000
        to_port          = 3000
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
      Name= "custom-instance-sg"
    }
}
# security group for aws elb
resource "aws_security_group" "custom-elb-sg" {
  vpc_id = aws_vpc.custom-vpc.id
  name        = "custom-elb-sg"
  description = "security group for ELB"

  ingress {
        description      = "ssh from VPC"
        from_port        = 443
        to_port          = 443
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
      Name= "custom-elb-sg"
    }
}

/* resource "aws_security_group_rule" "port-tcp" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  description       = "open tcp test"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.custom-instance-sg.id
} */

resource "aws_launch_configuration" "custom-launch-config" {
  name = "custom-launch-config"
  image_id = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.key_name
  security_groups   = [aws_security_group.custom-instance-sg.id]

     user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo amazon-linux-extras install epel -y
    sudo yum install stress -y
    sudo yum install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo yum install git -y
    git clone https://github.com/canblt38/lecture-devops-app.git
    cd lecture-devops-app
    imageName=my-image
    containerName=my-container
    sudo docker build -t $imageName -f Dockerfile  .
    sudo docker run -e MONGODB_URL=mongodb://${aws_instance.mongo.public_ip}:27017/todo-app --network="host"  -d -p 3000:3000 --name $containerName $imageName
  EOF

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "custom-group-autoscaling" {
    name = "custom-group-autoscaling"
    vpc_zone_identifier = [ aws_subnet.customvpc-public-1.id,aws_subnet.customvpc-public-2.id ]
    launch_configuration = aws_launch_configuration.custom-launch-config.name
    min_size = 1
    max_size = 2
    health_check_grace_period = 100
    health_check_type = "EC2"
    load_balancers = [aws_elb.custom-elb.name]
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
  scaling_adjustment = 1
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
      AutoScalingGroupName = aws_autoscaling_group.custom-group-autoscaling.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.custom-cpu-policy.arn]
}

# AWS ELB config
resource "aws_elb" "custom-elb" {
  name               = "custom-elb"
  subnets = [aws_subnet.customvpc-public-1.id,aws_subnet.customvpc-public-2.id]
  security_groups   = [aws_security_group.custom-elb-sg.id]

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
    ssl_certificate_id = aws_iam_server_certificate.test_cert.arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:3000/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "custom-elb"
  }
}

// ssl certificate
resource "aws_iam_server_certificate" "test_cert" {
  name             = "todo-certificate"
  certificate_body = file("./todocert.pem")
  private_key      = file("./todo-key.pem")
}

# create AWS VPC
resource "aws_vpc" "custom-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_classiclink = true

  tags = {
    "Name" = "custom-vpc"
  }
}

# public subnets in the vpc
resource "aws_subnet" "customvpc-public-1" {
  vpc_id = aws_vpc.custom-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
    "Name" = "customvpc-public-1"
  }
}

resource "aws_subnet" "customvpc-public-2" {
  vpc_id = aws_vpc.custom-vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1c"
  tags = {
    "Name" = "customvpc-public-2"
  }
}

resource "aws_internet_gateway" "customvpc-ig" {
  vpc_id = aws_vpc.custom-vpc.id

  tags = {
      Name ="customvpc-ig"
  }
}

resource "aws_route_table" "customvpc-r" {
    vpc_id = aws_vpc.custom-vpc.id

    route {
          cidr_block = "0.0.0.0/0"
          gateway_id = aws_internet_gateway.customvpc-ig.id
    }

     tags = {
      Name ="customvpc-r"
  }
}

resource "aws_route_table_association" "customvpc-public-1-a" {
  subnet_id = aws_subnet.customvpc-public-1.id
  route_table_id = aws_route_table.customvpc-r.id
}

resource "aws_route_table_association" "customvpc-public-2-a" {
  subnet_id = aws_subnet.customvpc-public-2.id
  route_table_id = aws_route_table.customvpc-r.id
}

