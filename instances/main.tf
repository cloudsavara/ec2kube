terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "tfstateec2kube"
    key    = "instances/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}


data "aws_subnet" "kube_subnet_id" {
  
  filter {
    name   = "tag:Name"
    values = ["kube_subnet"]
  }

#   most_recent = true
}

data "aws_security_group" "kube_sg_id" {
  
  filter {
    name   = "tag:Name"
    values = ["kube_sg"]
  }

#   most_recent = true
}

resource "aws_key_pair" "kube_cp_key" {
  key_name   = "vara2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDkDirifXxv/yd7kqRpR3chv34G3nFrrnYBfdnQpfItGeeMxSfLD/FJ3OlF486m1PSI6YgPQm2miv98VA7UnIpmYWczGVljAbFrf9wPXbHKqYdHamxkMzV9Q7NdwTw+MUVYgoTbWyUmPYXY5RbOh76cQu2LtkBMg0dOFNb/ByJ80Km2F1uRJlJTjDRiDIxr44NY1gKPriYLOxGKzoh4Mv4tZmJIPoaR6teYBS8eRC5KG2CaI/y9WS43ENljBFGr1NklKRhrLGHh0JuRx8XwtcBPmf4GL71lDgH9ztiYzok8aurPTqxit+MGl8Bc1m995irYtp7HJqPhtaP2zfZ3x4RwBbQwC23+x1vG6doFNvRjsMxCFXmt/EdykNwk19RXYzjl6mteX4DkYBFWeq3S9EkYeqwb80Q9wBW8nxI0NV+WBuAB7AqORFsJbydBjKR9amtjvOznTaQC8oCIKZpGOEaO0SIGD15B1Bnq8GBYfiZXibNzov1u3nP4xHROomBkUdk= vara prasad@DESKTOP-7GJA2VA"
}


resource "aws_network_interface" "kube_instance_eni" {
  subnet_id       = data.aws_subnet.kube_subnet_id.id
  security_groups = [data.aws_security_group.kube_sg_id.id]

  
}

resource "aws_instance" "kube_dash_instance" {
  ami           = "ami-0e472ba40eb589f49" # us-east-1
  instance_type = "t3.medium"

  network_interface {
    network_interface_id = resource.aws_network_interface.kube_instance_eni.id
    device_index         = 0
  }
  availability_zone = "us-east-1a"
  key_name = resource.aws_key_pair.kube_cp_key.key_name

  tags= {
    Name = "KubeCtrlPlane"
  }

}
