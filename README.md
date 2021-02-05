# Proxmox cloud-init tools
Shellscipt tools to manage VM cloud-init in Proxmox Virtual Environment (PVE)

### Supported PVE Versions
PVE 6 *Not tested*

PVE 6.1 **[OK] - Tested**

PVE 6.2 **[OK] - Tested**

PVE 6.3 **[OK] - Tested**

### Features
1. Auto cloud images download
1.1 Debian 9 - Stretch
1.2 Debian 10 - Buster
1.3 Ubuntu Server 18.04 LTS - Bionic
1.4 Ubuntu Server 20.04 LTS - Focal
2. Set VM Hostname
3. Set VM Description
4. Memory (Available choose 2GB,4GB,8GB and 16GB)
5. CPU Cores
6. CPU Sockets
7. Storage path (Local, NFS, LVM/LVM-Thin, etc)
8. Define user, by default root user is defined. If you change to another, this user can be used with sudo powers without password;
9. Insert SSH authorized keys to user defined on step 8 **Very important**;
10. Select bridge network;
11. Select Static/IP or DHCP usage;
12. Define uniq VMID;
13. Can start or not, VM after deployment.

### Usage
1. Login on your Proxmox VE server
2. Clone proxmox-cloud-init project
> git clone https://github.com/kmee/proxmox-cloud-init-tools.git

> cd proxmox-cloud-init-tools
3. Create authorized keys files
> mkdir pub_keys

> touch pub_keys/id_rsa.pub

> copy your public ssh keys to pub/keys/id_rsa.pub file
4. Adjust permission, then run deploy.sh
> chmod +x deploy.sh

> ./deploy.sh
5. Follow instructions on screen.

### Important
Before deploy you VM using things script, upload your public ssh key to ./pub_keys/id_rsa.pub file.
if you do not upload keys do pub_keys/id_rsa.pub, you will not access VM.
