# Test'n

## preview instructions

## System requirements

1. A reasonably recent linux machine on x86_64.
2. rust / cargo
3. hugepages
4. docker
5. a user in the docker group which you can use to run tests
6. the ability to launch virtual machines (you very likely have this by default)

## Steps

1. Allocate some 1GiB hugepages:

   If you don't already have some hugepages available, you can allocate 4 with the following command:

   ```bash
   echo 4 | sudo tee /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
   ```

   This will last until you reboot (or explicitly deallocate them).

2. Pull the current docker image:

   ```bash
   docker pull ghcr.io/githedgehog/testn/n-vm:0.0.3
   ```

3. Clone the repo

   ```bash
   git clone https://github.com/githedgehog/testn
   ```

4. Change into the repo directory and run the scratch test

   ```bash
   cd testn
   cargo test --package=scratch
   ```
