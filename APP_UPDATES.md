# App update prompts

The app checks for updates on startup and when returning to the foreground.
Successful update responses are throttled for five minutes. Optional updates
can be postponed with **Later** and the same version is not prompted again
until the next app session. Required updates remain open while the user visits
the store. Network failures do not block app use.

## Release configuration

Publish a JSON response at:
`https://eportal.rexinsure.com/api/mobile/app-version`

The app also accepts the object inside a `data` field. Example:

```json
{
  "latest_version": "1.1.7",
  "latest_build_number": 25,
  "minimum_supported_version": "1.1.0",
  "force_update": false,
  "title": "Update available",
  "message": "Update Rex Insurance to get the latest improvements.",
  "android_url": "https://play.google.com/store/apps/details?id=com.rexinsure.rexverse",
  "ios_url": "https://apps.apple.com/ng/app/rexverse/id6762462868"
}
```

Update this configuration after the release is available in the stores. Version
numbers determine whether a newer release exists; a higher build number also
triggers the prompt when the version matches. Store URLs are optional and default
to the existing Rexverse listings. Set `force_update` to true, or raise the
minimum supported version/build, to require an update.

This endpoint must describe a release available on both platforms. If release
versions differ between platforms, provide a deployment-specific configuration
URL using `--dart-define=APP_UPDATE_CONFIG_URL=https://your-host/version.json`.
