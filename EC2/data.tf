
data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
}