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
  key_name   = "vara"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCRWPQNuFR+e807W6aaZQZjpbWye3X/udhU1HN9Zdqfr3RJw6UARvu5Z77yxM0KNiAUPVzAPgygB2njtq27rs9QsovPzPvDqoqB3kEIsZYOIh7znHNSy4HaNE8Uftp6kDeBXvOR+kggD3TCpZpZVGl+BRmTr2O8Hv16VIrWTFdyvxw+HF61Ou3v9aOXStDOacHUOIteubND/MQjAfFcFozbnjptZgTCKg1haD5p2Yn2dxbAIwS6vp+d2gXSZ5KTZyEYFzF72VPmDSOEQgSHBrK/Pb/Rii1EjxQdoAOc1W4NNjP9uNlJMUB3VjydUamXdnzSfVlTavxHJeSyDJIRKPdN vara"
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
