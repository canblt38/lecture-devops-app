terraform {
    backend "remote" {
        organization = "SemesterabgabeDevOps"

        workspaces {
            name = "BulutDevOps"
        }
    }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.15.1"
}

provider "aws" {
  region  = "us-east-1"
    access_key = "ASIAYUOZXJF4SMHQ6BU7"
    secret_key = "gCCfK1UvRIthvwpQcjmU5E6bAVPAMNYK8Dz9uMYl"
    token = "FwoGZXIvYXdzEA8aDBSxzDRKt4FEFJivAiLKAXecaq9WjcqbPSjqQW0KC9XWJfEPEqHK21GuSbeksap59DfqxN5GQkJrAXcWD8+FtlwEcEr2QVJHv+RMcVHCNe+hEeb2azMMuTyQbzfVQaLaf2tvjWsKAswNlNc2EhYxyN5JEMIOf9NsC+q3/BOswGS20JJi5jOixhHzvLVxKG9xFreSfnoYxuAQ0gZofxO27u5mmllb23z+inbGiP82A5VAJK+CMhrk0+sfFwXS/ZiW3+902PQAkvu2BygWT4g4a+o8VXmS+/+RbtQop42liAYyLZQ1wuB8E618vlgQ3lq23e1q1i+kTkFJwQh5IZ2lmL742qqFa7OVaUWOc26cHQ=="
}
