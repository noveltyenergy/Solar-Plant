# NEL Energy Dashboard

Website: https://noveltyenergy.github.io/Solar-Plant/

Edit `NEL_Energy_Flow_Dashboard_v13.html`. Push to `main` to publish automatically through GitHub Pages. The workflow publishes only the HTML, at both the root URL and its original filename.

## Publish from Windows

One-time publish from this folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Publish-Dashboard.ps1
```

Automatically commit and push the dashboard after each saved change:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Publish-Dashboard.ps1 -Watch
```

Keep the watcher running while editing; Ctrl+C stops a visible watcher. Restart it after restarting Windows. Only the dashboard HTML is automatically committed; firmware and other files are not included. Network/push failures retry after 30 seconds. Conflicting remote edits require normal Git reconciliation; the publisher never force-pushes.

The public website updates after the Pages deployment succeeds, usually within a few minutes. See the repository Actions tab for progress.

## Existing plants and readings

Plant settings, saved readings, graph history and alarm history are kept in browser storage, separate for each browser and origin. Export a backup from the local dashboard Settings, open the hosted website, and restore that backup there. Private channels need their read keys; include keys in a backup only when transferring through your own device. Backups are never uploaded by the publisher.

ThingSpeak write keys belong in firmware only. `.ino` files are intentionally ignored and are not part of the website. Do not paste API keys or exported backups into the HTML or commit them.
