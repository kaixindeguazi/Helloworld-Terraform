# 条件表达式 (Conditional Expressions)

variable "is_production" {
  default = false
}

output "environment" {
  value = var.is_production ? "production" : "development"
}

# 动态块 (Dynamic Blocks) - 用于动态生成资源或块的内容，通常与模块或嵌套资源一起使用

variable "ingress_rules" {
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]
}

resource "aws_security_group" "example" {
  name = "example-sg"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

# for 循环

variable "numbers" {
  default = [1, 2, 3, 4]
}

output "squared_numbers" {
  value = [for number in var.numbers : number * number]
}

# 过滤元素

variable "numbers1" {
  default = [1, 2, 3, 4, 5]
}

output "even_numbers" {
  value = [for number in var.numbers1 : number if number % 2 == 0]
}


# 生成映射

variable "tags" {
  default = {
    "env"  = "production"
    "team" = "devops"
  }
}

output "upper_tags" {
  value = {for key, value in var.tags : key => upper(value)}
}


# 函数调用 (Built-in Functions)

variable "tags1" {
  default = {
    "env"  = "production"
    "team" = "devops"
  }
}

output "tag_count" {
  value = length(var.tags1)
}

output "env_tag" {
  value = lookup(var.tags, "env", "default")
}


resource "aws_instance" "example" {
  count         = 3
  instance_type = "t2.micro"
  ami           = "ami-12345678"
}

resource "aws_instance" "example1" {
  for_each = toset(["web", "app", "db"])
  instance_type = "t2.micro"
  ami           = "ami-12345678"
  tags = {
    Name = each.key
  }
}

# depends_on - 声明显式依赖，确保资源按顺序创建。

resource "aws_instance" "app" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}

resource "aws_eip" "app_eip" {
  instance = aws_instance.app.id
  depends_on = [aws_instance.app]
}
