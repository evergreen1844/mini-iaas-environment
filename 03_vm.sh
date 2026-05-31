#!/bin/bash
echo "=== 03. 가상머신(VM) KVM 실행 및 IP 초기 설정(Cloud-init) 시작 ==="

# 1. Cloud-init 설정(Seed ISO) 생성
echo "-> VM 초기 설정용 Seed ISO 생성 중..."
PASSWORD=$(openssl passwd -6 ubuntu) # 기본 계정/비번: ubuntu / ubuntu

for i in 1 2 3; do
cat > user-data-$i <<EOF
#cloud-config
password: $PASSWORD
chpasswd: { expire: False }
ssh_pwauth: True
EOF

# 요구사항에 맞춘 정적 IP 192.168.0.x/24 할당
cat > network-config-$i <<EOF
version: 2
ethernets:
  enp0s3:
    dhcp4: false
    addresses: [192.168.0.${i}/24]
EOF

# 설정 파일들을 CD롬 이미지(ISO)로 굽기
cloud-localds -N network-config-$i seed$i.iso user-data-$i
done

# 지저분한 임시 파일 삭제
rm -f user-data-* network-config-*

# 2. Ceph RBD를 커널 블록 디바이스로 매핑
echo "-> RBD 매핑 중..."
sudo rbd map vmpool/vm1-image 2>/dev/null || true
sudo rbd map vmpool/vm2-image 2>/dev/null || true
sudo rbd map vmpool/vm3-image 2>/dev/null || true

# 3. VM 실행
echo "-> vm-1 실행 중 (IP: 192.168.0.1, vnet-A)..."
sudo qemu-system-x86_64 -enable-kvm -m 1024 -smp 1 \
  -name vm-1 \
  -drive format=raw,file=/dev/rbd/vmpool/vm1-image,if=virtio \
  -cdrom seed1.iso \
  -netdev bridge,br=vnet-A,id=net0 \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:11:11:11 \
  -vnc :1 -daemonize

echo "-> vm-2 실행 중 (IP: 192.168.0.2, vnet-A)..."
sudo qemu-system-x86_64 -enable-kvm -m 1024 -smp 1 \
  -name vm-2 \
  -drive format=raw,file=/dev/rbd/vmpool/vm2-image,if=virtio \
  -cdrom seed2.iso \
  -netdev bridge,br=vnet-A,id=net1 \
  -device virtio-net-pci,netdev=net1,mac=52:54:00:22:22:22 \
  -vnc :2 -daemonize

echo "-> vm-3 실행 중 (IP: 192.168.0.3, vnet-B)..."
sudo qemu-system-x86_64 -enable-kvm -m 1024 -smp 1 \
  -name vm-3 \
  -drive format=raw,file=/dev/rbd/vmpool/vm3-image,if=virtio \
  -cdrom seed3.iso \
  -netdev bridge,br=vnet-B,id=net2 \
  -device virtio-net-pci,netdev=net2,mac=52:54:00:33:33:33 \
  -vnc :3 -daemonize

echo "=== VM 3개 실행 및 IP 할당 완료 ==="
