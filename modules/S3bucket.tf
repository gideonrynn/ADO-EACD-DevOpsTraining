//** Client Side Bucket and Policy **//

// add resource that creates s3 bucket for client side files (clientsf)
// https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#static-website-hosting
// resource line: "resource name according to terraform" and "the nickname you are giving it". the nickname will be referenced in other resources, like bucket objects 
// bucket line = what will show up in aws
// read/reference the policy client bucket in the templates

resource "aws_s3_bucket" "wrst-clientsf-bucket" {
  bucket = "wildrydest-scd"
  acl    = "public-read"
  policy = templatefile("../modules/templates/policy_clientbucket.json", {
    bucket_name = "wildrydest-scd"
  })

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF

  }

  tags = {
    "app_name" = "${var.app_name}"
    "env"      = "${var.env}"
  }
}

// add resource to add config file to bucket
// review tpl and add vars to template file
// replaced source with content and added vars, which are in the config_for_S3.tpl
resource "aws_s3_bucket_object" "wrst-clientsf-bucket-config" {
  bucket = "wildrydest-scd"
  key    = "js/config.js"
  content = templatefile("../modules/templates/config_for_S3.tpl", {
    userPoolId = aws_cognito_user_pool.wrst-pool.id
    userPoolClientId = aws_cognito_user_pool_client.wrst-pool-client.id
    region = var.region
    invokeUrl = aws_api_gateway_deployment.wrst-apigateway-deployment.invoke_url
  })
  content_type = "application/javascript"

  etag = "filemd5(../modules/templates/config_for_S3.tpl)"
}

//** Lambda Bucket and Policy **//

// do we need these? creating the data archive and output seems to do the trick

//creates bucket and reads template policy
# resource "aws_s3_bucket" "wrst-lambda-bucket" {
#   bucket = "wildrydest-lambda-scd"
#   acl    = "public-read"
#   policy = templatefile("../modules/templates/policy_lambdabucket.json", {
#     bucket_name = "wildrydest-lambda-scd"
#   })

#   website {
#     index_document = "index.html"
#     error_document = "error.html"

#     routing_rules = <<EOF
# [{
#     "Condition": {
#         "KeyPrefixEquals": "docs/"
#     },
#     "Redirect": {
#         "ReplaceKeyPrefixWith": "documents/"
#     }
# }]
# EOF

#   }

#   tags = {
#     "app_name" = "${var.app_name}"
#     "env"      = "${var.env}"
#   }
# }


// create bucket object and add zip to it
// check use of source and content
# resource "aws_s3_bucket_object" "wrst-lambda-bucket" {
#   bucket = "wildrydest-lambda-scd"
#   key    = "wrst-lambda.zip"
#   source = "../modules/Files_lambda_S3/requestUnicorn.js"
  # content_type = "application/javascript"

#   etag = "filemd5(../modules/Files_lambda_S3/requestUnicorn.js)"
# }