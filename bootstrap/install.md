## Preparation

Setup env variables:
```
PART1=/dev/sda1 (or /dev/nvme0n1p1)
PART2=/dev/sda2 (or /dev/nvme0n1p2)
PART3=/dev/sda3 (or /dev/nvme0n1p3)
```

This manual will acess these partitions as $PART# afterwards.

## Step 1 - Partitioning

Boot into a Mint or LMDE live environment and open GParted.

Choose a name for your root container. Since I use LMDE, in this instruction it will be lmde_root.

DELETE ALL THE PARTITIONS THAT CURRENTLY EXIST

Partition your /dev/sda drive as described below:

Disk label: GPT

$PART1:
    size: 512 MB
    filesystem: fat32
    flags: boot,esp

$PART2:
    size: 1024 MB (or 2048 MB if planning to use custom kernels, like xanmod)
    filesystem: ext4
    flags: none

$PART3:
    size: 10000 MB (to minimize reencrypt time)
    filesystem: btrfs
    flags: none

Save the partitioning and close GParted.

## Step 2 - Installation

Start installation wizard and go through it as normal. When it asks where to install the system, choose "Manual partitioning"

Edit the options of partitions you just created as follows:

$PART1:
    mount point: /boot/efi
    format: vfat

$PART2:
    mount point: /boot
    format: ext4

$PART3:
    mount point: /
    format: btrfs

Click Next and select to install GRUB on /dev/sda. Rest of the installation proceeds as normal.

## Step 3 - Encryption



At this point the installed correctly installed the system, GRUB and created two BTRFS subvolumes - @ for root and @home for home. This is standard practice, supported eg. by Timeshift for in-place snapshots.

We will be using cryptsetup's reencrypt command. First we need to make space for LUKS header. To do that we have to mount the @ subvolume and reduce its size by 32 MB. Open the terminal, go into sudo mode (sudo su) and do as follows:

```
mount $PART3 -o subvol=@ /mnt
btrfs filesystem resize -32m /mnt
umount /mnt
```

Next we will encrypt the partition. Choose strong and complicated password, that you will remember - this will be the password you have to type in every time your PC boots. It is recommended that the encryption password is different than user account password.

```
cryptsetup reencrypt --encrypt --type luks2 --reduce-device-size 32m $PART3
```

You will be first asked to type YES in capital letters to confirm, and then to type in your encryption password twice. The process will take some time, depending on your disk size (for 50 GB in a VM it takes about 2 minutes). The partition is now encrypted and closed.

After that, you should manually increase #PART3 luks partition to maximum using gparted.

## Step 4 - Final touches

Next step is to open the partition/LUKS container with the name you chose in the beginning. In this example it's lmde_root. You will be asked for the encryption password. Next we will mount all the partitions, so we can chroot into them. Pay close attention to the partitions/drives, mountpoints and the order of mounting, as this is crucial.

```
cryptsetup luksOpen $PART3 lmde_root
sudo mount --mkdir /dev/mapper/lmde_root -o subvol=@ /mnt
sudo mount --mkdir /dev/mapper/lmde_root -o subvol=@home /mnt/home
sudo mount --mkdir $PART2 /mnt/boot
sudo mount --mkdir $PART1 /mnt/boot/efi
sudo mount --mkdir --bind /dev /mnt/dev
sudo mount --mkdir --bind /sys /mnt/sys
sudo mount --mkdir --bind /proc /mnt/proc
chroot /mnt
```

Now we are inside our brand new system. Congrats, we only have a few more steps to go through. First of all, we need to re-extend the filesystem (remember, we shrunk it by 32 MB to fit LUKS header), then we will inform our system, that it has an encrypted partition (giving it the LUKS container name and its UUID, which is different than /dev/sda3 UUID) and should ask as for a password. We will give ourselves 3 tries, before it fails and panics. First we need to find the UUID of the LUKS container lmde_root and then put it in the /etc/crypttab file. The first command will output the UUID, which you then need to paste into the second command where {uuid} is.

```
btrfs filesystem resize max /
UUID=$(cryptsetup luksUUID $PART3)
echo "lmde_root UUID=$UUID none luks,discard,tries=3" >> /etc/crypttab
```

Next step is to inform GRUB about it, by giving it in turn the UUID of /dev/sda3 partition and again LUKS container name, and also informing it that the root partition is on the LUKS container.
```
cat << EOF > /etc/default/grub.d/99_fde.cfg
#! /bin/sh
set -e

GRUB_CMDLINE_LINUX="rd.luks.uuid=$UUID"
EOF
```

Also, you want to add compress option to `/etc/fstab`: add `defaults,compress=zstd,` options for your btrfs partitions before `subvol=@`.

Finally update grub and initramfs:

```
update-grub
update-initramfs -u
```

Exit chroot with CTRL+D or exit and unmount all the partitions, EXACTLY IN THIS ORDER. Then close LUKS container.

```
sudo umount /mnt/dev
sudo umount /mnt/proc
sudo umount /mnt/sys/firmware/efi/efivars
sudo umount /mnt/sys
sudo umount /mnt/home
sudo umount /mnt/boot/efi
sudo umount /mnt/boot
sudo umount /mnt

sudo cryptsetup close lmde_root
```

Done. Now reboot to your actually installed OS. If everything went right, you should see GRUB menu and after it a nice prompt for lmde_root (or whatever your LUKS contaienr is named) password with Mint logo.
