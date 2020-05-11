// set up basic iam role for lambda function
// update service to lambda from ec2 default
resource "aws_iam_role" "wrst-iam-lambda-role" {
  name = "WildRidesTLambdaRoleSCD"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },
     {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    "app_name" = "${var.app_name}"
    "env"      = "${var.env}"
  }
}


// set up the in-line table write access policy
// can use IAM policy simulator from original WildRydes IAM to generate statement below but must enter current table
// note that resource required "" and ${} format to execute successfully from within the statement
// fyi - using the aws policy generator will generate statement below but direct table resource

resource "aws_iam_role_policy" "wrst-iam-policy-writeaccess" {
  name = "WildRydesTWriteAccess"
  role = aws_iam_role.wrst-iam-lambda-role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
       {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "dynamodb:PutItem",
            "Resource": "${aws_dynamodb_table.wrst-dynamo-table.arn}"
        }
    ]
  }
  EOF
}

// set up management policy for AWSLambdaBasicExecutionRole
// instructions reference policy_arn = "${aws_iam_policy.policy.arn}", but since the arn is not exported from aws_iam_role policy, grabbed the policy_arn from the original WildRydes AWSLBER 
resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.wrst-iam-lambda-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}