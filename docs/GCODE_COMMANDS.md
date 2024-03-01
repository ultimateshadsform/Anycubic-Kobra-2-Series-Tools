# Hidden Gcode commands

To run these custom gcode commands you need to pass

```gcode
ROOT
; gcode commands in here
UNROOT
```

The `root` command enabled these commands. And `unroot` disables them.

- ROOT - Enable root commands.
- M8802 - Reboots the printer.
- M8803 - Copy printer.cfg to USB.
- M8807 - Copy printer.cfg from USB.
- M8810 - Copy encrypted logs to USB.
- M8817 - Copy printer.cfg from USB to /app/resources/configs/printer.cfg.
- M8818 - Copy unmodifiable.cfg from USB.
- M8820 - Resets the printer to factory settings.
