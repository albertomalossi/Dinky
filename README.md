<img src="docs/assets/icon.png" alt="dinky" width="128">

# dinky

> oh wow. you moved a rectangle.

A tiling window manager for macOS that leaves System Integrity Protection on.

```sh
brew install --cask mikker/tap/dinky
```

[Documentation](https://dinky.rodeo)

## Quick start

Open dinky and grant Accessibility when asked. Windows tile as they open.

- `dinky workspace 3`: Switch to workspace 3.
- `dinky layout accordion`: Stack the focused container.
- `dinky doctor`: Check the config, the macOS settings dinky needs, and that no other tiler is running.

Learn more:

- [Concepts](https://dinky.rodeo/concepts/) and [Layouts](https://dinky.rodeo/layouts/)
- [Configuration](https://dinky.rodeo/configuration/)
- [Commands](https://dinky.rodeo/commands/)

## Frame recovery

If a tiled window answers a frame write at a displaced origin or a smaller size, Dinky makes up to three additional layout passes after 250, 500 and 1000 ms. Recovery stops when a newer pass replaces it, tiling is disabled, the Space is hidden, the layout changes or a mouse drag is in progress. Unreadable windows are not retried. Larger frames at the requested origin retain the existing minimum-size handling. Accessibility write errors and unresolved frames are logged for diagnosis. Normal tile changes animate from the live window position. Repeated requests for the same tile correct the frame directly instead of replaying the animation; this animation history does not count a misplaced frame as successfully settled.

Frame requests superseded by a newer request for the same window are skipped before writing or retrying. Recovery diagnostics include the app's Enhanced UI status and Accessibility versus WindowServer frames; slow or failed attribute writes include timing. Before each frame batch, Dinky checks whether Enhanced UI was re-enabled and disables it when needed. It leaves that mode alone while VoiceOver or Switch Control is enabled. Setter status and readback are both logged because some apps report an error even when the value changes.

MIT licensed.
