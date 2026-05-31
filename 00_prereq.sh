#!/bin/bash
echo "=== 00. 패키지 업데이트 및 필수 패키지 설치 시작 ==="
sudo apt-get update -y

# 1. KVM/QEMU 패키지 및 브릿지 네트워크 헬퍼
sudo apt-get install -y qemu-system-x86 qemu-utils bridge-utils

# 2. IP 세팅 및 네트워크 도구 (iproute2)
sudo apt-get install -y iproute2 iptables

# 3. MicroCeph 설치
sudo snap install microceph

# 4. OS 이미지 다운로드 및 클라우드 초기화(Cloud-init)용 도구
sudo apt-get install -y wget cloud-image-utils ceph-common

echo "=== 필수 패키지 설치 완료 ==="
