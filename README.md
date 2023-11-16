# Terraform Testing Project
This project contains pre-created samples for testing purposes. These **are not** production ready templates.   
## Prerequisites
* Install Terraform
* Install postgresql client
* Install mysql client

## Terraform directory contains the Terraform infrastructure that is currently be worked on.
### Setup variables
* copy terraform.tfvars.sample to terraform.tfvars
* update terrform.tfvars with the relevant data
### Terraform commands 
The commands must be issued inside the Terraform directory
* **terraform init** - Used to initialize the Terraform client
* **terraform plan** - Used to check what Terraform plans to do if applied
* **terraform apply -auto-approve** - Used to execute the Terraform plan
* **terraform output** - Show output parameters from the previous apply
* **terraform plan -destroy** - Used to check what Terraform plans to do if a destroy command is issued
* **terraform destroy** - Used to remove the resources from the Terraform plan

## TerraformExamples directory contains various Terraform projects
To use any of these examples 
1. Create a directory under TerraformExamples for the contents of the Terraform directory
2. Move the contents excluding lock files and the .terraform directory from the Terraform directory to the TerraformExamples/newlyCreatedDirectory
3. Cleanup remaining files in the Terraform directory
4. Copy files from the TerraformExamples directory of choice into the Terraform directory
5. Follow examples above for the Terraform directory