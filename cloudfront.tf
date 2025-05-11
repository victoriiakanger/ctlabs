module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"
  version = "v4.1.0"
  default_root_object = "index.html"

  #aliases = ["cdn.example.com"]

  comment             = "My awesome CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "My awesome CloudFront can access"
  }

#   logging_config = {
#     bucket = "logs-my-cdn.s3.amazonaws.com"
#   }

  origin = {
    # something = {
    #   domain_name = "something.example.com"
    #   custom_origin_config = {
    #     http_port              = 80
    #     https_port             = 443
    #     origin_protocol_policy = "match-viewer"
    #     origin_ssl_protocols   = ["TLSv1.2"]
    #   }
    # }

    s3_one = {
      domain_name = module.frontend_s3.s3_bucket_bucket_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id           = "s3_one"
    viewer_protocol_policy     = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

#   ordered_cache_behavior = [
#     {
#       path_pattern           = "/static/*"
#       target_origin_id       = "s3_one"
#       viewer_protocol_policy = "redirect-to-https"

#       allowed_methods = ["GET", "HEAD", "OPTIONS"]
#       cached_methods  = ["GET", "HEAD"]
#       compress        = true
#       query_string    = true
#     }
#   ]

#   viewer_certificate = {
#     acm_certificate_arn = "arn:aws:acm:us-east-1:135367859851:certificate/1032b155-22da-4ae0-9f69-e206f825458b"
#     ssl_support_method  = "sni-only"
#   }

    custom_error_response = [{
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    }, {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }]
}