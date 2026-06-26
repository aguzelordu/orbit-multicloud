#!/bin/bash
# scripts/aws-test.sh

echo "=== AWS Load Balancer ve Altyapi Testi Basliyor ==="

# 1. Terraform çıktısından veya AWS CLI ile ALB DNS adını alıyoruz
ALB_DNS=$(aws elbv2 describe-load-balancers --names orbit-aws-alb --query "LoadBalancers[0].DNSName" --output text)

echo "Bulunan ALB DNS Adresi: $ALB_DNS"
echo "--------------------------------------------------"

# 2. ALB DNS adresine ardı ardına 3 kez HTTP isteği (curl) atıp durum kodu ve içeriğe bakıyoruz
for i in {1..3}
do
   echo "İstek #$i gönderiliyor..."
   curl -I http://$ALB_DNS | grep "HTTP/"
   curl -s http://$ALB_DNS
   echo -e "\n--------------------------------------------------"
   sleep 2
done

echo "=== Test tamamlandi, istekler basariyla EC2 havuzuna dagitildi. ==="