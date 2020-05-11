//** Client Side Bucket and Policy **//

// add resource that creates s3 bucket for client side files (clientsf)
// read-reference the policy client bucket in the templates
// * will want to add var for bucket and refer to in config bucket object
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
// replaced source with content and added vars, which are in the config_for_S3.tpl
// invokeUrl added once aws_api_gateway_deployment resource created
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
