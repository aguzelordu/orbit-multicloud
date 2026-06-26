# Orbit Multi-Cloud Infrastructure Project

This repository contains the multi-cloud infrastructure deployment blueprints for the Orbit enterprise environment. The project demonstrates Infrastructure as Code (IaC) best practices across **AWS**, **GCP**, and **Azure** to build a secure, scalable, and compliant hybrid-cloud ecosystem.

---

## 🏗️ Architecture Overview

The infrastructure is strategically distributed across three major cloud providers to leverage their distinct core capabilities:

- **AWS & GCP (Core Automation):** Managed via **Terraform** modules to provision global core networking (VPCs, Subnets) and basic security boundaries.
- **Azure (Enterprise Workloads & Compliance):** Managed via **Azure Bicep** and compiled into **Template Specs** to deploy institutional workloads (3-tier Virtual Network, Network Security Groups, and Azure SQL Server) under strict governance policies.

---

## 🛠️ Repository Structure

```
orbit-3-multicloud-project/
├── terraform/
│   ├── aws/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── modules/
│   │       ├── vpc/
│   │       ├── alb/
│   │       └── asg/
│   └── gcp/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── modules/
│           ├── vpc/
│           └── compute/
├── azure-templates/
│   ├── main.bicep
│   ├── sql.bicep
│   └── policy.json
├── scripts/
│   ├── azure-deploy.sh
│   ├── aws-test.sh
│   └── gcp-test.sh
└── README.md
```

---

## 🚀 Deployment Guide

### 1. AWS Infrastructure (Terraform)

S3 backend ve DynamoDB lock tablosunu bir kez oluştur:

```bash
aws s3api create-bucket \
  --bucket orbit-multi-tf-state \
  --region us-east-1

aws dynamodb create-table \
  --table-name orbit-multi-tf-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

Ardından deploy et:

```bash
cd terraform/aws
terraform init
terraform apply -auto-approve
```

### 2. GCP Infrastructure (Terraform)

GCS backend bucket'ı bir kez oluştur:

```bash
gcloud storage buckets create gs://orbit-multi-tf-state \
  --location=us-central1
```

`terraform/gcp/terraform.tfvars` dosyasını oluştur:

```hcl
gcp_project_id = "senin-gcp-proje-id'n"
```

Ardından deploy et:

```bash
cd terraform/gcp
terraform init
terraform apply -auto-approve
```

### 3. Azure Infrastructure (Bicep & CLI)

Azure Cloud Shell'de çalıştır:

```bash
export AZURE_ADMIN_PASSWORD="SifreniBuraya123!"
bash scripts/azure-deploy.sh
```

---

## Governance & Compliance (Azure Policy)

Kurumsal metadata standartlarını zorlamak için `policy.json` dosyası bir Azure Policy tanımlar. Bu policy **Deny** etkisiyle zorunlu tag'leri olmayan deploy'ları reddeder.

**Zorunlu Tag'ler:**

| Tag | Değer |
|-----|-------|
| Environment | Prod |
| Owner | Master-Grad |
| CostCenter | 101 |

---

## Karşılaşılan Zorluklar ve Çözümler

### 1. Terraform HCL Syntax Hatası
**Sorun:** `variables.tf` dosyalarında tek satırda `;` ile birden fazla attribute tanımlandı.  
**Çözüm:** Her attribute ayrı satıra alındı. HCL, noktalı virgül ile aynı satırda çoklu attribute desteklemiyor.

### 2. GCP VM Public IP Konfigürasyonu
**Sorun:** `network_interface` bloğunda `access_config` bloğunun bırakılması gerektiği bilinmiyordu.  
**Çözüm:** `access_config` bloğu tamamen kaldırıldı. GCP'de bu bloğun yokluğu VM'e public IP atanmaması anlamına gelir.

### 3. Azure Template Spec vs ARM Deploy Farkı
**Sorun:** `main.bicep` doğrudan deploy edilmek yerine Template Spec olarak yüklenmesi gerekiyordu.  
**Çözüm:** `az ts create` ile Template Spec yüklendi, `az deployment group create --template-spec` ile deploy edildi.

### 4. Bicep `minCapacity` Tip Hatası
**Sorun:** `sql.bicep` içinde `minCapacity: "0.5"` string olarak yazıldı, int/float bekliyordu.  
**Çözüm:** `minCapacity: json('0.5')` olarak düzeltildi.

---

## Destroy Guide (Maliyet Yönetimi)

Doğrulama tamamlandıktan hemen sonra tüm kaynaklar silinmeli.

**AWS & GCP:**
```bash
cd terraform/aws && terraform destroy -auto-approve
cd terraform/gcp && terraform destroy -auto-approve
```

**Azure:**
```bash
az group delete --name orbit-multi-rg --yes --no-wait
```

---

## 📋 CIDR Planı

| Cloud | CIDR |
|-------|------|
| Azure | 10.1.0.0/16 |
| AWS | 10.2.0.0/16 |
| GCP | 10.3.0.0/16 |

> IP aralıkları birbiriyle çakışmayacak şekilde tasarlandı. İleride VPN Peering kurulursa çakışma olmaz.
