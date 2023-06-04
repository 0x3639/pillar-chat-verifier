# Pillar Chat Verifier
A service that manages Pillar owner access to a private chat on a [Rocket Chat](https://www.rocket.chat) server.

The service uses a websocket connection to a Zenon node to validate Pillar ownership status in real-time.

## Building from source
The Dart SDK is required to build the server from source (https://dart.dev/get-dart). Use the Dart SDK to install the dependencies and compile the program by running the following commands:
```
dart pub get
mkdir build
dart compile exe bin/main.dart -o build/pillar-chat-verifier
cp example.config.yaml build/config.yaml
```

## Running as a system service (Linux)
It is advisable to run the service as a system service that automatically restarts the service if it experiences an unexpected crash.

Example systemd service configuration:

```
sudo nano /etc/systemd/system/pillar-chat-verifier.service
```

```
[Unit]
Description=Pillar Chat Verifier
Wants=network-online.target
After=network-online.target

[Service]
Restart=on-failure
RestartSec=5
ExecStart=/home/$USER/pillar-chat-verifier/build/pillar-chat-verifier
ExecStop=/usr/bin/pkill -9 pillar-chat-verifier
TimeoutStopSec=10s
TimeoutStartSec=10s
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=pillar-chat-verifier

[Install]
WantedBy=multi-user.target
```

# Rocket Chat setup

Make a copy of the `example.config.yaml` file and rename it as `config.yaml`. This is the configuration file for the Rocket Chat Pillar Verifier. This file must be located in the same folder as the Rocket Chat Pillar Verifier binary.

### Create a private channel
A private channel has to be set up on Rocket Chat. The channel's name is set to the `config.yaml` file and it has to match the channel name set up in Rocket Chat. This will be the private chat that users will be added to/removed from based on their Pillar ownership status.

### Set up credentials for the service
The service needs Rocket Chat user credentials with **admin privileges and with all 2FA features disabled** for said user. The credentials are set in the `config.yaml` file.

### Set custom fields for the Pillar public key & signature information
The service reads the user's address and signature information from the user's Rocket Chat profile. The user profiles must be configured with custom fields for the user's Pillar's public key, signed message and signature information. The custom fields are configured from `Administration > Settings > Accounts`.

The following values should be used.

For the setting `Custom Fields to Show in User Info`:

```json
[{"Pillar public key": "pubkey"}, {"Message to sign": "message"}, {"Pillar signature": "signature"}]
```

For the setting `Registration > Custom Fields`:

```json
{
    "Pillar public key": {
		"type": "text",
		"required": false,
		"minLength": 2,
		"maxLength": 80,
		"private": true
	},
	"Message to sign": {
		"type": "select",
		"defaultValue": "Acta Non Verba",
		"options": ["Acta Non Verba", "Independent Entity", "Network of Momentum"],
		"required": false,
		"private": true
	},
	"Pillar signature": {
		"type": "text",
		"required": false,
		"minLength": 2,
		"maxLength": 200,
		"private": true
	}
}
```
