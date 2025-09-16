FROM ghcr.io/githedgehog/testin/n-vm:latest

RUN setcap cap_net_admin+ep $(readlink -f /bin/cloud-hypervisor)
