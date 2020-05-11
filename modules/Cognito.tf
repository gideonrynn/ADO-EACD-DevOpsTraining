
// add resource for user pool for reg and sign in pages
// auto_verified_attributes will trigger email to user email address
resource "aws_cognito_user_pool" "wrst-pool" {
  name = "wildrydest-pool-scd"

  auto_verified_attributes = ["email"] 
  email_verification_subject = "Wild Rydes confirmation email code"
  // email_verification_message = "Thank you for joining Wild Rydes verify below"

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