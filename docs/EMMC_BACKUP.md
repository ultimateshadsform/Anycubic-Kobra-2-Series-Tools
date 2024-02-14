# EMMC Backup Procedure

1. Use the original app version 2.39 and stop the booting process by holding key 's' (or use any custom firmware update that has the UART enabled)
2. Insert USB disk with the file [backup.scr](../extra-stuff/emmc/backup.scr) on it for complete emmc backup. If you need to backup just the system partitions use the file [sbackup.scr](../extra-stuff/emmc/sbackup.scr) instead.
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

source 42000000

4. Remove the USB disk and insert at least 8GB USB disk for a complete backup (or at least 1GB USB disk for a system backup)
5. Wait about 15 minutes (or about 2 minutes for a system backup) and the entire emmc (or the system part of it) will be transfered 1:1 to the USB disk
   If you see an error and the script stopped before showing 100%, insert another type USB disk and enter:

```sh
source 42000000
```

6. From a linux machine export the complete backup as a file:

```sh
dd if=/dev/sdh of=emmc_backup.bin bs=512 count=15269888 status=progress
```

or the system backup:

```sh
dd if=/dev/sdh of=emmc_system_backup.bin bs=512 count=1135648 status=progress
```

---

With the xfel tool:

You could either do:

```sh
xfel exec 0x0
```

to boot into uboot and then enter the commands above or:

1. Enter the printer in FEL mode
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

Press and hold key 's' until the boot process stop in uboot shell and go to step 3 above

You can modify the script and create new backup.scr image by:

```sh
mkimage -T script -n 'EMMC Backup' -d backup.txt backup.scr
```

or for the system backup:

```sh
mkimage -T script -n 'EMMC System Backup' -d sbackup.txt sbackup.scr
```
