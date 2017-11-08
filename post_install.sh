# !/bin/bash

# Assume Centos7

curl -O https://raw.githubusercontent.com/dlux/InstallScripts/master/common_functions

source ./common_functions

EnsureRoot

echo "PREPARING NODE AS HEAD NODE"

yum -y update
yum -y install vim redhat-lsb-core kernel-devel
yum -y groupinstall "Development Tools"

# Install ohpc
echo "INSTALLING OHPC"
yum -y install https://github.com/openhpc/ohpc/releases/download/v1.2.GA/ohpc-release-centos7.2-1.2-1.x86_64.rpm

echo "INSTALLING OHPC-WAREWULF"
yum -y groupinstall ohpc-base
yum -y groupinstall ohpc-warewulf
# Disable the firewall
systemctl disable firewalld
systemctl stop firewalld

# Create warewulf chroot - like a venv chained to a folder tree
echo "CREATING WAREWULF CHROOT"
pushd /usr/libexec/warewulf/wwmkchroot/
sed -i "s/YUM_MIRROR/#YUM_MIRROR/g" centos-7.tmpl
sed -i "s/# #YUM_MIRROR/YUM_MIRROR/g" centos-7.tmpl
CHROOT=/opt/ohpc/admin/images/centos7.2
wwmkchroot centos-7 $CHROOT
# Enable DNS resolution
cp -p /etc/resolv.conf $CHROOT/etc/resolv.conf
# Update CentOS
chroot $CHROOT /bin/bash -c "yum clean all"
chroot $CHROOT /bin/bash -c "yum -y update"
popd

echo 'ADD CLUSTER SSH-KEYS'
wwinit ssh_keys
cat ~/.ssh/cluster.pub >> $CHROOT/root/.ssh/authorized_keys

echo 'SETUP NFS FOR THE CLUSTER'
echo "192.168.0.10:/home /home nfs nfsvers=3,rsize=1024,wsize=1024, cto 0 0" >> $CHROOT/etc/fstab
echo "192.168.0.10:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3 0 0" >> $CHROOT/etc/fstab
echo "/home *(rw,no_subtree_check,fsid=10,no_root_squash)" >> /etc/exports
echo "/opt/ohpc/pub *(rw,no_subtree_check,fsid=11)" >> /etc/exports
exportfs -a
systemctl enable nfs-server
systemctl restart nfs

echo 'MARIADB - SEE /etc/warewulf/database-root.conf'
systemctl restart mariadb

echo 'SETTING UP BOOTSTRAP'
# Image preparation
chroot $CHROOT /bin/bash -c "yum -y install kernel"
pushd $CHROOT
wwbootstrap `uname -r`
popd
# TFTP server preparation
sed -i "s/#tftpdir/tftpdir/g" /etc/warewulf/provision.conf
perl -pi -e "s/^\s+disable\s+= yes/ disable = no/" /etc/xinetd.d/tftp
# VNFS Preparation - Image to be provisioned into compute nodes
echo 'SEE /etc/warewulf/vnfs/*.conf'
wwvnfs -y --chroot=$CHROOT

echo 'SETTING UP PROVISIONING SERVICES'
# HTTP for provisioning
MODFILE=/etc/httpd/conf.d/warewulf-httpd.conf
perl -pi -e "s/cgi-bin>\$/cgi-bin>\n Require all granted/" $MODFILE
perl -pi -e "s/Allow from all/Require all granted/" $MODFILE
perl -ni -e "print unless /^\s+Order allow,deny/" $MODFILE
wwsh file import /etc/passwd
wwsh file print passwd
wwsh file list

echo 'REGISTER COMPUTE NODE1 FOR PROVISIONING'
perl -pi -e "s/device = eth1/device = enp0s8/" /etc/warewulf/provision.conf
wwsh -y node new node01 --netdev=eth0 --hwaddr=08:00:27:7C:F2:70
wwsh -y node set node01 --netdev=eth0 --ip=192.168.0.22 \
                        --netmask=255.255.255.0 \
                        --gateway=192.168.0.10
wwsh -y provision set node01 --bootstrap=`uname -r`
wwsh -y provision set node01 --vnfs=$(echo $CHROOT | sed 's!.*/!!')
wwsh -y provision set node01 --fileadd passwd
wwsh provision print node01
wwsh dhcp update
systemctl restart dhcpd
systemctl restart mariadb
systemctl restart xinetd
systemctl restart mariadb
systemctl enable mariadb
systemctl enable httpd
systemctl restart httpd
wwsh pxe update


