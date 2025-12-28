variable "project_name"{
    description = "The name of the project."
    type        = string
    default = "terraform-aws-s3-static-site"
}

variable "environment"{
    description = "The environment for the deployment."
    type        = string
    default = "staging"
    validation {
      condition = contains(["staging","production"], var.environment)
      error_message = "Invalid environment input. Environment should either be staging or production."
    }
}

variable "default_tags" {
  description = "Base tags for resources."
  type        = map(string)
  default = {
    developer = "kripal",
    source    = "terraform"
    }
}

variable "static_file_directory" {
  description = "Directory with website content"
    type        = string
    default = "./www"
}

variable "static_file_type_dictionary" {
  description = "Lookup dictionary to fetch the type of the static file uploaded to S3"
    type        = map(string)
    default = {
      html = "text/html"
      css  = "text/css"
      js   = "application/javascript"
      png  = "image/png"
      jpg  = "image/jpeg"
      jpeg = "image/jpeg"
      svg  = "image/svg+xml"
    }
}

variable "cloudfront_price_class" {
  description = "The price class for CloudFront distribution"
    type        = string
    default = "PriceClass_100"
}