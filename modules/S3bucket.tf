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
    placeholdervar = "wildrydest-scd"
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

//add resource or data for config file from the templates folder
//add resource for bucket objects (which go into the bucket) when you need them, which will include info from the s3 bucket code