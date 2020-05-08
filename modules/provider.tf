//per validate:
//Terraform 0.11 and earlier required all non-constant expressions to be
# provided via interpolation syntax, but this pattern is now deprecated. To
# silence this warning, remove the "${ sequence from the start and the }"
# sequence from the end of this expression, leaving just the inner expression.

# Template interpolation syntax is still used to construct strings from
# expressions when the template includes multiple interpolation sequences or a
# mixture of literal strings and interpolations. This deprecation applies only
# to templates that consist entirely of a single interpolation sequence.
//updated "${var.region}" to "var.region"

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

