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