# Infrastructure for the Managed Service for YDB and Data Transfer.
#
# RU: https://cloud.yandex.ru/ru/docs/data-transfer/tutorials/yds-to-ydb
# EN: https://cloud.yandex.com/en/docs/data-transfer/tutorials/yds-to-ydb
#
# Set the source and target database settings.
locals {
  # Source YDB settings:
  source_db_name     = "" # Set a YDB database name.
  source_endpoint_id = "" # Set the source endpoint id.

  # Target YDB settings:
  target_db_name     = "" # Set a YDB database name.
  target_endpoint_id = "" # Set the target endpoint id.

  # Transfer settings:
  transfer_enable = 0 # Set to 1 to enable transfer.
}

resource "yandex_vpc_network" "network" {
  name        = "network"
  description = "Network for the Managed Service for YDB"
}

# Subnet in ru-central1-a availability zone
resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.1.0.0/16"]
}

# Security group for the Managed Service for YDB
resource "yandex_vpc_default_security_group" "security-group" {
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    description    = "Allow connections to the Managed Service for YDB from the Internet"
    port           = 2135
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow outgoing connections to any required resource"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_ydb_database_serverless" "source-ydb" {
  name        = local.source_db_name
  location_id = "ru-central1"
}

resource "yandex_ydb_database_serverless" "target-ydb" {
  name        = local.target_db_name
  location_id = "ru-central1"
}

resource "yandex_datatransfer_transfer" "yds-ydb-transfer" {
  count       = local.transfer_enable
  description = "Transfer from the the Yandex Data Streams to the Managed Service for YDB"
  name        = "transfer-from-yds-to-ydb"
  source_id   = local.source_endpoint_id
  target_id   = local.target_endpoint_id
  type        = "INCREMENT_ONLY" # Replication data from the source Data Stream.
}