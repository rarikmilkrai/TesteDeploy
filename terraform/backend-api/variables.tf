variable "region" {
  default = "us-east-1"

}

variable "accountId" {
  default = 868948464703
  type    = number

}


variable "dynamodb_table" {
  default = "count-table"

}