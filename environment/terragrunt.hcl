remote_state {
  backend = "s3"
  config = {
    bucket         = "${yamldecode(file("common_values.yaml"))["prefix"]}-tf-cavarsa-store-${yamldecode(file("common_tags.yaml"))["Env"]}-${yamldecode(file("common_values.yaml"))["aws_region"]}-particule"
    key            = "${path_relative_to_include()}"
    region         = "${yamldecode(file("common_values.yaml"))["aws_region"]}"
    encrypt        = true
    dynamodb_table = "${yamldecode(file("common_values.yaml"))["prefix"]}-tf-cavarsa-store-lock-${yamldecode(file("common_tags.yaml"))["Env"]}-${yamldecode(file("common_values.yaml"))["aws_region"]}-particule"
  }
}

