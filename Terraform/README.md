# Terraform Directory

## An example Debezium configuration capturing data from Postgres and writing to MySQL

### Setup variables
* copy terraform.tfvars.sample to terraform.tfvars
* update terrform.tfvars with the relevant data

### Terraform commands
The commands must be issued inside the Terraform directory
* `terraform init` - Used to initialize the Terraform client
* `terraform plan` - Used to check what Terraform plans to do if applied
* `terraform apply -auto-approve` - Used to execute the Terraform plan
* `terraform output` - Show output parameters from the previous apply
* `terraform plan -destroy` - Used to check what Terraform plans to do if a destroy command is issued
* `terraform destroy` - Used to remove the resources from the Terraform plan

### Terminal commands
* `avn service cli pg1` - Used to connect on command line to the Postgres database
* `terraform output pg1_connect` - Used to get connection information for postgres
* `export PGPASSWORD=xxx;psql --host=xxx --port=xxx --user=appuser --dbname=pg1db1` - Used to connect on command line to the Postgres database  
* `terraform output mysql1_connect` - Used to get connection information for mysql
* `mysql --host=xxx --port=xxx --user=appuser --password=xxx mysqldb1` - Used to connect on command line to the MySQL database

### Files
| Filename                | Description                                                                          |
|-------------------------|--------------------------------------------------------------------------------------|
| kafka.tf                | Creates a Kafka instance and 2 connectors used to pull data from Postgresql to MySQL |
| mysql.tf                | Creates the MySQL instance and database, then it calls the mysql1.sql script         |
| mysql1.sql              | SQL script placeholder that writes log to out directory                              |
| postgres.tf             | Creates the MySQL instance and database, then it calls the mysql1.sql script         |
| postgres1.sql           | SQL script creates a table with rows, adds aiven_extras, and creates publication     |
| provider.tf             | Sets up the Aiven Terraform provider                                                 |
| terraform.tfvars.sample | Template to create the terraform.tfvars file.  Please set before attempting to run   |
| variables.tf            | Creates variables that get set by the terraform.tfvars file                          |

### Demo Script
1. Prior to demo run `trerafiorm apply -auto-approve`
2. Connect to the Postgres database
   ``` BASH
   eval $(terraform output -raw pg1_command)
   ```
3. Connect to the MySQL database
   ``` BASH
   eval $(terraform output -raw mysql1_command)
   ```
4. In Postgres window show the current state of the table
   ``` SQL
   select * from words;
   ```
5. In MySQL window show the current state of the table
   ``` SQL
   select * from words;
   ```
6. Make some changes on the Postgres database
   ``` SQL
   delete from words where id=2;
   update words set word='hello' where id=1;
   insert into words values (DEFAULT, 'how',DEFAULT), (DEFAULT, 'are',DEFAULT), (DEFAULT, 'you',DEFAULT);
   select * from words;
   ```
7. Validate changes are made in MySQL
   ``` SQL
   select * from words;
   ```
   Note the deleted row is a tombstone on the MySQL side.
