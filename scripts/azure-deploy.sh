#!/bin/bash
# scripts/azure-deploy.sh

echo "=== Azure Bicep Altyapi Dagitimi Basliyor ==="

# Resource Group oluşturma (Eğer yoksa)
az group create --name orbit-multicloud-rg --location eastus

# Bicep şablonunu canlıya gönderme (Güvenli şifreyi canlı parametre olarak paslıyoruz)
az deployment group create \
  --resource-group orbit-multicloud-rg \
  --template-file ../azure-templates/main.bicep \
  --parameters sqlAdminPassword='OrbitSecurePassword99!'

echo "=== Azure Dagitimi Tamamlandi! ==="