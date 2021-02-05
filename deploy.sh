#!/bin/bash
clear
### SSH KEY PATH check
if [ ! -f pub_keys/id_rsa.pub ]; then
	echo "Public ssh keys file not fount!"
	echo "Create ./pub_keys/id_rsa.pub file, then paste your public ssh key file (id_rsa.pub)"
	echo "Script finished"
	exit
fi
# IMAGE PATH
IMG_PATH="imgs"
### Check if imgs path exist
if [ ! -d $IMG_PATH ] ; then
	mkdir -p IMG_PATH
fi
#URLS - Available compatible cloud-init images to download - Debina 9/10 and Ubuntu 18.04/20.04
DEBIAN_10_URL="https://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.raw"
DEBIAN_9_URL="https://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.raw"
UBUNTU_1804_URL="https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
UBUNTU_2004_URL="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"

echo "Available images are: "
echo -n "
1 - Debian 9 - Stretch
2 - Debian 10 - Buster
3 - Ubuntu 18.04 LTS - Bionic
4 - Ubuntu 20.04 LTS - Focal
"
echo -n "Choose a Image template to install: "
read OPT_IMAGE_TEMPLATE

case $OPT_IMAGE_TEMPLATE in
	1)
		TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${DEBIAN_9_URL##*/}"
		if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
			wget -c $DEBIAN_9_URL -O $TEMPLATE_VM_CI_IMAGE
		fi
		;;
	2)
		TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${DEBIAN_10_URL##*/}"
		if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
			wget -c $DEBIAN_10_URL -O $TEMPLATE_VM_CI_IMAGE
		fi
		;;
	3)
		TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${UBUNTU_1804_URL##*/}"
		if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
			wget -c $UBUNTU_1804_URL -O $TEMPLATE_VM_CI_IMAGE
		fi
		;;
	4)
		TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${UBUNTU_2004_URL##*/}"
		if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
			wget -c $UBUNTU_2004_URL -O $TEMPLATE_VM_CI_IMAGE
		fi
		;;
	*)
		clear
		echo "[Fail] - Unknown option - Run script again then choose a valid option."
		exit
		;;
esac
clear
echo "########## VM DETAILS ##########"

echo -n "Type VM Name: "
read TEMPLATE_VM_NAME
echo -n "Type VM Description: "
read TEMPLATE_VM_DESCRIPTION
echo -n "Memory Options:
a - 1GB
b - 2GB
c - 4GB
d - 8GB
e - 16GB
Select VM Memory option (a-e): "
read TEMPLATE_VM_MEMORY_GB

case $TEMPLATE_VM_MEMORY_GB in
	a)
	TEMPLATE_VM_MEMORY=1024
	;;
	b)
		TEMPLATE_VM_MEMORY=2048
	;;
	c)
		TEMPLATE_VM_MEMORY=4096
	;;
	d)
		TEMPLATE_VM_MEMORY=8192
	;;
	e)
		TEMPLATE_VM_MEMORY=16384
	;;
        *)
                clear
                echo "[Fail] - Unknown option - Run script again then choose a valid option."
                exit
                ;;
esac
### VM Cores
echo -n "Type # of VM CPU Cores: (Example: 2)"
read TEMPLATE_VM_CORES
### VM Sockets
echo -n "Type # of VM CPU Sockets: (Example: 1)"
read TEMPLATE_VM_SOCKETS

### VM Storage
clear
echo "########## NETWORK ##########"
echo ""
echo Storage Availability|awk '{ printf "%-20s %-40s\n", $1, $2 }'
pvesm status|grep active|awk '{ printf "%-20s %-40s\n", $1, $7 }'
echo -n "Type name of Storage to install VM: "
read TEMPLATE_VM_STORAGE

### VM Default user
clear
echo "######### USER INFORMATION ##########"
echo "Script create user root as default. If you would like to change it and use sudo, please"
echo -n "type new username: "
read TEMPLATE_DEFAULT_USER
#### Network
clear
echo "########## NETWORK ##########"
### Bridge
echo "Choose a Bridge interface to attach VM, options are:"
brctl show|grep vmbr|awk '{print "Bridge " $1}'|sort|uniq
echo -n "Type brigde name: (Example vmbr0) "
read TEMPLATE_VM_BRIDGE
### VM IP
echo -n "Type VM IP Address and Network Mask bit. (Example: 192.168.0.101/24): "
read TEMPLATE_VM_IP
### VM GW
echo -n "Type Network Gateway IP Address. (Example: 192.168.0.1): "
read TEMPLATE_VM_GW
echo "Choose a UNIQ ID for VM, please, do not use any of bellow IDs"
pvesh get /cluster/resources --type vm|grep qemu|awk '{ print $2}'|cut -d"/" -f2
echo -n "Type a uniq ID for VM: "
read TEMPLATE_VM_ID

