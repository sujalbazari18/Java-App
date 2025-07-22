// Configure AWS provider
provider "aws" {
  region = "ap-south-1"  # Use your preferred region
}



//Create the VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}



// Add a public Subnet
resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}



// Add Internet GateWay 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}


// Add Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


//Associate route table with subnet 

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.rt.id
}



//Add Security Group
resource "aws_security_group" "sg" {
  name   = "allow_ssh_http"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Sujal" {
  ami           = "ami-0f5ee92e2d63afc18" # Ubuntu for ap-south-1
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name      = var.key_name
  associate_public_ip_address = true
}
