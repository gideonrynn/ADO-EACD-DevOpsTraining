// set local value for lmb zip
locals {
    lambda_zip_location = "../modules/Files_lambda_S3/wrst-lambda.zip"
}

// create archive of rU.js as zip
data "archive_file" "WildRydesTLambda" {
  type        = "zip"
  source_file = "../modules/Files_lambda_S3/requestUnicorn.js"
  output_path = local.lambda_zip_location
}

// set up lambda function as a resource, triggered in response to http req
// handler attr is name of the file and the function that will run (handler in this case)
resource "aws_lambda_function" "wrst-lambda" {
  filename      = local.lambda_zip_location
  function_name = "WildRydesTLambda"
  role          = aws_iam_role.wrst-iam-lambda-role.arn
  handler       = "requestUnicorn.handler"

  runtime = "nodejs12.x"

   tags = {
    "app_name" = "${var.app_name}"
    "env"      = "${var.env}"
  }
}