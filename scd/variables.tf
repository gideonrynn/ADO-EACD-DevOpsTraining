module "build_wildRydes" {
  # globals
  source   = "../modules"

}


 variable "app_name" {
    description = "application name - match app repo"
    default     = "wildrydestscd"
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
