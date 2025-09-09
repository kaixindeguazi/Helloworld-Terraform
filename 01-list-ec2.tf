
# 获取所有 EC2 实例的列表
data "aws_instances" "all_instances" {}

# 获取每个实例的详细信息
data "aws_instance" "details" {
  for_each = toset(data.aws_instances.all_instances.ids)
  instance_id = each.value
}

# 输出实例的 ID、名称和 IP 地址
output "ec2_instance_details" {
  value = {
    for id, instance in data.aws_instance.details :
    id => {
      name       = lookup(instance.tags, "Name", "No Name") # 获取 Name 标签，默认为 "No Name"
      public_ip  = instance.public_ip                      # 公网 IP 地址
      private_ip = instance.private_ip                     # 私网 IP 地址
    }
  }
}
