# EMMC Backup Procedure

This procedure is recommended to be performed when your printer is completely setup in a well working condition. It is possible to create complete eMMC backup ( 15 minutes / 8GB) or just a backup of the system partitions ( 2 minutes / 600MB ). It is recommended to have at least one complete backup and one or two system backups at different firmware versions. The procedure uses the uboot functionality to read/write the eMMC and to read/write USB disks. The backup procedure copy the entire eMMC (or just the system partitions) on a USB disk. Then on a Linux host you can create image of the USB disk to have it as a backup file.

To perform a backup follow these steps:

1. Use the original app version 2.39 and stop the booting process by holding key 's' (or use any custom firmware update that has the UART enabled)
2. Insert a USB disk (FAT32 formated) with the file [backup.scr](../extra-stuff/emmc/backup.scr) on it for complete emmc backup. If you need to backup just the system partitions use the file [sbackup.scr](../extra-stuff/emmc/sbackup.scr) instead.
3. From the uboot shell enter the following:

```sh
usb reset
```

```sh
usb dev 0
```

```sh
fatload usb 0:0 42000000 backup.scr
```

If you see an error, try typing in usb part and see what partitions are available. Then enter:

```sh
fatload usb 0:<Enter partition number in here> 42000000 backup.scr
```

Example:

```sh
fatload usb 0:1 42000000 backup.scr
```

(Partition 1)

For a system backup replace the above script name `backup.scr` with the name `sbackup.scr`.

4. Remove the USB disk with the scripts and insert at least 8GB USB disk for a complete backup (or at least 1GB USB disk for a system backup). It can be formated or not and it will be completely rewritten by the contents of the eMMC. NOTE: Do not use a disk with important information! All data on it will be lost!

5. Type the following to execute the script:

```sh
source 42000000
```

6. Wait about 15 minutes (or about 2 minutes for a system backup) and the entire emmc (or the system part of it) will be transfered 1:1 to the USB disk
   If you see an error and the script stopped before showing 100%, insert another type USB disk and enter again:

```sh
source 42000000
```

7. From a linux machine export the complete backup as a file from the USB disk:

```sh
dd if=/dev/sdh of=emmc_backup.bin bs=512 count=15269888 status=progress
```

or the system backup:

```sh
dd if=/dev/sdh of=emmc_system_backup.bin bs=512 count=1135648 status=progress
```

Note: replace the `/dev/sdh` with the device name of your USB disk.

---

With the xfel tool

This mode can be used when the version you are using has the uart disabled and you are unable to stop the booting process and to enter in the uboot shell.

You could either do:

```sh
xfel exec 0x0
```

to boot into uboot and then enter the commands above or:

1. Enter the printer in FEL mode and connect the uart to the computer. Open the terminal.
2. Enter the following:

```sh
xfel ddr t113-s3
```

```sh
xfel write 0x43000000 uboot239.bin
```

```sh
xfel exec 0x43000b50
```

Immediately press and hold key 's' in the terminal until the boot process stop in uboot shell and go to step 3 above

You can modify the script and create new backup.scr image by:

```sh
mkimage -T script -n 'EMMC Backup' -d backup.txt backup.scr
```

or for the system backup:

```sh
mkimage -T script -n 'EMMC System Backup' -d sbackup.txt sbackup.scr
```
