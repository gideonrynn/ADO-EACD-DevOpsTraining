
//add resource that creates s3 bucket
//https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#static-website-hosting
//resource line: "name according to terraform" and "the nickname you are giving it". the nickname will be referenced in other resources, like bucket objects 
//bucket line is what will show up in aws
//tags = {"app_name"= "${var.app_name}", "env"= "${var.env}"}
//NOTE : these tags allow an admin to calculate the cost of the application based on the environment. They should be added to all AWS applications going forward.

//reference the policy client bucket in the templates

resource "aws_s3_bucket" "wrs-clientsf-scd-t" {
  bucket = "wildrydes-scd-t"
  acl    = "public-read"
  # policy = "this should reference the client bucket policy"

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

  tags = {"app_name"= "${var.app_name}", "env"= "${var.env}"}
}


//add policy, which is referenced in the bucket
# resource "aws_s3_bucket_policy" "wrs_clientsf_policy_scd_t" {
#   bucket = "aws_s3_bucket.wrs_clientsf_scd_t.id"

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Id": "MYBUCKETPOLICY",
#   "Statement": [
#     {
#       "Sid": "IPAllow",
#       "Effect": "Deny",
#       "Principal": "*",
#       "Action": "s3:*",
#       "Resource": "arn:aws:s3:::my_tf_test_bucket/*",
#       "Condition": {
#          "IpAddress": {"aws:SourceIp": "8.8.8.8/32"}
#       }
#     }
#   ]
# }
# POLICY
# }


//add resource for bucket objects (which go into the bucket) when you need them, which will include info from the s3 bucket code


//add resource or data for config file that the bucket will use
