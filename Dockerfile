FROM ghcr.io/githedgehog/testn/n-vm:latest

RUN setcap cap_net_admin+ep $(readlink -f /bin/cloud-hypervisor)
