// add resource that creates s3 bucket for client side files (clientsf)
// https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#static-website-hosting
// resource line: "name according to terraform" and "the nickname you are giving it". the nickname will be referenced in other resources, like bucket objects 
// bucket line = what will show up in aws
// add tags = {"app_name"= "${var.app_name}", "env"= "${var.env}"} update for Terraform version .12
// reference the policy client bucket in the templates
// fyi - known error with vsc: https://github.com/hashicorp/vscode-terraform/issues/231

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
    invokeUrl = ""
  })
  content_type = "application/javascript"

  etag = "filemd5(../modules/templates/config_for_S3.tpl)"
}

