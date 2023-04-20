#----------------------------------------------------------------------------------------#
# ===================== Cloud Native Coding Challenges Application ======================#
#----------------------------------------------------------------------------------------#
#                                                                                        #
# - Amazon RDS relational database for challenges and users using PostgreSQL.            #
# - Amazon API Gateway REST endpoints for serverless logics and alternative clients.     #
# - AWS Lambda functions for multi language challenges launching and validation.         #
# - Amazon Cognito for authentication to API.                                            #
# - AWS Amplify for frontend client on CDN using Next.js.                                #
#                                                                                        #
#----------------------------------------------------------------------------------------#

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.63.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region = var.region
}

resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier = "cluster"
  engine             = "aurora-postgresql"
  engine_version     = "11.9"
  database_name      = var.pg_database_name
  master_username    = var.pg_database_user
  master_password    = var.pg_database_password
  db_cluster_instance_class = var.pg_database_instance_class
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
}

resource "aws_rds_cluster_instance" "db_cluster_instance" {
  cluster_identifier = aws_rds_cluster.db_cluster.id
  instance_class = aws_rds_cluster.db_cluster.db_cluster_instance_class
  engine = aws_rds_cluster.db_cluster.engine
}

resource "aws_api_gateway_rest_api" "server" {
    name = "server"
}

resource "aws_amplify_app" "client" {
    name = "client"
    description = "client"
    environment_variables = {
        API_URL = "https://${aws_api_gateway_rest_api.server.id}.execute-api.ap-northeast-1.amazonaws.com",
    }
}

resource "aws_cognito_user_pool" "user_pool" {
    name = "user_pool"
    username_attributes = ["email"]
    auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
    name = "user_pool_client"
    user_pool_id = aws_cognito_user_pool.user_pool.id
    generate_secret = false
    allowed_oauth_flows = ["implicit"]
    allowed_oauth_flows_user_pool_client = true
    allowed_oauth_scopes = ["email", "openid", "aws.cognito.signin.user.admin"]
    callback_urls = ["https://${aws_amplify_app.client.id}.amplifyapp.com"]
    logout_urls = ["https://${aws_amplify_app.client.id}.amplifyapp.com"]
    supported_identity_providers = ["COGNITO"]
}

resource "aws_api_gateway_resource" "server_resource" {
    rest_api_id = aws_api_gateway_rest_api.server.id
    parent_id = aws_api_gateway_rest_api.server.root_resource_id
    path_part = "{proxy+}"
}