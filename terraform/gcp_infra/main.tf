# 1. Custom VPC (IP çakışması olmaması için AWS'ten farklı blok: 10.1.0.0/16)
resource "google_compute_network" "custom_vpc" {
  name                    = "orbit-gcp-vpc"
  auto_create_subnetworks = false
}

# 2. Subnet Açılması
resource "google_compute_subnetwork" "gcp_subnet" {
  name          = "orbit-gcp-subnet"
  ip_cidr_range = "10.1.1.0/24"
  region        = var.gcp_region
  network       = google_compute_network.custom_vpc.id
}

# 3. Güvenlik Duvarı Kuralları (Sadece Cloud IAP IP bloğuna izin verilir: 35.235.240.0/20)
resource "google_compute_firewall" "allow_iap" {
  name    = "orbit-allow-iap-ssh"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-ssh-enabled"]
}

# 4. Compute Engine Instance (Dışarıya tamamen kapalı, Public IP'siz)
resource "google_compute_instance" "recommendation_engine" {
  name         = "orbit-recommendation-engine"
  machine_type = "e2-micro"
  zone         = var.gcp_zone
  tags         = ["iap-ssh-enabled"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.gcp_subnet.id
    # Burası boş bırakıldığı için harici (public) IP atanmaz, tamamen gizli kalır.
  }

  metadata_startup_script = "echo 'Recommendation Engine Simulated'"
}