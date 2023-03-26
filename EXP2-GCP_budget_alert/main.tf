#terraform code to create Google cloud budget alert

#Google Cloud provider
provider "google" {
  project = "<PROJECT_ID>"
  region  = "<REGION>"
}

data "google_billing_account" "account" {
  billing_account = "000000-0000000-0000000-000000"
}

data "google_project" "project" {
}

resource "google_billing_budget" "example_budget" {
  amount               = "1000"
  currency             = "USD"

  threshold_rules {
    threshold_percent = 50.0
    spend_basis       = "FORECASTED_SPEND"
  }

  budget_filter {
    projects = ["<PROJECT_ID>"]
  }

# notification for the budget alert
  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.notification_channel.id,
    ]
    disable_default_iam_recipients = true
  }
}

resource "google_monitoring_notification_channel" "notification_channel" {
  display_name = "Example Notification Channel"
  type         = "email"

  labels = {
    email_address = "address@example.com"
  }
}
