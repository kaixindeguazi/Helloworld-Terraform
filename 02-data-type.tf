
# string
variable "example_string" {
  type    = string
  default = "Hello, Terraform!"
}

output "string_output" {
  value = var.example_string
}

# 数字 - 可以是整数或浮点数。
variable "example_number" {
  type    = number
  default = 42
}

output "number_output" {
  value = var.example_number
}

# 布尔类型

variable "example_bool" {
  type    = bool
  default = true
}

output "bool_output" {
  value = var.example_bool
}

# List - 有序集合，元素类型相同。

variable "example_list" {
  type    = list(string)
  default = ["one", "two", "three"]
}

output "list_output" {
  value = var.example_list
}

# 键值对集合，键为字符串，值可以是任何类型。

variable "example_map" {
  type    = map(string)
  default = {
    key1 = "value1"
    key2 = "value2"
  }
}

output "map_output" {
  value = var.example_map["key1"]
}


# Set - 无序且不重复的元素集合，元素类型相同。

variable "example_set" {
  type    = set(string)
  default = ["apple", "banana", "apple"]
}

output "set_output" {
  value = var.example_set
}

# 元组 - 有序集合，元素类型可以不同。

variable "example_tuple" {
  type    = tuple([string, number, bool])
  default = ["hello", 42, true]
}

output "tuple_output" {
  value = var.example_tuple[1] # 返回 42
}

# 对象 - 类似于结构体，每个属性有特定类型

variable "example_object" {
  type = object({
    name   = string
    age    = number
    active = bool
  })
  default = {
    name   = "John"
    age    = 30
    active = true
  }
}

output "object_output" {
  value = var.example_object.name # 返回 "John"
}


