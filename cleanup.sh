#!/bin/bash
echo "=== 자원 정리(Cleanup) 시작 ==="

# 1. 실행 중인 QEMU 가상머신 프로세스 강제 종료
echo "-> 실행 중인 VM 종료 중..."
sudo pkill -f qemu-system-x86_64

# 프로세스가 완전히 죽을 때까지 잠시 대기
sleep 2 

# 2. 커널에 매핑된 Ceph RBD 블록 디바이스 해제
echo "-> RBD 매핑 해제 중..."
for i in 1 2 3; do
    if rbd showmapped | grep -q "vm$i-image"; then
        sudo rbd unmap /dev/rbd/vmpool/vm$i-image
    fi
done

# 3. Ceph 내 RBD 이미지 삭제
echo "-> Ceph RBD 이미지 삭제 중..."
for i in 1 2 3; do
    sudo rbd rm vmpool/vm$i-image 2>/dev/null || true
done

# (선택) 풀(Pool)까지 완전히 날리고 싶다면 아래 주석 해제 (단, pool 삭제는 Ceph 설정에 따라 막혀있을 수 있음)
# sudo ceph osd pool rm vmpool vmpool --yes-i-really-really-mean-it

# 4. 가상 네트워크(VNet) 브릿지 삭제
echo "-> 가상 네트워크 (vnet-A, vnet-B) 삭제 중..."
sudo ip link set vnet-A down 2>/dev/null || true
sudo ip link delete vnet-A type bridge 2>/dev/null || true

sudo ip link set vnet-B down 2>/dev/null || true
sudo ip link delete vnet-B type bridge 2>/dev/null || true

# 5. QEMU 브릿지 설정 파일 초기화
sudo rm -f /etc/qemu/bridge.conf

echo "-> Cloud-init Seed ISO 삭제 중..."
sudo rm -f seed*.iso

echo "-> 테스트용 네트워크 네임스페이스 삭제 중..."
sudo ip netns delete test-vm1 2>/dev/null || true
sudo ip netns delete test-vm2 2>/dev/null || true
sudo ip netns delete test-vm3 2>/dev/null || true

echo "=== 모든 자원 정리 완료 ==="
