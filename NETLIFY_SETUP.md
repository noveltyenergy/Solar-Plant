# Shared website configuration

The website can load the published plant and channel list automatically in a new browser. The metadata is in `netlify/shared-dashboard.json`. Private ThingSpeak read keys are available only to Netlify Functions and are never returned to the browser.

## One-time setup on Netlify

1. Open the WattWeave project in Netlify.
2. Open **Project configuration → Environment variables → Add a variable → Import from a .env file**.
3. On your own computer, open `C:\Users\shafi\Downloads\WattWeave-Netlify-Private.env` and copy its contents into the import form.
4. Use **All scopes** (or **Functions** if available), and apply to **Production**. Save/import the variable.
5. Trigger a new production deploy from `main`.
6. Open the site in a private/incognito browser. Plants and live telemetry should load without restoring a backup.

The variable is named `NEL_THINGSPEAK_READ_KEYS`. Do not paste the private file in GitHub, source HTML, `netlify.toml`, or a public message. Netlify's environment import is the intended destination. The file is required only once per site, and again if read keys change.

## Behavior

- Published configuration is loaded on every visit; matching local readings and histories are kept.
- The configured channels are read through `/.netlify/functions/telemetry`. The function permits only the channel IDs in the published list and returns the latest eight fields and source timestamp.
- New browsers get current readings from ThingSpeak. Graph history and alarm acknowledgement still belong to each browser; this change is not a shared historical database.
- If Wokwi is stopped, the latest ThingSpeak entry remains available and is labelled stale/offline according to its timestamp.
- Local HTML and GitHub Pages keep their existing direct ThingSpeak configuration. Netlify is the host for the shared server configuration.
- Changes made in a browser's Settings are local. To update the default list for everyone, update `netlify/shared-dashboard.json` and push. A channel's read key must also be added to the environment variable before using a new private channel.

Check `/.netlify/functions/shared-config`: a successful response contains metadata and no keys. A 503 means the server environment is incomplete; a 404 means the function has not been deployed.
