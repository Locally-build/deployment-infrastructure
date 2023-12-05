# How to create and deploy Parallels Desktop on AWS Mac instances using Terraform

## The Repository

This repository contains an example on how to deploy a dedicated mac host in AWS and deploy Parallels Desktop on it. will will also install two virtual machines.
It contains everything needed for it to run using the latest terraform.

## Requirements

You will need several requirements to be able to run this terraform script

* [Terraform Cli](https://developer.hashicorp.com/terraform/downloads)
* AWS account with an API access
  * You will need the AWS ```access``` key and the AWS ```secret key```

## How to run it

For running the terraform script, you should:

* Clone the repo locally
* Create a ```local.tfvars``` inside the root and add the following:

    ```json
    aws_access_key              = "" // Your AWS access key
    aws_secret_key              = "" // Your AWS secret key
    aws_region                  = "" // the region where you want to deploy, ex: us-east-2
    aws_availability_zone_index = 0 // the availability zone index, this is normally 0
    use_intel                   = false // do you want to deploy a x86 mac or a ARM one
    machines_count              = 1 // How many machines do you want to deploy
    ```


    __Attention:__ At the moment of writing, only the US region has the new ARM Mac hardware and even there not all availability zones have them, check [here](https://aws.amazon.com/ec2/instance-types/mac/) before you choose.

by default the script will try to get the latest AMI available but you can set this manually by adding your own AMI ID or a specific version of the AMI, for example:

    ```json
    mac_ami_id = "ami-09b2201fa15c4cb83"
    ```

    __Attention:__ The AMI ID is different for each region and availability zone, so make sure you use the correct one.
    
* Run terraform init:
  
  ```bash
  $ terraform init
  ```

* Run the validate command

  ```bash
  $ terraform validate
  ```

* Run the plan command:

  ```bash
  $ terraform plan -var-file local.tfvars
  ```

* Verify that you are happy with the plan, if so run

  ```bash
  $ terraform apply -var-file local.tfvars
  ```

  __Attention:__ Applying the plan might take several minutes

You should now have a dedicated Mac host running Parallels Desktop and with two virtual machines on it, if you want to connect to the host using ssh to further customize it you can do so:

* Run in the terminal

  ```bash
  $ terraform output -raw ssh_private_key > private.key & chmod 0600 private.key
  ```

* Get the IP for the host by running in terminal

  ```bash
  $ terraform output instance_public_ip
  ```

* Run in terminal:

  ```bash
  $ ssh -i private.key ec2-user@<host_ip>
  ```
