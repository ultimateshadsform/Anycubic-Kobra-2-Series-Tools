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

### Credits

Original credits to [Assen](https://klipper.discourse.group/u/AGG2020) for the scripts.

[Alexander](https://github.com/ultimateshadsform) for minor modifications.
