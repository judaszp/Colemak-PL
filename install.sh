#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run this installer as root (sudo ./install.sh)." >&2
  exit 1
fi

package_dir=$(cd -- "$(dirname -- "$0")" && pwd)
kbd_dir=/usr/share/kbd/keymaps/i386/colemak
persistent_dir=/usr/local/libexec/colemak-pl
vconsole_conf=/etc/vconsole.conf

if ! command -v keyd >/dev/null 2>&1; then
  echo "Install keyd first (Arch/Omarchy: sudo pacman -S keyd)." >&2
  exit 1
fi

"$package_dir/reapply-xkb"
if [[ -f "$package_dir/colemak-pl.map" && -d "$kbd_dir" ]]; then
  gzip -n -c "$package_dir/colemak-pl.map" > "$kbd_dir/colemak-pl.map.gz"
  if [[ -e "$vconsole_conf" ]]; then
    cp -a "$vconsole_conf" "$vconsole_conf.bak.colemak-pl.$(date +%s)"
  fi
  if [[ -f "$vconsole_conf" ]] && grep -q '^KEYMAP=' "$vconsole_conf"; then
    sed -i 's/^KEYMAP=.*/KEYMAP=colemak\/colemak-pl/' "$vconsole_conf"
  else
    printf '\nKEYMAP=colemak/colemak-pl\n' >> "$vconsole_conf"
  fi
  if command -v mkinitcpio >/dev/null 2>&1 && compgen -G '/etc/mkinitcpio.d/*.preset' >/dev/null; then
    mkinitcpio -P
  else
    echo "Set KEYMAP=colemak/colemak-pl in /etc/vconsole.conf and rebuild your initramfs with your system's initramfs tool." >&2
  fi
fi

install -d "$persistent_dir" /etc/pacman.d/hooks /etc/keyd /etc/modprobe.d
install -m 0755 "$package_dir/reapply-xkb" "$persistent_dir/reapply-xkb"
install -m 0644 "$package_dir/hooks/98-colemak-pl.hook" /etc/pacman.d/hooks/98-colemak-pl.hook
install -m 0644 "$package_dir/modprobe.d/90-asus-fnlock.conf" /etc/modprobe.d/90-asus-fnlock.conf
if [[ -e /etc/keyd/default.conf ]] && ! grep -qF 'leftmeta+leftshift+f23 = rightcontrol' /etc/keyd/default.conf; then
  cp -a /etc/keyd/default.conf "/etc/keyd/default.conf.bak.colemak-pl.$(date +%s)"
fi
install -m 0644 "$package_dir/keyd/default.conf" /etc/keyd/default.conf

if command -v systemctl >/dev/null 2>&1; then
  systemctl enable --now keyd.service
fi

cat <<'MSG'
Colemak-PL is installed as system XKB layout us, variant colemak_pl.
The Linux console and early-boot keymap is colemak/colemak-pl.
The keyd Copilot mapping is configured to emit Right Control.
The pacman hook will restore the XKB variant after xkeyboard-config updates.
Set kb_layout = "us" and kb_variant = "colemak_pl" in Hyprland input config if not already set.
MSG
