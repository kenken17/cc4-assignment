# Background

I have limited experience on actual Terraform provisioning. I am trying my best to reason and come out with a solution that fit the requirements.

# High-level Requirements

- A private network which would best suit Symbiosis’s 3-tier architecture needs. In order to meet their internal SLA’s they require a highly scalable solution as well.
- Symbiosis being a B2C company, needs their applications to be accessible over the internet.
- Symbiosis aims to reduce the administrative burden of managing their database and prefer a managed and highly scalable database.
- Symbiosis encounters medium to high traffic levels daily during business hours. Given the fluctuating nature of this traffic, they are in need of a cost-effective solution that can dynamically scale to meet varying workload demands automatically.
- Symbiosis is interested in your recommendations for various metrics that can be monitored to enhance customer satisfaction.

# Tasks

- You are expected to use AWS for this assignment, to keep cost minimum try limiting to free tier eligible resources.
- Use Terraform to build the challenge using IaC
- Push the completed assignment to any public repo (Github or Gitlab)
- You can choose any application to host for assignment#1. A good example of a web application that does CRUD operations can also be found here: https://github.com/chapagain/nodejs-mysql-crud

#### Solution:

ALl the files are under `./tf/`. Since this is a phase by phase setup. Suggest to copy files step by step.

Let's create a user so we could start provisioning. Make sure we have an admin profile called `cc4`.

Copy user setup under `./tf/01-user.tf` to a new folder `./cc4/`

**Note**: For security, we could have stricter policy and enforce MFA for the group

```bash
# Run under ./cc4/ folder
terraform init

terraform plan

terraform apply
```

Then we should setup the remote state instead local versioning the state.

Copy remote state setup under `./tf/02-remote-state.tf` to `./cc4/`

```bash
# Run under ./cc4/ folder
terraform plan

terraform apply
```

Copy backend setup under `./tf/03-terraform.tf` to `./cc4/`

```bash
# Run under ./cc4/ folder
terraform init
```

Then answer `Yes` for copying the state to the remote and remove the local state file.

```bash
rm terraform.tfstate
```

Create the three tier architecture starting by create a simple vpc with 6 subnets across two AZ (2 publics and 4 privates).

```bash
# Run under ./cc4/ folder
terraform init

terraform plan

terraform apply
```

Copy vpc & subnets setup under `./tf/04-vpc.tf` to `./cc4/`
