# Colemak-PL

Colemak-PL is the standard US Colemak layout with the physical Caps Lock and
Backspace keys exchanged:

- Caps Lock sends Backspace.
- Backspace sends Caps Lock.

All other keys and layers come from the base XKB `us(colemak)` layout.

## Install on Arch Linux / Omarchy

Install keyd, the system-wide remapper used for the Copilot key:

```sh
sudo pacman -S keyd
```

From this directory, run:

```sh
sudo ./install.sh
```

The installer maps the ASUS Copilot shortcut `Left Meta + Left Shift + F23` to
`Right Control` with keyd. It also installs the Linux text-console
keymap, sets it as the system vconsole keymap, and rebuilds the initramfs so it
is active at the disk-unlock prompt during boot. The system XKB default is set
to layout `us`, variant `colemak_pl`. In Omarchy's
Hyprland configuration (`~/.config/hypr/input.lua`), the input block should
contain:

```lua
kb_layout = "us",
kb_variant = "colemak_pl",
```

Reload Hyprland or log out and back in. XKB settings can also be applied to
other XKB-based desktop environments by selecting layout `us` and variant
`colemak_pl` in their keyboard settings.

On ASUS laptops using `asus_wmi`, the installer sets `fnlock_default=0` so the
function row's media and brightness actions are primary; hold `Fn` for F1–F12.
This module option is stored in `/etc/modprobe.d/90-asus-fnlock.conf` and takes
effect after the next reboot. The config file is outside package-managed paths,
so kernel and system package updates leave it in place.

## Export

`colemak_pl.xkb` is the standalone XKB definition, and `install.sh` installs it
as an XKB variant. `colemak-pl.map` is the corresponding Linux console map.
Share this directory as a Git repository or archive so others can install it
on systems with XKB. The installer backs up the original
`/usr/share/X11/xkb/symbols/us` file before appending the variant.

The installer adds a pacman hook that reapplies the XKB variant after
`xkeyboard-config` updates. Its helper is stored under `/usr/local`, outside
package-managed paths.
