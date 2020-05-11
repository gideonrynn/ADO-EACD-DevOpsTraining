locals {
    lambda_zip_location = "../modules/Files_lambda_S3/wrst-lambda.zip"
}


data "archive_file" "WildRydesTLambda" {
  type        = "zip"
  source_file = "../modules/Files_lambda_S3/requestUnicorn.js"
  output_path = local.lambda_zip_location
}

// as the lambda will be house in another s3 bucket, will need to set that up first, and refer to it below
// reference: https://www.youtube.com/watch?v=Lkm3v7UDlD8
// handler is name of the file and the function that will run (handler in this case)
resource "aws_lambda_function" "wrst-lambda" {
  filename      = local.lambda_zip_location
  function_name = "WildRydesTLambda"
  role          = aws_iam_role.wrst-iam-lambda-role.arn
  handler       = "requestUnicorn.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
#   source_code_hash = "${filebase64sha256("lambda_function_payload.zip")}"

  runtime = "nodejs12.x"

#   environment {
#     variables = {
#       foo = "bar"
#     }
#   }

   tags = {
    "app_name" = "${var.app_name}"
    "env"      = "${var.env}"
  }
}