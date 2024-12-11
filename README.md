# AWS Backup Service - Creating Backup of RDS

## Usage

1. **Install Terraform**: Ensure you have Terraform installed on your machine. If not, download it from [terraform.io](https://www.terraform.io/downloads.html).

2. Clone this repository:

   ```bash
   git clone <repository-url>
   cd <repository-name>

   ```

3. **Set Up AWS Provider**

- Machine from which this terraform is ran, either should have

  - revelant IAM role attached to itOR
  - Export following as environment variables

    ```bash
    export AWS_DEFAULT_REGION=ap-southeast-2
    export AWS_ACCESS_KEY_ID=
    export AWS_SECRET_ACCESS_KEY=
    export AWS_SESSION_TOKEN=
    ```

4. **Initialize Terraform**: Run the following command to initialize your Terraform workspace:

   ```bash
   terraform init
   ```

5. **Plan the Deployment**: To see the changes that will be made, run:

   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```

6. **Apply the Configuration**: Deploy the resources with:

   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

# AWS RDS PostgreSQL with Terraform

This Terraform configuration provisions and manages an AWS RDS PostgreSQL database instance with associated resources, ensuring a secure, optimized, and scalable database setup.

---

## Features

1. **RDS PostgreSQL Instance**:

   - Deploys a PostgreSQL database instance with configurable engine version, instance type, and storage.
   - Enables performance insights and CloudWatch logs for monitoring.

2. **Custom Parameter Group**:

   - Defines and applies a custom parameter group for fine-tuned database behavior, including logging configurations.

3. **Event Subscription**:

   - Subscribes to RDS events (e.g., failovers, low storage) and sends notifications to an SNS topic.

4. **Networking and Security**:

   - Configures security groups to manage database access.
   - Allows the instance to be publicly accessible (configurable via the `publicly_accessible` setting).

5. **Automated Backups**:
   - Configures backup retention, maintenance windows, and snapshots for durability.

---

## Variables

| Variable                | Description                     | Default Value |
| ----------------------- | ------------------------------- | ------------- |
| `engine_version`        | PostgreSQL engine version       | `17.1`        |
| `instance_class`        | Database instance class         | `db.t3.small` |
| `db_name`               | Name of the database            | `appdb`       |
| `allocated_storage`     | Initial allocated storage in GB | `20`          |
| `max_allocated_storage` | Maximum allocated storage in GB | `100`         |
| `username`              | Database master username        | `postgres`    |
| `password`              | Database master password        | _Required_    |
| `tags`                  | Tags to apply to all resources  | `{}`          |

---

## Resources Created

### 1. **RDS Instance**

- A PostgreSQL database instance with:
  - Configurable storage (`gp3` type by default).
  - Enhanced monitoring with CloudWatch logs.
  - Performance insights enabled with a 7-day retention period.

### 2. **Custom DB Parameter Group**

- Applies PostgreSQL-specific parameters such as:
  - Logging configurations (`log_temp_files`, `log_lock_waits`).
  - Preload libraries for performance (`shared_preload_libraries`).

### 3. **RDS Event Subscription**

- Subscribes to critical database events (e.g., failovers, low storage) and sends notifications to an SNS topic.
