# MQTT

## About

MQTT is a machine-to-machine (M2M)/"Internet of Things" connectivity protocol. It was designed as an extremely lightweight publish/subscribe messaging transport. It is useful for connections with remote locations where a small code footprint is required and/or network bandwidth is at a premium.

## MQTT API

To be able to send MQTT commands to the device, you need to connect and use the following topic:
(All commands will need to be sent here)

```
anycubic/anycubicCloud/v1/server/printer/<PRINTER_MODEL_ID>/<PRINTER_ID>/response
```

You can find the printer id by taking the first 32 characters of the file:

```
/user/ac_mqtt_connect_info
```

The `<PRINTER_MODEL_ID>` can be `20021` for K2Pro, `20022` for K2Plus or `20023` for K2Max.

Then to see received responses from the printer, you need to subscribe to the following topic:

```
anycubic/anycubicCloud/v1/printer/public/#
```

### Commands

#### List internal files

```json
{
  "type": "file",
  "action": "listLocal",
  "data": {
    "path": "/"
  }
}
```

#### List files on USB

```json
{
  "type": "file",
  "action": "listUdisk",
  "data": {
    "path": "/"
  }
}
```

#### Delete internal file

```json
{
  "type": "file",
  "action": "deleteLocal",
  "data": {
    "path": "dir",
    "filename": "filename"
  }
}
```

#### Delete file on USB

```json
{
  "type": "file",
  "action": "deleteUdisk",
  "data": {
    "path": "dir",
    "filename": "filename"
  }
}
```

#### cloudRecommendList

Need more info on what this does

```json
{
  "type": "cloudRecommendList",
  "records" {
    "md5": "md5",
    "url": "url",
    "size": "size",
    "img_url": "img_url",
    "est_time": "est_time",
  }
}
```

#### Get printer status

```json
{
  "type": "status",
  "action": "query"
}
```

#### Video

```json
{
  "type": "video",
  "action": "startCapture",
  "data": {
    "region": "region",
    "tmpSecretKey": "tmpSecret",
    "tmpSecretId": "tmpSecretId",
    "sessionToken": "sessionToken"
  }
}
```

#### Get slice params

```json
{
  "type": "print",
  "action": "getSliceParam"
}
```

#### Get printer status

```json
{
  "type": "print",
  "action": "query"
}
```

#### localtasktrans

```json
{
  "type": "print",
  "action": "localtasktrans",
  "data": {
    "taskid": "<taskid>",
    "localtask": "<localtask>"
  }
}
```

#### Start print

```json
{
  "type": "print",
  "action": "start",
  "data": {
    "taskid": "<taskid>",
    "url": "<url>",
    "filename": "<filename>",
    "filesize": "<filesize>",
    "md5": "<md5>",
    "filetype": "<filetype>",
    "filepath": "<filepath>",
    "project_type": "<project_type>"
  }
}
```

#### Pause print

```json
{
  "type": "print",
  "action": "pause",
  "data": {
    "taskid": "<taskid>"
  }
}
```

#### Resume print

```json
{
  "type": "print",
  "action": "resume",
  "data": {
    "taskid": "<taskid>"
  }
}
```

#### Stop print

```json
{
  "type": "print",
  "action": "stop",
  "data": {
    "taskid": "<taskid>"
  }
}
```

#### Update print

```json
{
  "type": "print",
  "action": "update",
  "data": {
    "taskid": "<taskid>",
    "settings": {
      "target_nozzle_temp": "<target_nozzle_temp>",
      "target_hotbed_temp": "<target_hotbed_temp>",
      "fan_speed_pct": "<fan_speed_pct>",
      "print_speed_mode": "<print_speed_mode>",
      "z_comp": "<z_comp>"
    }
  }
}
```

#### Cancel print

```json
{
  "type": "print",
  "action": "cancel",
  "data": {
    "taskid": "<taskid>"
  }
}
```

#### Get ota version

```json
{
  "type": "ota",
  "action": "reportVersion",
  "data": {
    "force_update": "force_update",
    "firmware_md5": "firmware_md5",
    "firmware_version": "firmware_version",
    "firmware_name": "firmware_name",
    "firmware_url": "firmware_url",
    "firmware_size": "firmware_size"
  }
}
```

#### Update ota version

```json
{
  "type": "ota",
  "action": "update",
  "data": {
    "force_update": "force_update",
    "firmware_md5": "firmware_md5",
    "firmware_version": "firmware_version",
    "firmware_name": "firmware_name",
    "firmware_url": "firmware_url",
    "firmware_size": "firmware_size"
  }
}
```
