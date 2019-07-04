resource "aws_lambda_function" "shorturl" {
  filename      = "lambda/lambda.zip"
  role          = var.lambda_role
  handler       = "lambda.handler"
  function_name = "shorturl"
  source_code_hash = filebase64sha256("lambda/lambda.zip")

  runtime = "python3.7"

  environment {
    variables = {
      HEALTH = "200"
      TABLE = aws_dynamodb_table.shorturls.id
    }
  }
}

resource "aws_lambda_permission" "alb_lambda" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.shorturl.arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_alb_target_group.alb.arn
}

resource "aws_alb_target_group_attachment" "alb_lambda" {
  target_group_arn = aws_alb_target_group.alb.arn
  target_id        = aws_lambda_function.shorturl.arn
  depends_on       = [aws_lambda_permission.alb_lambda]
}