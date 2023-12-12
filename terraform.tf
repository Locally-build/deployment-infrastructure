terraform {
  backend "s3" {
  }

  required_providers {
    parallels-desktop = {
      source  = "parallels/parallels-desktop"
      version = "0.2.2"
    }
  }
}
