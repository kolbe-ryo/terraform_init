resource "aws_db_instance" "wordpress" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t3.micro"
  db_name                 = "wpdb"
  username                = "dba"
  password                = random_password.wordpress.result
  parameter_group_name    = "default.mysql5.7"
  multi_az                = false
  db_subnet_group_name    = aws_db_subnet_group.db.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  backup_retention_period = "7"
  backup_window           = "01:00-02:00"
  skip_final_snapshot     = true
  max_allocated_storage   = 200
  identifier              = "wordpress"
  tags = {
    Name = "WordPress DB"
  }
}

resource "random_password" "wordpress" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_instance" "web" {
  ami           = "ami-0eba6c58b7918d3a1"
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = aws_network_interface.web.id
    device_index         = 0
  }
  user_data = file("wordpress.sh")
  tags = {
    Name = "web"
  }
}
resource "aws_network_interface" "web" {
  subnet_id       = aws_subnet.public.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.web.id]
}

resource "aws_eip" "wordpress" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip_association" "wordpress" {
  allocation_id        = aws_eip.wordpress.id
  network_interface_id = aws_network_interface.web.id
}
