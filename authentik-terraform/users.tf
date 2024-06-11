# Defualt Groups
data "authentik_group" "akadmins" {
  name = "authentik Admins"
}

data "authentik_user" "akadmin" {
  username = "akadmin"
}

resource "authentik_group" "admin" {
  name    = "Admin"
  is_superuser = true
}

# Users
data "authentik_user" "akadmin" {
  username = "akadmin"
}
resource "authentik_user" "Caleb" {
  username = "caleb"
  name     = "Caleb"
  groups   = [data.authentik_group.akadmins.id, authentik_group.admin.id]
}