output "lambda_courses_invoke_arn" {
  value = module.lambda_get_all_courses.lambda_function_invoke_arn
}

output "lambda_save_course_invoke_arn" {
  value = module.lambda_save_course.lambda_function_invoke_arn
}

output "lambda_update_course_invoke_arn" {
  value = module.lambda_update_course.lambda_function_invoke_arn
}

output "lambda_delete_course_invoke_arn" {
  value = module.lambda_delete_course.lambda_function_invoke_arn
}

output "lambda_get_course_invoke_arn" {
  value = module.lambda_get_course.lambda_function_invoke_arn
}

output "lambda_get_all_courses_invoke_arn" {
  value = module.lambda_get_all_courses.lambda_function_invoke_arn
}

output "lambda_get_all_authors_invoke_arn" {
  value = module.lambda_get_all_authors.lambda_function_invoke_arn
}