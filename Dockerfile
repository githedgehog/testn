FROM ghcr.io/githedgehog/testin/n-vm:latest

RUN setcap cap_net_admin,cap_net_raw+eip $(readlink -f /bin/cloud-hypervisor)
