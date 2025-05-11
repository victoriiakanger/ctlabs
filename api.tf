module "label_api" {
  source = "cloudposse/label/null"
  # Cloud Posse recommends pinning every module to a specific version
  version = "0.25.0"
  context = module.label.context
  name    = "api"
}


resource "aws_api_gateway_rest_api" "this" {
  name        = module.label_api.id
  description = "API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


#
# ── /courses ──────────────────────────────────────────────────────────────────
#

resource "aws_api_gateway_resource" "courses" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "courses"
}


module "cors_courses" {
  source          = "squidfunk/api-gateway-enable-cors/aws"
  version         = "0.3.3"
  api_id          = aws_api_gateway_rest_api.this.id
  api_resource_id = aws_api_gateway_resource.courses.id

  allow_methods = ["GET", "POST", "OPTIONS"]
  allow_headers = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key"]
  allow_origin  = "*"
}

# GET /courses
resource "aws_api_gateway_method" "courses_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "courses_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.courses_get.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambda_functions.lambda_get_all_courses_invoke_arn

  request_templates = {
    "application/json" = "{}"
  }
}

resource "aws_api_gateway_integration_response" "courses_get_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.courses_get.http_method
  status_code = "200"
  selection_pattern = ""

  response_templates = {
    "application/json" = "$input.body"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'" 
  }

  depends_on = [aws_api_gateway_integration.courses_get_integration]
}

resource "aws_api_gateway_method_response" "courses_get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.courses_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# POST /courses
resource "aws_api_gateway_method" "courses_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "courses_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.courses_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambda_functions.lambda_save_course_invoke_arn

  request_templates = {
    "application/json" = "$input.json('$')"
  }
}

resource "aws_api_gateway_method_response" "courses_post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.courses_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "courses_post_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.courses_post.http_method
  status_code = "200"
  selection_pattern = ""

  response_templates = {
    "application/json" = "$input.body"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'" 
  }

  depends_on = [aws_api_gateway_integration.courses_post_integration]
}

#
# ── /courses/{id} ──────────────────────────────────────────────────────────────
#

resource "aws_api_gateway_resource" "course_id" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.courses.id
  path_part   = "{id}"
}

module "cors_course_id" {
  source          = "squidfunk/api-gateway-enable-cors/aws"
  version         = "0.3.3"
  api_id          = aws_api_gateway_rest_api.this.id
  api_resource_id = aws_api_gateway_resource.course_id.id

  allow_methods = ["GET", "PUT", "DELETE", "OPTIONS"]
  allow_headers = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key"]
  allow_origin  = "*"
}

# GET /courses/{id}
resource "aws_api_gateway_method" "course_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "course_id_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.course_id_get.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambda_functions.lambda_get_course_invoke_arn

  request_templates = {
    "application/json" = <<EOF
    {
      "id": "$input.params('id')"
    }
    EOF
  }
}

resource "aws_api_gateway_method_response" "course_id_get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.course_id_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "course_id_get_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.course_id_get.http_method
  status_code = "200"
  selection_pattern = ""

  response_templates = {
    "application/json" = "$input.body"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'" 
  }

  depends_on = [aws_api_gateway_integration.course_id_get_integration]
}

# PUT /courses/{id}
resource "aws_api_gateway_method" "course_id_put" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "course_id_put_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.course_id_put.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambda_functions.lambda_update_course_invoke_arn

  request_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
    {
      "id": "$input.params('id')",
      #foreach($key in $inputRoot.keySet())
      "$key": $input.json("$.$key")#if($foreach.hasNext),#end
      #end
    }
    EOF
  }
}

resource "aws_api_gateway_method_response" "course_id_put_method_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.course_id_put.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}


resource "aws_api_gateway_integration_response" "course_id_put_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.course_id_put.http_method
  status_code = "200"
  selection_pattern = ""

  response_templates = {
    "application/json" = "$input.body"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'" 
  }

  depends_on = [aws_api_gateway_integration.course_id_put_integration]
}

# DELETE /courses/{id}
resource "aws_api_gateway_method" "course_id_delete" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "course_id_delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.course_id_delete.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambda_functions.lambda_delete_course_invoke_arn

   request_templates = {
    "application/json" = <<EOF
    {
      "id": "$input.params('id')"
    }
    EOF
  }
}

resource "aws_api_gateway_method_response" "course_id_delete_method_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.course_id_delete.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "course_id_delete_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.course_id_delete.http_method
  status_code = "200"
  selection_pattern = ""

  response_templates = {
    "application/json" = "$input.body"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'" 
  }

  depends_on = [aws_api_gateway_integration.course_id_delete_integration]
}


#
# ── /authors ─────────────────────────────────────────────────────────────────
#

resource "aws_api_gateway_resource" "authors" {
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "authors"
  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_method" "get_authors" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.authors.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_authors_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.authors.id
  http_method             = aws_api_gateway_method.get_authors.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambda_functions.lambda_get_all_authors_invoke_arn

  request_templates = {
    "application/json" = "{}"
  }
}

resource "aws_api_gateway_method_response" "get_authors_method_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.get_authors.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "get_authors_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.get_authors.http_method
  status_code = "200"
  selection_pattern = ""

  response_templates = {
    "application/json" = "$input.body"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'" 
  }

  depends_on = [aws_api_gateway_integration.get_authors_integration]
}


module "cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.this.id
  api_resource_id = aws_api_gateway_resource.authors.id

  allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  allow_headers = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key"]
  allow_origin  = "*"
}

# Deployment & Stage
resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration_response.courses_get_response,
    aws_api_gateway_integration_response.courses_post_response,
    aws_api_gateway_integration_response.course_id_get_response,
    aws_api_gateway_integration_response.course_id_put_response,
    aws_api_gateway_integration_response.course_id_delete_response,
    aws_api_gateway_integration_response.get_authors_response
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "dev"
}


resource "aws_api_gateway_model" "post_course" {
  rest_api_id  = aws_api_gateway_rest_api.this.id
  name         = replace("${module.label_api.id}-PostCourse", "-", "")
  description  = "a JSON schema"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/schema#",
  "title": "CourseInputModel",
  "type": "object",
  "properties": {
    "title": {"type": "string"},
    "authorId": {"type": "string"},
    "length": {"type": "string"},
    "category": {"type": "string"}
  },
  "required": ["title", "authorId", "length", "category"]
}
EOF
}

resource "aws_api_gateway_request_validator" "this" {
  name                  = "validate_request_body"
  rest_api_id           = aws_api_gateway_rest_api.this.id
  validate_request_body = true
}