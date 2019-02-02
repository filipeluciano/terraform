resource "aws_db_parameter_group" "aurora_db_parameter_group" {
  name = "sov-mgmt-seap1-aurora-mysql-parametergroup"
  family = "aurora-mysql5.7"
  description = "sov-mgmt-seap1-aurora-mysql-parametergroup"

  parameter {
    name = "autocommit"
    value = "1"
  }

  parameter {
    name = "time_zone"
    value = "UTC"
  }

  parameter {
    name = "max_connections"
    value = "50"
  }

  parameter {
    name = "max_connect_errors"
    value = "10"
  }

  parameter {
    name = "slow_query_log"
    value = "1"
  }

  parameter {
    name = "general_log"
    value = "1"
  }

  parameter {
    name = "long_query_time"
    value = "10"
  }

  parameter {
    name = "log_output"
    value = "FILE"
  }
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group" {
  name = "sov-mgmt-seap1-aurora-mysql-clusterparametergroup"
  family = "aurora-mysql5.7"
  description = "sov-mgmt-seap1-aurora-mysql-clusterparametergroup"

  parameter {
    name = "binlog_format"
    value = "OFF"
  }

  parameter {
    name = "server_audit_logging"
    value = "1"
  }

  parameter {
    name = "server_audit_events"
    value = "CONNECT,QUERY,QUERY_DCL,QUERY_DDL,QUERY_DML,TABLE"
  }
}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
  count = 3
  identifier = "seap1-${substr(aws_rds_cluster.aurora_cluster.availability_zones[count.index % length(aws_rds_cluster.aurora_cluster.availability_zones)],-1,1)}${count.index / length(aws_rds_cluster.aurora_cluster.availability_zones) + 1}"
  cluster_identifier = "${aws_rds_cluster.aurora_cluster.id}"
  instance_class = "db.t2.medium"
  availability_zone = "${aws_rds_cluster.aurora_cluster.availability_zones[count.index %  length(aws_rds_cluster.aurora_cluster.availability_zones)]}"
  engine = "aurora-mysql"
  engine_version = "5.7.12"
  promotion_tier = "${count.index}"
  db_parameter_group_name = "${aws_db_parameter_group.aurora_db_parameter_group.id}"
  auto_minor_version_upgrade = "true"
}

/*
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = "seap1"
  engine = "aurora-mysql"
  engine_version = "5.7.12"
  availability_zones = ["ap-southeast-2a","ap-southeast-2b","ap-southeast-2c"]
  database_name = "sea"
  master_username = "admin"
  master_password = "password"
  backup_retention_period = 30
  preferred_backup_window = "00:00-06:00"
  skip_final_snapshot = true
  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.aurora_cluster_parameter_group.id}"

}*/

resource "aws_rds_cluster" "seap1" {
  cluster_identifier = "seap1"
  database_name = "sea"
  master_username = "admin"
  master_password = "password"
  port = "3306"
  storage_encrypted = "true"
//  kms_key_id = "/alias/aws/rds"
  backup_retention_period = "30"
  preferred_maintenance_window = "mon:15:42-mon:04:30"
}
