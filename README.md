# Border Control

Security tool prototype in Objective-C for macOS, utilizing Apple's Network Extension Framework and Endpoint Security Framework. The tool enables comprehensive tracking of web requests and file operations, providing users with enhanced visibility and control over their system's security. The tool actively monitors network traffic, allowing for the detection of potential threats and vulnerabilities in real-time.

## Development

You’ll need to request a System Extension entitlement from Apple. https://developer.apple.com/system-extensions/
While your request is in review, you can test system extensions on your Mac by temporarily turning off System Integrity Protection.

### Disable SIP

To temporarily disable System Integrity Protection (SIP) on your Mac, you can follow these steps:

1. Boot your Mac into Recovery Mode.
2. In Recovery Mode, click on the "Utilities" menu in the menu bar at the top and select "Terminal" to open a Terminal window.
3. In the Terminal, type the following command and press Enter: `csrutil disable`

It's important to note that disabling SIP removes security protections from your Mac.

## Installing

1. Uninstall previously loaded BorderControl system extension using systemextensionsctl.
2. Verify and codesign using specified entitlements and provided certificate.
3. Run the app from the specified directory with sudo mode.
4. Start the WebSocket server to receive event messages.

Note that there is a helper tool available which automates all the steps mentioned above, run `./builder.sh`

## Running

After the installation, the following steps need to be performed:

- The app will prompt to load the network system extension. Accept the network prompt from macOS.
- The app will prompt to load the endpoint security system extension. Grant the app full disk access in the macOS Security & Privacy settings.

## License

MIT License