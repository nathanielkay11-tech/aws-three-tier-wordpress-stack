# =====================================================================
# SECTION 1: THE NETWORK EDGE (VPC & Internet Gateway)
# =====================================================================

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Prod-app-vpc"
  }
}

resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "Prod-IGW"
  }
}

# =====================================================================
# SECTION 2: THE SUBNETS (Public, App, and Data)
# =====================================================================

resource "aws_subnet" "prod_pub_sub_1a" {
  vpc_id     = aws_vpc.prod_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
 
 tags= {
    Name = "Prod-pub-sub-1a"
  }
} 

resource "aws_subnet" "prod_app_sub_1a" {
  vpc_id     = aws_vpc.prod_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
 
 tags= {
    Name = "Prod-app-sub-1a"
  }
} 

resource "aws_subnet" "prod_data_sub_1a" {
  vpc_id     = aws_vpc.prod_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
 
 tags= {
    Name = "Prod-data-sub-1a"
  }
} 

resource "aws_subnet" "prod_pub_sub_1b" {
  vpc_id     = aws_vpc.prod_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
 
 tags= {
    Name = "Prod-pub-sub-1b"
  }
} 

resource "aws_subnet" "prod_app_sub_1b" {
  vpc_id     = aws_vpc.prod_vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1b"
 
 tags= {
    Name = "Prod-app-sub-1b"
  }
} 

resource "aws_subnet" "prod_data_sub_1b" {
  vpc_id     = aws_vpc.prod_vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "us-east-1b"
 
 tags= {
    Name = "Prod-data-sub-1b"
  }
} 

# =====================================================================
# SECTION 3: THE GATEWAYS (Elastic IPs & NAT Gateways)
# =====================================================================

resource "aws_eip" "nat_eip_1a" {
domain = "vpc"

tags = {
  Name = "Prod-NAT-EIP-1a"
}
}

resource "aws_nat_gateway" "prod_nat_gw_1a" {
  allocation_id = aws_eip.nat_eip_1a.id
  subnet_id     = aws_subnet.prod_pub_sub_1a.id

  tags = {
    Name = "Prod-NAT-GW"
  }
}

resource "aws_eip" "nat_eip_1b" {
domain = "vpc"

tags = {
  Name = "Prod-NAT-EIP-1b"
}
}

resource "aws_nat_gateway" "prod_nat_gw_1b" {
  allocation_id = aws_eip.nat_eip_1b.id
  subnet_id     = aws_subnet.prod_pub_sub_1b.id

  tags = {
    Name = "Prod-NAT-GW"
  }
}

# =====================================================================
# SECTION 4: THE ROUTE TABLES (Mapping the Traffic)
# =====================================================================

resource "aws_route_table" "prod_pub_rt" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "Prod-pub-rt"
  }

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_igw.id

}
}

resource "aws_route_table_association" "prod_pub_rt_assoc_1a" {
  subnet_id      = aws_subnet.prod_pub_sub_1a.id
  route_table_id = aws_route_table.prod_pub_rt.id
}

resource "aws_route_table_association" "prod_pub_rt_assoc_1b" {
  subnet_id      = aws_subnet.prod_pub_sub_1b.id
  route_table_id = aws_route_table.prod_pub_rt.id
}

resource "aws_route_table" "prod_priv_rt_1a" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "Prod-priv-rt-1a"
  }

route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.prod_nat_gw_1a.id

}
}

resource "aws_route_table_association" "prod_priv_rt_assoc_1a" {
  subnet_id      = aws_subnet.prod_app_sub_1a.id
  route_table_id = aws_route_table.prod_priv_rt_1a.id
}

resource "aws_route_table" "prod_priv_rt_1b" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "Prod-priv-rt-1b"
  }

route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.prod_nat_gw_1b.id

}
}

resource "aws_route_table_association" "prod_priv_rt_assoc_1b" {
  subnet_id      = aws_subnet.prod_app_sub_1b.id
  route_table_id = aws_route_table.prod_priv_rt_1b.id
}

# =====================================================================
# SECTION 5: THE FIREWALLS (Security Groups)
# =====================================================================

resource "aws_security_group" "alb_sg" {
  name        = "Prod-ALB-SG"
  description = "Allow HTTP and HTTPS traffic to ALB"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description      = "Allow HTTP traffic from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Prod-ALB-SG"
  }
}

resource "aws_security_group" "web_tier_sg" {
  name        = "Prod-Web-SG"
  description = "Allow traffic only from the ALB security group"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description      = "Allow HTTP traffic from ALB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Prod-Web-SG"
  }
}

resource "aws_security_group" "db_tier_sg" {
  name        = "Prod-DB-SG"
  description = "Allow traffic only from the Web tier security group"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description      = "Allow MySQL traffic from Web tier"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.web_tier_sg.id]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Prod-DB-SG"
  }
}

# =====================================================================
# SECTION 6: THE COMPUTE TIER (ALB & Auto Scaling Group)
# =====================================================================

resource "aws_lb_target_group" "prod_tg" {
  name     = "Prod-Wordpress-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.prod_vpc.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200-299"
  }

  tags = {
    Name = "Prod-TG"
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "prod_lt" {
  name_prefix   = "Prod-Wordpress-LT-"
  image_id = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_tier_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
              yum install -y httpd mariadb-server
              
              # --- CASE STUDY FIX ---
              # Applying permissions fix discovered in Case Study Section 4
              chown -R apache:apache /var/www/html
              chmod -R 755 /var/www/html
              
              systemctl start httpd
              systemctl enable httpd
              EOF
  )

  tags = {
    Name = "Prod-LT"
  }
}

resource "aws_lb" "prod_alb" {
  name               = "Prod-Wordpress-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.prod_pub_sub_1a.id, aws_subnet.prod_pub_sub_1b.id]

  tags = {
    Name = "Prod-ALB"
  }
}

resource "aws_lb_listener" "prod_listener" {
  load_balancer_arn = aws_lb.prod_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_tg.arn
  }
}

resource "aws_autoscaling_group" "prod_asg" {
  name                      = "Prod-Wordpress-ASG-1a"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  launch_template {
    id      = aws_launch_template.prod_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [aws_subnet.prod_app_sub_1a.id, aws_subnet.prod_app_sub_1b.id]
  target_group_arns        = [aws_lb_target_group.prod_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "Prod-ASG-Instance"
    propagate_at_launch = true
  }
}
# =====================================================================
# SECTION 7: THE DATABASE TIER (RDS MariaDB)
# =====================================================================

resource "aws_db_subnet_group" "prod_db_subnet_group" {
  name       = "prod-wordpress-db-subnet-group"
  subnet_ids = [aws_subnet.prod_data_sub_1a.id, aws_subnet.prod_data_sub_1b.id]

  tags = {
    Name = "Prod-DB-Subnet-Group"
  }
}

resource "aws_db_instance" "prod_db_instance" {
  identifier              = "prod-wordpress-db"
  allocated_storage       = 20
  
  # MATCHES YOUR CASE STUDY!
  engine                  = "mariadb"
  engine_version          = "10.11" # A valid, modern MariaDB version
  
  instance_class          = "db.t3.micro"
  db_name                 = "wordpress_storage_db" 
  username                = "admin"
  password                = var.db_password
  
  db_subnet_group_name    = aws_db_subnet_group.prod_db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_tier_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = {
    Name = "Prod-DB-Instance"
  }
}