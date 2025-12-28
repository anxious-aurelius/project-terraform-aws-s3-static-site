locals {
  bucket_name = "${var.project_name}-${var.environment}"
}

resource "aws_s3_bucket" "static_site" {
  bucket = "${local.bucket_name}-site"
  tags = var.default_tags
}

resource "aws_s3_object" "web_files" {
  for_each = fileset(var.static_file_directory, "*")
  bucket   = aws_s3_bucket.static_site.id
  key      = each.value
  source   = "${var.static_file_directory}/${each.value}"
  content_type = lookup(
    var.static_file_type_dictionary,
    split(".", each.value)[length(split(".", each.value)) - 1],
    "binary/octet-stream"
  )
  tags = var.default_tags
}

resource "aws_s3_bucket_public_access_block" "private_access" {
  bucket                  = aws_s3_bucket.static_site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "access_static_website_origin"
  description                       = "OAC for CF to access website files on S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = aws_s3_bucket.static_site.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.static_site.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = var.cloudfront_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_s3_bucket_policy" "access_policy" {
  bucket = aws_s3_bucket.static_site.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowCloudFrontReadAccess",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudfront.amazonaws.com"
          },
          "Action" : "s3:GetObject",
          "Resource" : "${aws_s3_bucket.static_site.arn}/*",
          "Condition" : {
            "StringEquals" : {
              "AWS:SourceArn" : "${aws_cloudfront_distribution.s3_distribution.arn}"
            }
          }
        }
      ]
    }
  )
}

