# E-Commerce DevOps Lab — Terraform + Ansible + Docker + GitHub Actions (AWS / Learner Lab)

GitHub Actions provisions AWS infrastructure with **Terraform**, configures the
EC2 hosts with **Ansible**, and deploys a containerized e-commerce app
(**Nginx → Node.js/PM2 → MongoDB**) behind an **Application Load Balancer**.

```
git push  →  GitHub Actions
                 ↓
Terraform → AWS (VPC, public+private subnets, NAT, ALB, EC2, bastion)
                 ↓
Ansible (via bastion) → Docker + app deployment on the private EC2 hosts
                 ↓
ALB → Nginx → Node.js → MongoDB
```

## Architecture (matches the lab diagram)

- VPC `10.0.0.0/16`, two **public** and two **private** subnets across two AZs.
- Internet Gateway for the public subnets; a **NAT gateway per AZ** so the
  private instances can reach the internet (yum, image pulls) without being
  publicly reachable.
- Public **ALB** in the public subnets → app **EC2 instances in the private
  subnets** (port 80).
- A small **bastion host** in a public subnet. The app instances have no public
  IP, so Ansible (running on the GitHub runner) connects to the bastion first
  and hops to each private instance via SSH ProxyJump. This is the standard way
  to manage private instances and resolves the "SSH into private EC2" gap in the
  original lab pipeline.

## IMPORTANT — AWS Academy Learner Lab notes

Learner Lab credentials are **temporary** and **rotate every session**:

1. Click **Start Lab** and wait for the dot next to "AWS" to turn green.
2. Open **AWS Details → AWS CLI → Show**. You'll see four values:
   `aws_access_key_id`, `aws_secret_access_key`, `aws_session_token`, region.
3. Open **AWS Details → SSH key → Download PEM** — this is your `vockey.pem`.

Because the access key, secret, and **session token change every time you Start
Lab**, you must re-paste them into the GitHub secrets at the start of each
session, or the pipeline fails with an expired-token error. The region
(`us-east-1`) and the key pair (`vockey`) stay the same.

## GitHub secrets (Settings → Secrets and variables → Actions)

| Secret | Where it comes from |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | AWS Details → AWS CLI → Show |
| `AWS_SECRET_ACCESS_KEY` | AWS Details → AWS CLI → Show |
| `AWS_SESSION_TOKEN` | AWS Details → AWS CLI → Show (required for Learner Lab) |
| `AWS_REGION` | `us-east-1` |
| `EC2_KEY` | Full contents of the downloaded `vockey.pem` |

## Run it

```bash
git add .
git commit -m "AWS Learner Lab pipeline"
git push origin main
```

Then watch **GitHub → Actions**:

1. **Provision Infrastructure** — Terraform builds the VPC, NAT, ALB, bastion, and 2 private EC2 instances.
2. **Configure Servers** — the pipeline writes `vockey.pem`, builds an inventory of the private IPs (through the bastion), and runs Ansible to install Docker and start the app.

When it finishes, open the **ALB DNS name** (printed in the "Provision
Infrastructure" job log, or run `terraform output alb_dns_name`). You should see:

```
E-Commerce Store
- Laptop $1200
- Phone $800
```

## Tear it down (save your budget!)

NAT gateways and EC2 cost money while running. When you're done:

**GitHub → Actions → "Full DevOps Pipeline (AWS / Learner Lab)" → Run workflow**
(the manual run triggers the `destroy` job, which runs `terraform destroy`).

Also click **End Lab** in the Learner Lab when finished.

## Repository structure

```
ecommerce-devops-lab/
├── terraform/
│   ├── versions.tf        # AWS provider
│   ├── variables.tf       # region, vockey, sizing
│   ├── vpc.tf             # VPC, public+private subnets, IGW, NAT
│   ├── security_groups.tf # ALB / bastion / EC2 SGs
│   ├── alb.tf             # ALB, target group, listener
│   ├── ec2.tf             # app instances (private) + TG attachment
│   ├── bastion.tf         # jump host (public)
│   └── outputs.tf         # private IPs, bastion IP, ALB DNS
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini      # sample (CI generates inventory.generated.ini)
│   └── deploy.yml         # yum install Docker, deploy app, verify
├── app/                   # Node.js store, runs under PM2
├── nginx/default.conf     # reverse proxy :80 -> app:3000
├── docker-compose.yml     # nginx + app + mongo
└── .github/workflows/
    └── pipeline.yml       # terraform -> ansible -> (manual) destroy
```

## Troubleshooting

| Issue | Fix |
| --- | --- |
| `ExpiredToken` / auth error in Terraform | Learner Lab credentials rotated — re-copy all three (key, secret, **session token**) into the GitHub secrets |
| Ansible can't SSH | Confirm `EC2_KEY` is the full `vockey.pem`, and the bastion SG allows port 22 |
| ALB shows 502/503 | Targets still warming up; re-check after a minute, or check the app container on a host via the bastion |
| Terraform fails creating NAT/EIP | Learner Lab quota — destroy any leftover stacks, or reduce to one NAT/AZ |
