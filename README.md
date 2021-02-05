# Proxmox cloud-init tools
Shellscipt tools to manage VM cloud-init in Proxmox Virtual Environment (PVE)

### Supported PVE Versions
1. 6.1
2. 6.2
3. 6.3

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
9. Select bridge network;
10. Select Static/IP or DHCP usage;
11. Define uniq VMID;
12. Can start or not, VM after deployment.
 
