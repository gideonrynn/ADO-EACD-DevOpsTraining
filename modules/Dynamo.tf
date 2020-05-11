
// set up dynamo table as a resource
resource "aws_dynamodb_table" "wrst-dynamo-table" {
  name           = "RidesTSCD"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "RideId"

  attribute {
    name = "RideId"
    type = "S"
  }

  tags = {
      "app_name" = "${var.app_name}"
      "env"      = "${var.env}"
    }
}