variable "app_name" {
    type = string
}
variable "app_client_id" {
  type = string
}
variable "app_redirect_uris" {
  type = list(string)
}
variable "app_property_mappings" {
  type = list(string)
}
variable "app_admin_group" {
  type = string
}
variable "app_admin_users" {
  type = string
}
variable "app_groups" {
  type = list(string)
}
