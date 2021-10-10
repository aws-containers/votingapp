output "restaurant_table_name" {
  value = aws_dynamodb_table.restaurants.name
}

output "restaurant_table_arn" {
  value = aws_dynamodb_table.restaurants.arn
}