clear
echo ""
echo "######### VM DETAILS ##########"
echo ""
echo Name: $TEMPLATE_VM_NAME 
echo Description $TEMPLATE_VM_DESCRIPTION 
echo Memory:  $TEMPLATE_VM_MEMORY 
echo Cores: $TEMPLATE_VM_CORES
echo Sockets: $TEMPLATE_VM_SOCKETS
echo Template Image: $TEMPLATE_VM_CI_IMAGE
echo Storage: $TEMPLATE_VM_STORAGE
echo User: $TEMPLATE_DEFAULT_USER
echo Attached Bridge: $TEMPLATE_VM_BRIDGE
echo IP Address/Network: $TEMPLATE_VM_IP
echo Gateway $TEMPLATE_VM_GW
echo VM ID: $TEMPLATE_VM_ID

echo -n "Review informantions and type Y to continue: "
read OPT_CONTINUE
if [ $OPT_CONTINUE != "Y" ] ; then
	echo "Script finished"
	exit
fi
#### Start deploy
echo ""
echo "##########  Start  VM  Deploy  ##########"
echo
#### Check if vm id exist
qm status $TEMPLATE_VM_ID > /dev/null 2>&1
if [ $? -eq 0 ] ; then
	echo "[FAIL] - unable to create VM $TEMPLATE_VM_ID - VM $TEMPLATE_VM_ID already exists - Try another id"
	exit
fi
#### Function to check errors
check_errors() {
	if [ $? -ne 0 ] ; then
		echo "[FAIL] - $ACTION"
		exit
	else
		echo "[OK] - $ACTION"
	fi
}

### DO NOT TOUCH
ACTION="Create VM Template $TEMPLATE_VM_ID:$TEMPLATE_VM_NAME"
qm create $TEMPLATE_VM_ID \
	--name $TEMPLATE_VM_NAME \
	--memory $TEMPLATE_VM_MEMORY \
	--net0 virtio,bridge=$TEMPLATE_VM_BRIDGE \
	--cores $TEMPLATE_VM_CORES \
	--sockets $TEMPLATE_VM_SOCKETS \
	--cpu cputype=kvm64 \
	--kvm 1 \
	--numa 1 > /dev/null 2>&1
check_errors

ACTION="Import disk"
qm importdisk $TEMPLATE_VM_ID $TEMPLATE_VM_CI_IMAGE $TEMPLATE_VM_STORAGE > /dev/null 2>&1
check_errors

ACTION="Set disk controller and image"
qm set $TEMPLATE_VM_ID --scsihw virtio-scsi-pci --scsi0 $TEMPLATE_VM_STORAGE:$TEMPLATE_VM_ID/vm-$TEMPLATE_VM_ID-disk-0.raw > /dev/null 2>&1
check_errors

ACTION="Set serial socket"
qm set $TEMPLATE_VM_ID --serial0 socket > /dev/null 2>&1
check_errors

ACTION="Set boot disk"
qm set $TEMPLATE_VM_ID --boot c --bootdisk virtio0 > /dev/null 2>&1
check_errors

ACTION="Set Qemu Guest Agent Enabled"
qm set $TEMPLATE_VM_ID --agent 1 > /dev/null 2>&1
check_errors

ACTION="Set hotplug options"
qm set $TEMPLATE_VM_ID --hotplug disk,network,usb,memory,cpu > /dev/null 2>&1
check_errors

ACTION="Set vga display"
qm set $TEMPLATE_VM_ID --vga qxl > /dev/null 2>&1
check_errors

ACTION="Set machine type"
qm set $TEMPLATE_VM_ID --machine q35 > /dev/null 2>&1
check_errors

ACTION="Set name to $TEMPLATE_VM_NAME"
qm set $TEMPLATE_VM_ID --name $TEMPLATE_VM_NAME > /dev/null 2>&1
check_errors

ACTION="Set default user to $TEMPLATE_DEFAULT_USER"
qm set $TEMPLATE_VM_ID --ciuser $TEMPLATE_DEFAULT_USER > /dev/null 2>&1
check_errors

ACTION="Set image size to 20GB"
qm resize $TEMPLATE_VM_ID scsi0 +17748M > /dev/null 2>&1
check_errors

#Cloud INIT
ACTION="Add cloud-init cdrom"
qm set $TEMPLATE_VM_ID --ide2 local:cloudinit > /dev/null 2>&1
check_errors

ACTION="Set authorized ssh keys"
qm set $TEMPLATE_VM_ID --sshkey /root/cloud-init/pub_keys/id_rsa.pub > /dev/null 2>&1
check_errors

ACTION="Set IP Address and Gateway"
qm set $TEMPLATE_VM_ID --ipconfig0 ip=$TEMPLATE_VM_IP,gw=$TEMPLATE_VM_GW > /dev/null 2>&1
check_errors
