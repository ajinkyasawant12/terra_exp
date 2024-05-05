resource "aws_cognito_user_pool" "wild_rydes_user_pool" {
    name = "wild-rydes-user-pool"
}

resource "aws_cognito_user_pool_client" "wild_rydes_user_pool_client" {
    name                   = "wild-rydes-user-pool-client"
    user_pool_id           = aws_cognito_user_pool.wild_rydes_user_pool.id
    generate_secret        = false
    allowed_oauth_flows    = ["code"]
    allowed_oauth_scopes   = ["email", "openid", "profile"]
    callback_urls          = ["http://localhost:3000/callback"]
    supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "wild_rydes_user_pool_domain" {
    domain       = "wild-rydes-user-pool-domain"
    user_pool_id = aws_cognito_user_pool.wild_rydes_user_pool.id
}

resource "aws_cognito_user_pool_user" "wild_rydes_user" {
    user_pool_id = aws_cognito_user_pool.wild_rydes_user_pool.id
    username     = "example_user"
    message_action = "SUPPRESS"
    desired_delivery_mediums = ["EMAIL"]
    force_alias_creation = true

    password = "example_password"

    user_attributes {
        name  = "email"
        value = "example@example.com"
    }
}

output "user_details" {
    value = aws_cognito_user_pool_user.wild_rydes_user
}