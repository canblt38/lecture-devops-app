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
    access_key = "ASIAUYKDKOE7TOKSTDDJ"
    secret_key = "n61XGHIucWfAUh7VXYpDMmQHxqSO2L57bxFpNU8B"
    token = "FwoGZXIvYXdzEA8aDEaFbSzvX35v41F4EiLKAW9L3tjg5nYcHmd/FuhVODmC9lRfJQfaPZJPeufdkA8L6fsctmo8QKc0fXyXoG6n4vo0035AXMoPjONBgVFBFgPiVWWqHOLpbuwnUP/F7ER5UBoi/YL+zTgp8RQyn7Wub1rfdjo0XEz/z/30J7HkcTEOP2pKdHnd5xCt4bkcntoY/IwmablaDd6aD+bq91D4wrSIVsmMt4wDfMA2vS167FxEo7iqCFfam/SE4OmvL66i1vIp8APfh+QjK9xNZWyr+vNNaxL41EIA+g4o9IOliAYyLQGzUkjqUhvt0RgNpWZc1byARYlQNE93TCAedmEqdeM+eq4YZ+L7vZdI626Tjw=="
}
