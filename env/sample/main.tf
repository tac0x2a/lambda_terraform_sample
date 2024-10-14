module "lambda_sample" {
  source = "../../modules/lambda/"
}


module "s3_sample" {
  source = "../../modules/s3/"
}

module "x-ray_sample" {
  source = "../../modules/x-ray_sample/"
}
