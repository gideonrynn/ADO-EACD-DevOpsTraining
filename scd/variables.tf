module "build_wildRydes" {
  # globals
  source   = "../modules"
  app_name = "${var.app_name}"
  env      = "${var.env}"
  region   = "${var.region}"
}

# globals
variable "app_name" {
description = "application name - match app repo"
default     = "wildrydes"
}

//changed default from dev to scd
variable "env" {
description = "deployment environment"
default     = "scd"
}

variable "region" {
description = "region to build environment"
default     = "us-east-2"
}




