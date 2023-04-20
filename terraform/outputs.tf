output "client_id" {
  value = aws_amplify_app.client.id
}

output "api_id" {
  value = aws_api_gateway_rest_api.server.id
}

