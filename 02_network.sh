#!/bin/bash
echo "=== 02. 가상 네트워크(VNet) L2 격리 구성 시작 ==="

# 1. vnet-A 구성 (vm1, vm2 용)
sudo ip link add vnet-A type bridge
sudo ip link set vnet-A up

# 2. vnet-B 구성 (vm3 용 - vnet-A와 물리적으로 다른 브릿지라 L2 완전 분리됨)
sudo ip link add vnet-B type bridge
sudo ip link set vnet-B up

# 3. QEMU가 브릿지를 사용할 수 있도록 권한 부여
sudo mkdir -p /etc/qemu
echo "allow vnet-A" | sudo tee /etc/qemu/bridge.conf
echo "allow vnet-B" | sudo tee -a /etc/qemu/bridge.conf
sudo chmod u+s /usr/lib/qemu/qemu-bridge-helper

echo "=== 네트워크 구성 완료 (vnet-A, vnet-B) ==="
