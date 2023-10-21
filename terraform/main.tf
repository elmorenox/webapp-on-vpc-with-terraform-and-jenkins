# 1 VPC
# 2 AZ's
# 2 Public Subnets
# 2 EC2's
# 1 Route Table
# Security Group Ports: 8080, 8000, 22

#VPC
resource "aws_vpc" "d5_1_vpc" {
    cidr_block = var.vpc_cidr_block

    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "d5.1_vpc"
    }
}

# internet gateway
resource "aws_internet_gateway" "d5_1_internet_gateway" {
    vpc_id = aws_vpc.d5_1_vpc.id
    tags = {
        Name = "d5.1_internet_gateway"
    }
}


# subnets
resource "aws_subnet" "d5_1_public_subnet_1" {
    vpc_id = aws_vpc.d5_1_vpc.id
    cidr_block = var.public_subnet_cidr_blocks.0
    availability_zone = var.availability_zone1
    tags = {
        Name = "d5.1_public_subnet_1"
    }
}

resource "aws_subnet" "d5_1_public_subnet_2" {
    vpc_id = aws_vpc.d5_1_vpc.id
    cidr_block = var.public_subnet_cidr_blocks.1
    availability_zone = var.availability_zone2
    tags = {
        Name = "d5.1_public_subnet_2"
    }
}

# route table
resource "aws_route_table" "d5_1_route_table" {
    vpc_id = aws_vpc.d5_1_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.d5_1_internet_gateway.id
    }
    tags = {
        Name = "d5.1_route_table"
    }
}

# route table <> subnets
resource "aws_route_table_association" "d5_1_public1" {
    subnet_id = aws_subnet.d5_1_public_subnet_1.id
    route_table_id = aws_route_table.d5_1_route_table.id
}

resource "aws_route_table_association" "d5_1_public2" {
    subnet_id = aws_subnet.d5_1_public_subnet_2.id
    route_table_id = aws_route_table.d5_1_route_table.id
}

resource "aws_security_group" "d5_1_sg" {
    name_prefix = "web_"
    vpc_id = aws_vpc.d5_1_vpc.id

ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "d5.1_sg"
    }
}

# EC2s
resource "aws_instance" "webapp" {
  ami = var.ec2_ami
  instance_type = var.ec2_instance_type
  subnet_id = aws_subnet.d5_1_public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.d5_1_sg.id]
  key_name = var.key_name
  associate_public_ip_address = true
  user_data = "webapp-dependencies.sh"
  tags = {
    Name = "d5.1_webapp"
  }
}

resource "aws_instance" "jagent" {
  ami = var.ec2_ami
  instance_type = var.ec2_instance_type
  subnet_id = aws_subnet.d5_1_public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.d5_1_sg.id]
  key_name = var.key_name
  associate_public_ip_address = true
  user_data = file("webapp-dependencies.sh")
  tags = {
    Name = "d5.1_jagent"
  }
}

resource "aws_instance" "d5_1_jenkins_host" {
    ami = var.ec2_ami
    instance_type = var.ec2_instance_type
    subnet_id = aws_subnet.d5_1_public_subnet_2.id
    vpc_security_group_ids = [aws_security_group.d5_1_sg.id]
    key_name = var.key_name
    associate_public_ip_address = true
    user_data = file("jenkins-deploy.sh")
    tags = {
        Name = "d5.1_jenkins_host"
    }
}

output "instance_ips" {
  value = [
    aws_instance.d5_1_jenkins_host.public_ip,
    aws_instance.jagent.public_ip,
    aws_instance.webapp.public_ip
    ]
}