# 定义变量
variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "my_lambda_function"
}

variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "my_api_gateway"
}

variable "unique_id" {
  description = "A unique identifier to prevent naming conflicts"
  type        = string
  default     = "xa-allen"
}

# 创建 IAM 角色供 Lambda 使用
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role-${var.unique_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

# IAM Role Policy
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 创建 Lambda 函数
# resource "aws_lambda_function" "lambda_function" {
#   function_name = "${var.lambda_name}-${var.unique_id}"
#   runtime       = "python3.9"
#   handler       = "lambda_function.lambda_handler"
#   role          = aws_iam_role.lambda_exec_role.arn
# 
#   # 这里使用内联代码，也可以通过 `filename` 引用外部文件
#   source_code_hash = filebase64sha256("${path.module}/lambda/lambda.zip")
#   filename         = "${path.module}/lambda/lambda.zip"
# 
#   environment {
#     variables = {
#       LOG_LEVEL = "INFO"
#     }
#   }
# }

# 创建 Lambda 函数
resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.lambda_name}-${var.unique_id}"
  handler       = "index.handler"
  runtime       = "nodejs18.x" # 确保使用支持的 Node.js 版本
  role          = aws_iam_role.lambda_exec_role.arn

  # 这里使用内联代码，也可以通过 `filename` 引用外部文件
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda.zip")
  filename         = "${path.module}/lambda/lambda.zip"

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
}

# 创建 API Gateway
resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "${var.api_gateway_name}-${var.unique_id}"
  protocol_type = "HTTP"
}

# 创建 API Gateway 集成
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.lambda_function.invoke_arn
  payload_format_version = "2.0"
}

# 创建 API Gateway 路由
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 部署 API Gateway
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = "$default"
  auto_deploy = true
}

# Lambda 权限配置，允许 API Gateway 调用 Lambda
resource "aws_lambda_permission" "apigateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway-${var.unique_id}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*"
}

output "api_endpoint" {
  description = "The endpoint of the API Gateway"
  value       = aws_apigatewayv2_stage.api_stage.invoke_url
}
