#!/bin/bash
# scripts/gcp-operations.sh

echo "=== GCP Gizli VM Durum Sorgulama ve Canli Yedekleme ==="

# 1. VM'in durumunu ve internal IP adresini terminale basıyoruz
echo "Oneri Motoru VM Guncel Durumu:"
gcloud compute instances describe orbit-recommendation-engine \
    --zone=us-central1-a \
    --format="table(name, status, networkInterfaces[0].networkIP)"

echo "--------------------------------------------------"

# 2. Hocanın istediği Snapshot yedekleme operasyonu
echo "VM Disk Snapshot olusturuluyor..."
gcloud compute snapshots create orbit-vm-snapshot-live \
    --source-disk=orbit-recommendation-engine \
    --source-disk-zone=us-central1-a \
    --storage-location=us-central1

echo "--------------------------------------------------"
echo "=== Operasyon Basariyla Tamamlandi. Canli yedek alindi. ==="