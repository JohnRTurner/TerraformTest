# Terraform Directory

## Terraform directory contains an example Debeziym configuration capturing data in Postgresql and writes it to MySQL
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
### Files

| Filename                 | Description                                                                                          |
|--------------------------|------------------------------------------------------------------------------------------------------|
| kafka.tf                 | Creates a Kafka instance and the 2 connectors used to pull data from Postgresql and push it to MySQL |
| mysql.tf                 | Creates the MySQL instance and database, then it calls the mysql1.sql script                         |
| mysql1.sql               | SQL script placeholder that writes log to out directory                                              |
| postgres.tf              | Creates the MySQL instance and database, then it calls the mysql1.sql script                         |
| postgres1.sql            | SQL script creates a table, inserts rows, setups up aiven_extras, and creates publication            |
| provider.tf              | Sets up the Aiven Terraform provider                                                                 |
| terraform.tfvars.sample  | Template to create the terraform.tfvars file.  Please set before attempting to run                   |
| variables.tf             | Creates variables that get set by the terraform.tfvars file                                          |





