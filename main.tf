
terraform{
    required_providers {
      aws ={
        source = "hashicorp/aws"
        version= "~>3.0"
      }
       
    }
}
#create a providor block
provider "aws" {
    region = "us-east-2"
    access_key = var.access_key
    secret_key = var.secret_key
   
}

#Create VPC resource
resource "aws_vpc" "myLab-aws_vpc" {
    cidr_block= var.cidr_block[0]
    tags ={
        Name= "myLab-vpc"
    }
}

#Create a subnet (Public)
resource "aws_subnet" "myLab-subnet1" {
    vpc_id= aws_vpc.myLab-aws_vpc.id
    cidr_block= var.cidr_block[1]
    tags={
      Name= "PublicSubnet1"
    }
}
#Create Internet Gateway
resource "aws_internet_gateway" "myLab-IGW" {
    vpc_id = aws_vpc.myLab-aws_vpc.id
    tags={
      Name="myLab-igw"
    }

}

#Create security group
resource "aws_security_group" "myLab-SG" {
    name= "myLab-security grou"
    description = "To allow inbound outbound traffic with the VPC"
    vpc_id = aws_vpc.myLab-aws_vpc.id

    dynamic ingress{
      iterator =port
      for_each = var.ports
       content {
          from_port = port.value
          to_port = port.value
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]

        }
      
    }
    egress{
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name="allow"
    }
}
#Create a route table for this network 
resource "aws_route_table" "myLab_routeTable" {
    vpc_id = aws_vpc.myLab-aws_vpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.myLab-IGW.id
    }
    tags = {
      Name="Route-Table"
    }
}

#Create route table association 
resource "aws_route_table_association" "myLabRouteTableAss" {
    subnet_id = aws_subnet.myLab-subnet1.id
    route_table_id = aws_route_table.myLab_routeTable.id
}

#Create linux-Jenkins EC2 Instance to host out applications
resource "aws_instance" "Jenkins_instance" {
    ami = var.ami[0]
    instance_type = var.instance_type
    key_name = var.Keypair[0]
    security_groups= [aws_security_group.myLab-SG.id]
    subnet_id = aws_subnet.myLab-subnet1.id
    associate_public_ip_address = true
    user_data = file("./setupJenkins.sh")
    tags = {
      "Name" = "Jenkins-Instance"
    }
 }
 

 #Create linux-ansible EC2 Instance to host out applications
resource "aws_instance" "Ansible_instance" {
    ami = var.ami[0]
    instance_type = var.instance_type
    key_name = var.Keypair[0]
    security_groups= [aws_security_group.myLab-SG.id]
    subnet_id = aws_subnet.myLab-subnet1.id
    associate_public_ip_address = true
    user_data = file("./ansibleinstall.sh")
    tags = {
      "Name" = "Ansible-Instance"
    }
 }
 
 /*
  #Create Ubuntu EC2 Instance to host out applications
resource "aws_instance" "Ansible_instance-ubuntu" {
    ami = var.ami[3]
    instance_type = var.instance_type
    key_name = var.Keypair[0]
    security_groups= [aws_security_group.myLab-SG.id]
    subnet_id = aws_subnet.myLab-subnet1.id
    associate_public_ip_address = true
    #user_data = file("./setupJenkins.sh")
    tags = {
      "Name" = "Ansible-Instance-ubuntu"
    }
 }

   #Create Red Hat EC2 Instance to host out applications
resource "aws_instance" "Ansible_instance-Red" {
    ami = var.ami[2]
    instance_type = var.instance_type
    key_name = var.Keypair[0]
    security_groups= [aws_security_group.myLab-SG.id]
    subnet_id = aws_subnet.myLab-subnet1.id
    associate_public_ip_address = true
    #user_data = file("./setupJenkins.sh")
    tags = {
      "Name" = "Ansible-Instance-Red Hat"
    }
 }
*/