# Auto Scaling with CloudWatch Scaling Alarms

Deploys a web tier on AWS: an internet-facing ALB in public subnets forwards HTTP to Nginx EC2 instances in private subnets. An Auto Scaling Group adds or removes instances based on CloudWatch CPU alarms, which also notify an SNS topic. Three modules: `network`, `security`, `compute`.

## Module map

| Module | Creates | Key inputs | Key outputs |
|---|---|---|---|
| `network` | VPC, IGW, 3 public + 3 private subnets, 2 route tables, EIP, 1 NAT GW | `vpc_cidr`, `availability_zones`, `name_prefix` | `vpc_id`, `public_subnet_ids`, `private_subnet_ids` |
| `security` | ALB SG, EC2 SG | `vpc_id`, `name_prefix` | `alb_security_group_id`, `ec2_security_group_id` |
| `compute` | ALB, target group, listener, launch template, ASG, 2 scaling policies, 2 CloudWatch alarms, SNS topic (+ email subscription) | subnets, SG IDs, `ami_id`, `instance_type`, `min/max/desired`, `notification_email` | `load_balancer_dns_name`, `autoscaling_group_name`, alarm names, `notification_topic_arn` |

## Module wiring

Root [main.tf](main.tf) connects the modules. Order is implied by these references.

```
root vars ──vpc_cidr, availability_zones──────────► network
network.vpc_id ───────────────────────────────────► security.vpc_id
network.vpc_id ───────────────────────────────────► compute.vpc_id
network.public_subnet_ids ────────────────────────► compute.public_subnet_ids   (-> ALB)
network.private_subnet_ids ───────────────────────► compute.private_subnet_ids  (-> ASG)
security.alb_security_group_id ───────────────────► compute.alb_security_group_id (-> ALB)
security.ec2_security_group_id ───────────────────► compute.ec2_security_group_id (-> launch template)
root vars ──ami_id, instance_type, min/max/desired, notification_email──► compute
compute.load_balancer_dns_name ───────────────────► root output application_url
```

Inside `compute`: ALB → listener → target group ← ASG (`target_group_arns`). Alarms → scaling policies (+ SNS).

## Architecture

```
                         Internet
                            │
                     ┌──────▼──────┐
                     │     IGW     │
                     └──────┬──────┘
┌───────────────────────────┼───────────────── VPC 10.0.0.0/16 ──────────┐
│  PUBLIC subnets (rt: 0.0.0.0/0 -> IGW)                                 │
│  10.0.0.0/24 (az-a)   10.0.1.0/24 (az-b)   10.0.2.0/24 (az-c)          │
│  ┌──────────────────── ALB (alb-sg) ───────────────────┐               │
│  └───────────────┬─────────────────────────────────────┘               │
│  ┌───────────────┴──┐ NAT GW + EIP (az-a only)  ▲                      │
│  └──────────────────┘                           │ outbound             │
│        │ HTTP :80 (target group, health check /)│                      │
│  PRIVATE subnets (rt: 0.0.0.0/0 -> NAT GW)      │                      │
│  10.0.3.0/24 (az-a)   10.0.4.0/24 (az-b)   10.0.5.0/24 (az-c)          │
│  ┌────────────────────────────────────────────────┐                    │
│  │ ASG: EC2 Nginx instances (ec2-sg), min 1–max 3 │────────────────────┘
│  └────────────────────────────────────────────────┘                    │
└────────────────────────────────────────────────────────────────────────┘
 CloudWatch (AWS/EC2 CPU, ASG avg) ─alarm─► scaling policy ±1 ─► ASG
                                    └─────► SNS topic ─► email
```

## Networking

| Subnet tier | CIDRs (default) | `cidrsubnet(vpc, 8, n)` | Route table → default route | Why |
|---|---|---|---|---|
| Public | `10.0.0.0/24`, `.1.0/24`, `.2.0/24` | n = 0–2 | `0.0.0.0/0` → IGW | Hosts ALB and NAT GW; auto-assign public IP |
| Private | `10.0.3.0/24`, `.4.0/24`, `.5.0/24` | n = 3–5 | `0.0.0.0/0` → NAT GW | Instances have no public IP and can't be reached directly from the internet |

- Traffic inside the VPC (`10.0.0.0/16`) uses the implicit `local` route in both tables.
- Inbound from the internet: IGW → ALB → instance. Instances never see the internet directly.
- Outbound from instances (apt, updates): private subnet → NAT GW (public subnet) → IGW. NAT only allows connections started from inside.
- One shared route table per tier, not per AZ.
- One NAT GW in the first AZ only: cheaper, but a single point of failure for outbound traffic.

## Security groups

SGs are stateful: replies to allowed inbound traffic are allowed out automatically.

| SG | Module | Attached to | Inbound | Outbound | Why |
|---|---|---|---|---|---|
| `<prefix>-alb-sg` | `security` | ALB | TCP 80 and 443 from `0.0.0.0/0` | All, `0.0.0.0/0` | Public entry point |
| `<prefix>-ec2-sg` | `security` | ASG instances (launch template) | TCP 80 from **`alb-sg`** | All, `0.0.0.0/0` (via NAT) | Only the ALB can reach instances; outbound for package installs |

**SG-to-SG reference:** `ec2-sg` allows `security_groups = [alb-sg]` instead of a CIDR. Any resource carrying `alb-sg` is allowed, whatever its IP. This keeps working as the ALB's IPs change across AZs. Nothing else, even inside the VPC, can hit port 80 on the instances.

Notes: ALB outbound is wide open (could be limited to `ec2-sg` on port 80). Port 443 is open on the ALB, but no HTTPS listener exists, so it does nothing.

## IAM

None defined. No roles, policies or instance profiles. Consequences: instances have no AWS API access, and no SSM Session Manager. The launch template sets no key pair, so there is no SSH access either. CloudWatch alarms call the scaling policies and SNS through service-linked mechanisms, so no explicit IAM is needed.

## How to run

Prerequisites:
- Terraform `>= 1.6, < 2.0`; AWS provider `~> 6.0` (see [versions.tf](versions.tf)).
- AWS credentials (CLI profile or env vars) with rights for VPC, EC2/ASG, ELB, CloudWatch and SNS.
- Region defaults to `eu-north-1`, with AZs `eu-north-1a/b/c` and an Ubuntu 22.04 AMI. Override in `terraform.tfvars` if you change region (exactly 3 AZs required).
- Set `notification_email` (default is a personal address) or `""` to disable the subscription. The recipient must confirm the SNS email.

```powershell
terraform init
terraform plan -out tfplan
terraform apply tfplan
terraform output application_url   # open in browser
terraform destroy                  # NAT GW and ALB cost money
```

State: no backend block, so state is local (`terraform.tfstate`). Not suitable for teams.

## Assumptions

- Nginx is installed by [user_data.sh](modules/compute/user_data.sh); I did not review it.
- Scaling thresholds (CPU ≥70% scale out, ≤40% scale in, 2×60 s, 300 s cooldown) are hardcoded in `compute`, not variables.
- Free-tier region/AZ limits mentioned in the old README are not verified.
