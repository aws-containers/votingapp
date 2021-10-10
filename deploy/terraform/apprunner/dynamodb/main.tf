resource "aws_dynamodb_table" "restaurants" {
  hash_key = "name"
  name     = "restaurants-${var.table_suffix}"
  attribute {
    name = "name"
    type = "S"
  }

  billing_mode = "PAY_PER_REQUEST"
}

resource "aws_dynamodb_table_item" "ihop" {
  hash_key   = aws_dynamodb_table.restaurants.hash_key
  item       = <<ITEM
  {"name": {"S": "ihop"}, "restaurantcount": {"N": "0"}}'
ITEM
  table_name = aws_dynamodb_table.restaurants.name
}

resource "aws_dynamodb_table_item" "outback" {
  hash_key   = aws_dynamodb_table.restaurants.hash_key
  item       = <<ITEM
  {"name": {"S": "outback"}, "restaurantcount": {"N": "0"}}
ITEM
  table_name = aws_dynamodb_table.restaurants.name
}

resource "aws_dynamodb_table_item" "bucadibeppo" {
  hash_key   = aws_dynamodb_table.restaurants.hash_key
  item       = <<ITEM
  {"name": {"S": "bucadibeppo"}, "restaurantcount": {"N": "0"}}
ITEM
  table_name = aws_dynamodb_table.restaurants.name
}

resource "aws_dynamodb_table_item" "chipotle" {
  hash_key   = aws_dynamodb_table.restaurants.hash_key
  item       = <<ITEM
  {"name": {"S": "chipotle"}, "restaurantcount": {"N": "0"}}
ITEM
  table_name = aws_dynamodb_table.restaurants.name
}
