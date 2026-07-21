# Appium 2 integration guide

Idelium Docker does not bundle mobile devices, emulators, simulators, or device
farm credentials into the base stack. The portal stores environments and test
definitions, `idelium-cli` executes them, and Appium infrastructure remains an
explicit external dependency selected by the execution host.

This keeps the API/Web/database stack reproducible while still supporting real
Appium 2 execution topologies.

## Supported topologies

### Host Appium server

Use this topology when the CLI runs on the same workstation or CI worker as an
Appium 2 server, Android SDK, iOS tooling, USB devices, emulators, or simulators.

Recommended endpoint from a host-run CLI:

```json
{
  "appiumServer": "http://127.0.0.1:4723"
}
```

When a containerized CLI runner must reach an Appium server running on the Docker
host, use Docker Desktop's host gateway name:

```json
{
  "appiumServer": "http://host.docker.internal:4723"
}
```

Linux hosts may require an explicit gateway mapping or a host-routable address.
Avoid `network_mode: host` unless a documented device-access review proves there
is no narrower alternative.

### Compose-network Appium server

Use this only when the Appium server is intentionally operated as a separate
service on the same Compose network. The Idelium base stack does not define this
service because Appium device access is platform-specific and can require USB,
emulator, simulator, or vendor-specific privileges.

Recommended endpoint from the CLI runner:

```json
{
  "appiumServer": "http://appium:4723"
}
```

If you add a local service, pin the image, add a health check, do not embed
credentials, and document the platform limitations. Keep the service in a
separate override file rather than the base stack.

### External device farm

Use this topology for BrowserStack, Sauce Labs, private device farms, or a
corporate Appium grid. Store provider credentials in the provider integration,
CI secret store, or execution host secret files. Do not write usernames, access
keys, tokens, or signed URLs into tracked Compose files, screenshots, or issue
comments.

Example endpoint shape:

```json
{
  "appiumServer": "https://appium.device-farm.example.invalid/wd/hub"
}
```

Replace the URL with your provider's endpoint and use its secret-management
mechanism for credentials.

## Android examples

### Android native app with UiAutomator2

```json
{
  "isRealDevice": true,
  "appiumServer": "http://127.0.0.1:4723",
  "appiumDesiredCaps": {
    "platformName": "Android",
    "appium:automationName": "UiAutomator2",
    "appium:deviceName": "Android Device",
    "appium:udid": "emulator-5554",
    "appium:app": "/secure/path/to/app-under-test.apk",
    "appium:autoGrantPermissions": true,
    "appium:newCommandTimeout": 120
  }
}
```

### Android mobile browser

```json
{
  "isRealDevice": false,
  "appiumServer": "http://host.docker.internal:4723",
  "appiumDesiredCaps": {
    "platformName": "Android",
    "browserName": "Chrome",
    "appium:automationName": "UiAutomator2",
    "appium:deviceName": "Pixel_8_API_35",
    "appium:newCommandTimeout": 120
  }
}
```

Required host-side dependencies usually include:

- Appium 2 server;
- `uiautomator2` driver;
- Android SDK/platform tools;
- a reachable emulator or physical device;
- Chrome/WebView driver compatibility for browser or hybrid flows.

## iOS examples

### iOS native app with XCUITest

```json
{
  "isRealDevice": true,
  "appiumServer": "http://127.0.0.1:4723",
  "appiumDesiredCaps": {
    "platformName": "iOS",
    "appium:automationName": "XCUITest",
    "appium:deviceName": "iPhone",
    "appium:udid": "00000000-0000000000000000",
    "appium:bundleId": "org.idelium.example",
    "appium:xcodeOrgId": "TEAMID1234",
    "appium:xcodeSigningId": "iPhone Developer",
    "appium:newCommandTimeout": 120
  }
}
```

### iOS Safari simulator

