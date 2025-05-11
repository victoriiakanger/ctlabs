module "label_frontend" {
    source = "cloudposse/label/null"
    version = "0.25.0"
    context = module.label.context
    name    = "frontend"
}


module "frontend_s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket = module.label_frontend.id

  force_destroy = true
}

###################################
# IAM Policy Document
###################################

data "aws_iam_policy_document" "oai" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.frontend_s3.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [module.cdn.cloudfront_origin_access_identity_iam_arns[0]]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [module.frontend_s3.s3_bucket_arn]

    principals {
      type        = "AWS"
      identifiers = [module.cdn.cloudfront_origin_access_identity_iam_arns[0]]
    }
  }
}

###################################
# S3 Bucket Policy
###################################

resource "aws_s3_bucket_policy" "read_gitbook" {
  bucket = module.frontend_s3.s3_bucket_id
  policy = data.aws_iam_policy_document.oai.json
}