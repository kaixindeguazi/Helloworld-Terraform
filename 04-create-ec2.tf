# 3.87.253.10
# 获取现有的 VPC ID（my-vpc）
data "aws_vpc" "my_vpc" {
  filter {
    name   = "tag:Name"
    values = ["my-vpc"]
  }
}

# 获取与 VPC 关联的子网
data "aws_subnet" "public_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.my_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["my-public-subnet"] # 替换为实际子网的名称
  }
}

# 查找现有的 SSH 密钥对
data "aws_key_pair" "my_key" {
  key_name = "us-gz-stu-2005"
}


data "aws_security_group" "existing_allow_ssh" {
  filter {
    name   = "group-name"
    values = ["allow_ssh"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.my_vpc.id]
  }
}


# 创建 EC2 实例
resource "aws_instance" "ec2_instances" {
  ami           = "ami-005fc0f236362e99f" # AMI ID
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.public_subnet.id
  vpc_security_group_ids = [data.aws_security_group.existing_allow_ssh.id]

  associate_public_ip_address = true
  key_name = data.aws_key_pair.my_key.key_name

  tags = {
    Name = "xa-allen"
  }
}


# 输出实例信息
output "instance_public_ips" {
  value = aws_instance.ec2_instances[*].public_ip
}
