#!/bin/bash
echo "=== 04. 가상 네트워크(VNet) L2 통신 격리 테스트 시작 ==="

# 0. 기존 테스트 찌꺼기 싹 정리 (File exists 에러 방지)
sudo ip netns delete test-vm1 2>/dev/null || true
sudo ip netns delete test-vm2 2>/dev/null || true
sudo ip netns delete test-vm3 2>/dev/null || true
sudo ip link delete veth-vm1-br 2>/dev/null || true
sudo ip link delete veth-vm2-br 2>/dev/null || true
sudo ip link delete veth-vm3-br 2>/dev/null || true

# 1. 테스트용 임시 네트워크 네임스페이스 생성 (VM 역할을 대신함)
sudo ip netns add test-vm1
sudo ip netns add test-vm2
sudo ip netns add test-vm3

# 2. veth 인터페이스 생성 및 브릿지 연결
# vm1용 (vnet-A 연결)
sudo ip link add veth-vm1 type veth peer name veth-vm1-br
sudo ip link set veth-vm1 netns test-vm1
sudo ip link set veth-vm1-br master vnet-A
sudo ip link set veth-vm1-br up

# vm2용 (vnet-A 연결)
sudo ip link add veth-vm2 type veth peer name veth-vm2-br
sudo ip link set veth-vm2 netns test-vm2
sudo ip link set veth-vm2-br master vnet-A
sudo ip link set veth-vm2-br up

# vm3용 (vnet-B 연결)
sudo ip link add veth-vm3 type veth peer name veth-vm3-br
sudo ip link set veth-vm3 netns test-vm3
sudo ip link set veth-vm3-br master vnet-B
sudo ip link set veth-vm3-br up

# 3. 테스트용 가상 인터페이스에 과제 요구사항 IP 할당 [cite: 21-24]
sudo ip netns exec test-vm1 ip addr add 192.168.0.1/24 dev veth-vm1
sudo ip netns exec test-vm1 ip link set veth-vm1 up

sudo ip netns exec test-vm2 ip addr add 192.168.0.2/24 dev veth-vm2
sudo ip netns exec test-vm2 ip link set veth-vm2 up

sudo ip netns exec test-vm3 ip addr add 192.168.0.3/24 dev veth-vm3
sudo ip netns exec test-vm3 ip link set veth-vm3 up

# 브릿지 활성화 대기
sleep 3

# 4. 통신 기대 결과 테스트 수행 [cite: 37-43]
echo "------------------------------------------------"
echo "[테스트 1] vm-1 (192.168.0.1) -> vm-2 (192.168.0.2)"
echo "기대 결과: 통신 가능 (동일 vnet-A)"
if sudo ip netns exec test-vm1 ping -c 2 -W 1 192.168.0.2 > /dev/null 2>&1; then
    echo "✅ 결과: 성공 (통신 가능)"
else
    echo "❌ 결과: 실패"
fi

echo "------------------------------------------------"
echo "[테스트 2] vm-2 (192.168.0.2) -> vm-3 (192.168.0.3)"
echo "기대 결과: 통신 불가능 (vnet-A와 vnet-B 격리)"
if sudo ip netns exec test-vm2 ping -c 2 -W 1 192.168.0.3 > /dev/null 2>&1; then
    echo "❌ 결과: 실패 (통신이 됨 - 격리 실패)"
else
    echo "✅ 결과: 성공 (통신 불가능 - 격리 확인)"
fi

echo "------------------------------------------------"
echo "[테스트 3] vm-3 (192.168.0.3) -> vm-1 (192.168.0.1)"
echo "기대 결과: 통신 불가능 (vnet-B와 vnet-A 격리)"
if sudo ip netns exec test-vm3 ping -c 2 -W 1 192.168.0.1 > /dev/null 2>&1; then
    echo "❌ 결과: 실패 (통신이 됨 - 격리 실패)"
else
    echo "✅ 결과: 성공 (통신 불가능 - 격리 확인)"
fi
echo "------------------------------------------------"

# 5. 테스트용 임시 자원 삭제
sudo ip netns delete test-vm1
sudo ip netns delete test-vm2
sudo ip netns delete test-vm3
sudo ip link delete veth-vm1-br 2>/dev/null || true
sudo ip link delete veth-vm2-br 2>/dev/null || true
sudo ip link delete veth-vm3-br 2>/dev/null || true

echo "=== 통신 테스트 완료 ==="
