provider "aws" {
  region = "us-east-1"
}

resource "kubernetes_storage_class" "talant-storage-class" {
  metadata {
    name = "standard"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"
  parameters = {
    type    = "gp2"
    # zone    = "us-east-1"
    # fsType  = "ext4"
  }
}

resource "kubernetes_persistent_volume_claim" "talant-pvc" {
  metadata {
    name = "pvc-jenkins"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  storage_class_name = kubernetes_storage_class.talant-storage-class.metadata.0.name
  }

  tags = {
    Name = "new-volume"
  }
}
