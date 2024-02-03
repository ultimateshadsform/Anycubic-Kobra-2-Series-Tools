## Anycubic Kobra 2 Series Tools

This repository contains tools for the Anycubic Kobra 2 Series 3D printers.

### Usage

1. Clone the repository.
2. Place `.bin` firmware files in the `FW` directory.
3. Run `unpack.sh` to unpack the firmware files.
4. Modify the firmware files as needed and run `patch.sh` to patch the firmware files.
5. Run `pack.sh` to pack the firmware files.
6. Replace the `swupdate_public.pem` in the printer with the one in the `RESOURCES` directory or create your own.
7. Upload the firmware files to the printer as usual. Can be found in the `update` directory.

Default password for the firmware is `toor` but it can be changed in the `shadow` file.

OPKG is included.

### Notes

This repository is a work in progress and may contain bugs or may not work as expected any pull requests are welcome.

### Information

Default password for the firmware is `toor` but it can be changed in the `shadow` file.

**FW** - Place `.bin` firmware files here.

**RESOURCES** - Contains resources for the firmware files.

**TOOLS** - Contains tools to decrypt and encrypt firmware files and more.

**unpacked** - Contains the unpacked firmware files.

**update** - Contains the packed firmware files.

<details>
<summary>Old info</summary>
</br>
Right now, there is no klipper custom firmware but we have discovered that we can create our own modified firmware by patching things in the rootfs.

This is not a custom firmware created via the SDK. So it is not a custom firmware in the traditional sense.

We have managed to create our own .swu update file which we can flash via USB. But in order to do this, we need to patch and replace the public key in the printer to accept our custom firmware. Which requires root access/uart access.

But I have some links which the community has shared that may get us closer to custom firmware:

~~https://gitlab.com/weidongshan/tina-d1-h~~

~~https://bbs.aw-ol.com/topic/1034~~

~~We have found the sdk here: https://d1.docs.aw-ol.com/study/study_3getsdktoc/#sdk_3~~

~~Here is a more recent version of the SDK which you can download: https://klipper.discourse.group/t/printer-cfg-for-anycubic-kobra-2-plus-pro-max/11658/95?u=ultimatelifeform~~

https://bbs.aw-ol.com/assets/uploads/files/1645007527374-r528_user_manual_v1.3.pdf

If you have a male to male usb port connected you can probably use https://androidmtk.com/download-phoenixsuit to flash?

https://gitee.com/weidongshan/eLinuxCore_100ask-t113-pro

```bash
git clone https://gitee.com/weidongshan/eLinuxCore_100ask-t113-pro --recurse-submodules
```

You can find the devboard documentation here: https://shadow-storage.fra1.cdn.digitaloceanspaces.com/GXFB0461-001.zip

It was sent via Telegram but I uploaded it to my server for safe keeping.

</details>

### Credits

Original credits to [Assen](https://klipper.discourse.group/u/AGG2020) for the scripts.

[Alexander](https://github.com/ultimateshadsform) for minor modifications.

And to the community for the support and reverse engineering.
