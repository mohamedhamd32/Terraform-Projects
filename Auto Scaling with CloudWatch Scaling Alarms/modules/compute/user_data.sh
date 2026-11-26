#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y nginx stress-ng
systemctl enable --now nginx
printf '%s\n' 'Nginx is running on an Auto Scaling instance.' > /var/www/html/index.html

# Load test: all CPUs at 90% for 15 minutes to trigger the scale-out alarm. Remove after testing.
systemd-run --unit=cpu-stress stress-ng --cpu 0 --cpu-load 90 --timeout 15m