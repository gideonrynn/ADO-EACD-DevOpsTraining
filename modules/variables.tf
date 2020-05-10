#Globals
variable "app_name" {
  description = "application name - match app repo"
  default     = "wildrydestscd"
}

variable "env" {
  description = "deployment environment"
  default     = "scd"
}

variable "region" {
  description = "region to build environment"
  default     = "us-east-2"
}

# variable "client_bucket" {
#   description = "name for bucket containing client side files"
#   default     = "wildrydest-scd"
# }