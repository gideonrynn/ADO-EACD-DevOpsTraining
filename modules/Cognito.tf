
//add resource for user pool for reg and sign in pages
resource "aws_cognito_user_pool" "wrst-pool" {
  name = "wildrydest-pool-scd"
  tags = {
    "app_name" = "${var.app_name}"
    "env"      = "${var.env}"
  }
}

// add resource to add app to user pool
resource "aws_cognito_user_pool_client" "wrst-pool-client" {
  name = "wildrydest-pool-scd-client"

  user_pool_id = aws_cognito_user_pool.wrst-pool.id
  
}