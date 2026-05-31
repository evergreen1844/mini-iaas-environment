#!/bin/bash
echo "=== 01. MicroCeph 클러스터 및 RBD 디스크 생성 시작 ==="

# 1. 클러스터 초기화 (이미 되어있으면 자동으로 넘어감)
sudo microceph cluster bootstrap

# 2. 가상 디스크(OSD) 3개 동시 추가 (명령어 문법 완전 수정)
# 문법: loop,용량,개수 (10G짜리 3개 동시 생성)
sudo microceph disk add loop,10G,3

# Ceph 상태가 OK가 될 때까지 넉넉히 대기
echo "OSD 초기화 대기 중 (30초)..."
sleep 30 

# 3. Ceph 설정 파일 및 인증키 심볼릭 링크
sudo mkdir -p /etc/ceph
sudo cp /var/snap/microceph/current/conf/ceph.conf /etc/ceph/ceph.conf
sudo cp /var/snap/microceph/current/conf/ceph.client.admin.keyring /etc/ceph/ceph.client.admin.keyring
sudo chmod 644 /etc/ceph/ceph.conf
sudo chmod 644 /etc/ceph/ceph.client.admin.keyring

# 4. VM 디스크를 저장할 Pool 생성
sudo microceph.ceph osd pool create vmpool 2>/dev/null || true
sudo microceph.ceph osd pool application enable vmpool rbd 2>/dev/null || true

# 5. 우분투 24.04 클라우드 이미지 다운로드
if [ ! -f noble-server-cloudimg-amd64.img ]; then
    wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
fi

# 6. qcow2를 raw 포맷으로 변환
if [ ! -f noble.raw ]; then
    qemu-img convert -f qcow2 -O raw noble-server-cloudimg-amd64.img noble.raw
fi

# 7. 각 VM용 RBD 이미지 생성 및 OS 주입
for i in 1 2 3; do
    echo "vm-$i 디스크 생성 중..."
    sudo rbd import noble.raw vmpool/vm$i-image
done

echo "=== MicroCeph 구성 및 RBD 준비 완료 ==="
