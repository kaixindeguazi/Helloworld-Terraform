data "aws_instance" "details" {
  filter {
    name   = "tag:Name"
    values = ["xa-allen"]
  }
}


# 输出实例的 ID、名称和 IP 地址
output "allen_ec2_details" {
  value = {
      name       = lookup(data.aws_instance.details.tags, "Name", "No Name") # 获取 Name 标签，默认为 "No Name"
      public_ip  = data.aws_instance.details.public_ip                      # 公网 IP 地址
      private_ip = data.aws_instance.details.private_ip                     # 私网 IP 地址
  }
}
