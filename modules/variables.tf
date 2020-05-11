# Globals
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

// ** APIgateway CORS variables" **/
variable "allowed_headers" {
  description = "Allowed headers"
  type = list

  default = [
    "Origin",
    "Content-Type",
    "X-Amz-Date",
    "Authorization",
    "X-Api-Key",
    "X-Amz-Security-Token"
  ]
}

variable "allowed_methods" {
  description = "Allowed methods"
  type = list

  default = [
    "OPTIONS",
    "HEAD",
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE",
  ]
}

variable "allowed_origin" {
  description = "Allowed origin"
  type        = string
  default     = "*"
}

variable "allowed_max_age" {
  description = "Allowed response caching time"
  type        = string
  default     = "7200"
}