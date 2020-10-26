```
			recordings: {
				'get': { verb: 'GET', url: 'accounts/{accountId}/recordings/{recordingId}' },
				'delete': { verb: 'DELETE', url: 'accounts/{accountId}/recordings/{resourceId}' },
				'list': { verb: 'GET', url: 'accounts/{accountId}/recordings' }
```


recordings.list
```
  "data": [
        {
            "call_id": "3798468927@192_168_11_166",
            "callee_id_name": "",
            "callee_id_number": "132221",
            "caller_id_name": "Jesus Home",
            "caller_id_number": "1002",
            "cdr_id": "202004-3798468927@192_168_11_166",
            "content_type": "audio/mpeg",
            "custom_channel_vars": {
                "Account-ID": "b5b67b84fe43036b9cc7c9ee88a99776",
                "Account-Name": "RT-Test",
                "Account-Realm": "ccc506.s.some.local",
                "Application-Name": "callflow",
                "Application-Node": "kazoo_apps@kazoo1.pbx.local",
                "Authorizing-ID": "fd96a9f3b02560f80c6ba50b67c7dc59",
                "Authorizing-Type": "device",
                "Bridge-ID": "3798468927@192_168_11_166",
                "Call-Interaction-ID": "63753796101-cc99b372",
                "CallFlow-ID": "1cc848040a664f97b4c99fa4255b14bf",
                "Channel-Authorized": "true",
                "Ecallmgr-Node": "ecallmgr@kazoo1.pbx.local",
                "Fetch-ID": "49a2498e-7ba7-11ea-8f86-1de183757e2c",
                "Global-Resource": "false",
                "Media-Name": "e466ef950bf89951667c918f1b36765b.mp3",
                "Media-Names": "e466ef950bf89951667c918f1b36765b.mp3",
                "Media-Recorder": "kz_media_recording",
                "Media-Recording-ID": "202004-25b2a24e2111ac22265f739ac4ba73ff",
                "Media-Recordings": "202004-25b2a24e2111ac22265f739ac4ba73ff",
                "Owner-ID": "d481035afb48afa910d5a40ccbf73f10",
                "Privacy-Hide-Name": "false",
                "Privacy-Hide-Number": "false",
                "Realm": "ccc506.s.some.local",
                "Reseller-ID": "97ca6677470fb8d1fc67d86a144a5177",
                "Username": "user_xp5wmz979h"
            },
            "description": "recording e466ef950bf89951667c918f1b36765b.mp3",
            "direction": "inbound",
            "duration": 23,
            "duration_ms": 23960,
            "from": "1002@ccc506.s.some.local",
            "interaction_id": "63753796101-cc99b372",
            "media_source": "recorded",
            "media_type": "mp3",
            "name": "e466ef950bf89951667c918f1b36765b.mp3",
            "origin": "outbound to offnet from endpoint",
            "owner_id": "d481035afb48afa910d5a40ccbf73f10",
            "request": "132221@ccc506.s.some.local",
            "source_type": "kzc_recording",
            "start": 63753796103,
            "to": "132221@ccc506.s.some.local",
            "id": "202004-25b2a24e2111ac22265f739ac4ba73ff",
            "_read_only": {
                "content_types": [
                    "audio/mpeg"
                ]
            }
        },
```

recordings.get
```
v2/accounts/b5b67b84fe43036b9cc7c9ee88a99776/recordings/202004-e273fe992851793dc702367f56e6bce4

```



data:
[
  {
    "call_id": "4d7c2fe05e1603e3993295bc1730887c@10.83.53.38",
    "callee_id_name": "",
    "callee_id_number": "2121",
    "caller_id_name": "Jesus Tovar",
    "caller_id_number": "1001",
    "cdr_id": "202004-4d7c2fe05e1603e3993295bc1730887c@10.83.53.38",
    "content_type": "audio/mpeg",
    "custom_channel_vars": {
      "Account-ID": "b19465faefef394c2e0165df3b652969",
      "Account-Name": "RT-Test",
      "Account-Realm": "ccc506.s.some.local",
      "Application-Name": "callflow",
      "Application-Node": "kazoo_apps@kazoo1.pbx.local",
      "Authorizing-ID": "d657f2ea62d3561c8815ca93648cad41",
      "Authorizing-Type": "device",
      "Bridge-ID": "4d7c2fe05e1603e3993295bc1730887c@10.83.53.38",
      "Call-Interaction-ID": "63753545534-009c8474",
      "CallFlow-ID": "d2e1d9155b65bf329e0e629d2d2a4cd8",
      "Channel-Authorized": "true",
      "Ecallmgr-Node": "ecallmgr@kazoo1.pbx.local",
      "Fetch-ID": "e414527c-795f-11ea-abb9-1de183757e2c",
      "Global-Resource": "false",
      "Media-Name": "132fc78be6382d8d3d391bbf14bf0f38.mp3",
      "Media-Names": "132fc78be6382d8d3d391bbf14bf0f38.mp3",
      "Media-Recorder": "kz_media_recording",
      "Media-Recording-ID": "202004-c6b0605011a0309d03295fdac18705ec",
      "Media-Recordings": "202004-c6b0605011a0309d03295fdac18705ec",
      "Owner-ID": "3d7ceecd27c34ff80188dce467167b73",
      "Privacy-Hide-Name": "false",
      "Privacy-Hide-Number": "false",
      "Realm": "ccc506.s.some.local",
      "Username": "user_ek6s22qpdj"
    },
    "description": "recording 132fc78be6382d8d3d391bbf14bf0f38.mp3",
    "direction": "inbound",
    "duration": 14,
    "duration_ms": 14680,
    "from": "1001@ccc506.s.some.local",
    "interaction_id": "63753545534-009c8474",
    "media_source": "recorded",
    "media_type": "mp3",
    "name": "132fc78be6382d8d3d391bbf14bf0f38.mp3",
    "origin": "callflow : 2121",
    "owner_id": "3d7ceecd27c34ff80188dce467167b73",
    "request": "2121@ccc506.s.some.local",
    "source_type": "kzc_recording",
    "start": 63753545536,
    "to": "2121@ccc506.s.some.local:7000",
    "id": "202004-c6b0605011a0309d03295fdac18705ec",
    "_read_only": {
      "content_types": [
        "audio/mpeg"
      ]
    }
  }
]