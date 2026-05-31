# ☁️ Mini IaaS Environment Builder

Ubuntu 24.04 환경에서 KVM, MicroCeph, Linux Network Namespace를 활용하여 Compute, Network, Storage가 완벽히 격리 및 연동되는 미니 클라우드(IaaS) 환경을 자동 구축하는 쉘 스크립트 프로젝트입니다.

## 📌 Architecture Overview
* **Compute**: QEMU/KVM 기반 VM 3대 구동 및 Cloud-init을 통한 정적 IP 자동 할당
* **Storage**: MicroCeph 단일 클러스터 구성 및 RBD(RADOS Block Device) 커널 매핑 부팅 지원 (로컬 qcow2 파일 지양)
* **Network**: Linux Bridge 및 Network Namespace를 활용한 완벽한 L2 세그먼트 격리 구현 (vnet-A, vnet-B)

## 🚀 How to Use
스크립트를 순서대로 실행하여 인프라를 프로비저닝하고 통신 격리를 검증합니다.
1. `sh 00_prereq.sh` - 필수 패키지 설치
2. `sh 01_microceph.sh` - Ceph 클러스터 구성 및 VM 디스크(RBD) 생성
3. `sh 02_network.sh` - L2 브릿지 분리 네트워크 구성
4. `sh 03_vm.sh` - Cloud-init 설정 주입 및 KVM 가상머신 실행
5. `sh 04_test.sh` - Network Namespace를 활용한 통신 격리 핑(Ping) 테스트 자동화
* `sh cleanup.sh` - 멱등성 보장을 위한 생성 자원 완벽 롤백

## 📄 Detailed Report
상세한 아키텍처 다이어그램과 트러블슈팅 및 테스트 결과는 [architecture_report.pdf](./architecture_report.pdf)에서 확인할 수 있습니다.