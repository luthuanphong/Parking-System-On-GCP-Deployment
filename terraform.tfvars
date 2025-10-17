project_id            = "quixotic-vent-475107-s1"
region                = "asia-southeast1"
service_account_email = "parking-system-run-sa@quixotic-vent-475107-s1.iam.gserviceaccount.com"
image                 = "asia-southeast1-docker.pkg.dev/quixotic-vent-475107-s1/parking-api-repo/parking-service"
tag = ""
limit = {
  cpu    = "1000m"
  memory = "512Mi"
}