#!/bin/sh

set -e

sudo yum update -y

# Java11 Install
sudo yum install -y java-11-amazon-corretto

# EFS Path Mount
sudo mkdir -p /${efs_mount_point}
sudo yum -y install amazon-efs-utils
sudo su -c  "echo '${file_system_id}:/ /${efs_mount_point} efs _netdev,tls 0 0' >> /etc/fstab"
sudo mount /${efs_mount_point}
df -k

# Grafana Install
sudo bash -c "cat <<EOF > /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://packages.grafana.com/enterprise/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF"
sudo yum -y install grafana

# Prometheus Install
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-amd64.tar.gz
sudo tar xf prometheus-2.48.0.linux-amd64.tar.gz
sudo mkdir -p /etc/prometheus
cd prometheus-2.48.0.linux-amd64
sudo mv prometheus console_libraries consoles /etc/prometheus
sudo bash -c "cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  scrape_timeout: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'cloudn-monitor'

#rule_files:
  #- "rule.yml"
  #- "rule2.yml"

alerting:
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
      - "localhost:9093"

scrape_configs:
  - job_name: 'everyday'
    metrics_path: '/cloudn/manage/prometheus'
    static_configs:
      - targets: ['52.78.168.39:9091']
  - job_name: 'depa'
    metrics_path: '/cloudn/manage/prometheus'
    static_configs:
      - targets: ['3.36.145.196:9091']
EOF"

sudo bash -c 'cat <<EOF > /etc/prometheus/web.yml
basic_auth_users:
    admin: "${basic_auth_token}"
EOF'

sudo bash -c "cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=root
restart=on-failure
ExecStart=/etc/prometheus/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--web.config.file=/etc/prometheus/web.yml \
--storage.tsdb.path=/${efs_mount_point} \
--web.console.templates=/etc/prometheus/console \
--web.console.libraries=/etc/prometheus/console_libraries \
--web.listen-address=0.0.0.0:9090 \
--web.external-url=

[Install]
WantedBy=multi-user.target
EOF"

# alertmanager install
sudo mkdir -p /etc/alertmanager
sudo wget https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-amd64.tar.gz
sudo tar -xvf alertmanager-0.26.0.linux-amd64.tar.gz
sudo mv alertmanager-0.26.0.linux-amd64/* /etc/alertmanager
sudo rm alertmanager-0.26.0.linux-amd64.tar.gz

sudo bash -c "cat <<EOF > /etc/systemd/system/alertmanager.service
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=root
restart=on-failure
ExecStart=/etc/alertmanager/alertmanager \
--config.file=/etc/alertmanager/alertmanager.yml

[Install]
WantedBy=multi-user.target
EOF"

sudo bash -c 'cat <<EOF > /etc/alertmanager/alertmanager.yml
global:
  slack_api_url: "${slack_url}"

route:
  receiver: "cloudn"
  repeat_interval: 2m
receivers:
  - name: "cloudn"
    slack_configs:
    - channel: "${slack_channel}"
      send_resolved: true
      title: "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
      text: "{{ range .Alerts }}{{ .Annotations.description }}\n{{ end }}"
EOF'

sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl restart grafana-server
sudo systemctl enable prometheus.service
sudo systemctl start prometheus.service
sudo systemctl enable alertmanager.service
sudo systemctl start alertmanager.service
