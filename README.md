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

1. Clone the repo

   ```bash
   git clone https://github.com/githedgehog/testn
   cd testn
   ```

2. Allocate some 2MiB hugepages:

   If you don't already have some hugepages available, you can allocate 512 of them with the following command:

   ```bash
   echo 512 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
   ```

   This will last until you reboot (or explicitly deallocate them).

3. Pull the current docker image:

   ```bash
   docker pull ghcr.io/githedgehog/testn/n-vm:0.0.4
   ```

4. Change into the repo directory and run the scratch test

   ```bash
   cargo test --package=scratch
   ```

If all goes well you should see two tests pass and two tests fail.
The tests which fail exist to illustrate the type of output we get from a failed in-vm and non in-vm test.