```json
{
  "isRealDevice": false,
  "appiumServer": "http://127.0.0.1:4723",
  "appiumDesiredCaps": {
    "platformName": "iOS",
    "browserName": "Safari",
    "appium:automationName": "XCUITest",
    "appium:deviceName": "iPhone 16",
    "appium:platformVersion": "18.0",
    "appium:newCommandTimeout": 120
  }
}
```

iOS execution requires macOS, Xcode, signing configuration, and Appium's
`xcuitest` driver. A generic Linux container cannot provide a complete iOS
execution environment.

## Cloud provider example

This example intentionally uses placeholder values. Put credentials in the
provider dashboard, CI secret store, or runtime environment expected by the
provider. Do not commit real access keys.

```json
{
  "isRealDevice": true,
  "appiumServer": "https://appium.device-farm.example.invalid/wd/hub",
  "appiumDesiredCaps": {
    "platformName": "Android",
    "appium:automationName": "UiAutomator2",
    "appium:deviceName": "Google Pixel 8",
    "appium:platformVersion": "15",
    "appium:app": "provider-app-reference",
    "appium:newCommandTimeout": 120,
    "provider:options": {
      "projectName": "Idelium mobile regression",
      "buildName": "ci-build-id",
      "sessionName": "smoke"
    }
  }
}
```

Provider-specific namespaces vary. Keep them under the namespace documented by
the provider and avoid placing secrets in the JSON payload unless the provider
explicitly requires a short-lived reference.

## Optional Appium container profile evaluation

The project does not currently ship a generic `compose.appium.yml` profile. That
is intentional:

- iOS requires macOS/Xcode and cannot be represented by a portable Linux Compose
  service.
- Android emulator execution inside containers usually needs hardware
  acceleration, additional kernel capabilities, larger images, and host-specific
  device access.
- Physical Android devices require USB passthrough or a TCP-connected ADB
  server, which is security-sensitive and host-specific.
- Device farms already expose stable Appium endpoints and should not be proxied
  through the base Idelium stack.

If a future Android-only local profile is added, it must live in a separate
override file, use pinned image references, include `/status` health checks, avoid
embedded credentials, and document required host privileges before use.

## Troubleshooting

### Appium server is not reachable

From the CLI host or runner container, verify the status endpoint:

```bash
curl --fail --silent --show-error http://127.0.0.1:4723/status
```

Use `host.docker.internal` when a Compose runner must reach an Appium server on
Docker Desktop's host. Use a Compose service name such as `appium` only when an
Appium server service is attached to the same Compose network.

### Driver is missing

Install and verify the required Appium 2 driver on the Appium server host:

```bash
appium driver list --installed
```

Common drivers include `uiautomator2`, `xcuitest`, and `espresso`. Missing
drivers usually produce session-creation failures before the first test step.

### Plugin-dependent command fails

Some Appium commands depend on plugins or driver-specific extensions. Verify the
server's installed plugins:

```bash
appium plugin list --installed
```

Keep plugin requirements in environment documentation so CI workers and local
execution hosts are provisioned consistently.

### Device cannot be selected

For Android, confirm device visibility without printing secrets:

```bash
adb devices
```

For iOS, confirm the UDID and signing setup through Xcode tooling on the macOS
host. Make sure the `appium:udid`, `appium:deviceName`, and
`appium:platformVersion` values match the target device or simulator.

### Certificate or TLS errors

Use trusted certificates for device farms and internal Appium endpoints. For
local-only development, prefer installing the development CA in the execution
host trust store. Do not disable TLS verification to hide a production
certificate problem.

### Command timeouts

Increase `appium:newCommandTimeout` only when the application or device is known
to be slow. Investigate device logs, app startup behavior, and network latency
before setting very large timeouts. Large timeouts can make failed CI jobs appear
stuck.

### Sensitive diagnostics

When sharing logs, redact:

- authorization headers;
- cookies;
- device-farm usernames and access keys;
- signed application URLs;
- API keys and tokens;
- full device identifiers when they are considered internal inventory data.
