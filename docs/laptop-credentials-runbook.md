# Runbook: Mailspring re-login + SSH passphrase on the laptop

**Audience: an AI coding agent working on the LAPTOP.** Follow this top to
bottom. Run the diagnostics first, then apply only the fixes the diagnostics
call for. Report what you found and changed.

Two separate problems, same theme (a credential daemon isn't reachable in
the session):

1. **Mailspring asks you to log in to every email account on each start.**
   Its stored credentials aren't retrievable, because the freedesktop Secret
   Service (`org.freedesktop.secrets`) either isn't running or the wallet
   was never unlocked.
2. **`git push`/`pull` asks for the SSH key passphrase every time.** No
   ssh-agent is holding the key. (On the desktop the key simply has no
   passphrase, which is why it never prompts there — nothing is "broken" on
   the laptop, the two machines were set up differently.)

Nothing in the repo fixes these automatically: the pieces that matter live
in **machine-local files that stow does not manage** (`/etc/pam.d/sddm`,
`~/.config/autostart/Mailspring.desktop`, `~/.ssh/config`).

Background: this setup uses KWallet's `ksecretd` as the Secret Service —
a deliberate exception to the otherwise KDE-free goal. Do not propose
gnome-keyring.

---

## Step 0 — make sure the repo is current

```sh
cd ~/stow && git pull
stow -R app-configs local shell    # relink in case new files arrived
systemctl --user daemon-reload
```

---

## Part A — Mailspring credentials

### A1. Diagnose (run all four, note the output)

```sh
# 1. Is the Secret Service actually claimed on the session bus?
busctl --user status org.freedesktop.secrets 2>/dev/null | grep -E '^(PID|Comm)' \
  || echo "MISSING: nothing owns org.freedesktop.secrets"

# 2. Is kwallet-pam wired into the login stack? (this is what unlocks the
#    wallet with your login password, so nothing prompts later)
grep -n kwallet /etc/pam.d/sddm || echo "MISSING: no pam_kwallet lines"

# 3. Does a wallet file exist (i.e. credentials were ever stored)?
ls -la ~/.local/share/kwalletd/ 2>/dev/null || echo "MISSING: no wallet yet"

# 4. Does Mailspring launch with the flag that routes it to the Secret
#    Service? Electron only auto-detects GNOME/KDE, so it must be explicit.
grep '^Exec' ~/.config/autostart/Mailspring.desktop 2>/dev/null
grep '^Exec' ~/.local/share/applications/Mailspring.desktop 2>/dev/null
```

Reference: on the working desktop, (1) shows `Comm=ksecretd` with
`CommandLine=/usr/bin/ksecretd --pam-login ...`, (2) shows four
`pam_kwallet`/`pam_kwallet5` lines, (3) shows `kdewallet.kwl`, and (4) shows
`Exec=mailspring --password-store=gnome-libsecret --background %U`.

### A2. Fix whatever is missing

**If (4) lacks `--password-store=gnome-libsecret`** — most likely cause, fix
this first:

```sh
sed -i 's|^Exec=mailspring --background|Exec=mailspring --password-store=gnome-libsecret --background|' \
    ~/.config/autostart/Mailspring.desktop
grep '^Exec' ~/.config/autostart/Mailspring.desktop   # verify
```

The repo already ships a launcher override with the flag at
`~/.local/share/applications/Mailspring.desktop` (covers menu/rofi
launches); the autostart copy above is machine-local and separate.

**If (1) is MISSING** — start it and confirm it claims the bus name:

```sh
~/.local/bin/ensure-secret-service
sleep 2
busctl --user status org.freedesktop.secrets | grep -E '^(PID|Comm)'
```

That script is the right tool: it tests **bus-name ownership**, not the
process list, because `kwallet-pam` leaves a bus-less `ksecretd --pam-login`
running that satisfies a naive `pgrep` while serving nothing. It runs at
login from `modules/autostart.lua`, so if it works by hand but not at login,
say so rather than papering over it.

**If (2) is MISSING** — needs root; ask the user before editing. The package
is `kwallet-pam`:

```sh
rpm -q kwallet-pam || sudo dnf install kwallet-pam
```

If the package is installed but the lines are absent from `/etc/pam.d/sddm`,
report that to the user with the desktop's working stanza (auth + session,
`optional`, `auto_start`) rather than editing the PAM stack unattended — a
malformed PAM file can lock the user out of login.

### A3. Verify

1. Fully **log out and back in** (not just an awesome reload — PAM only runs
   at login).
2. `busctl --user status org.freedesktop.secrets` → owned by `ksecretd`.
3. Start Mailspring. Log in to the accounts **once**.
4. Log out, log back in, start Mailspring → it should **not** ask again.

If it still asks after a clean login, the wallet isn't being unlocked by
PAM. Check whether the wallet's password matches the login password — a
wallet created with a different password can't be auto-unlocked, and the
fix is to delete `~/.local/share/kwalletd/kdewallet.kwl` and let it be
recreated at next login (**this discards stored secrets** — confirm with the
user first).

---

## Part B — SSH passphrase on every push

### B1. Diagnose

```sh
echo "SSH_AUTH_SOCK=${SSH_AUTH_SOCK:-UNSET}"
ssh-add -l                       # "no identities" = agent running, key not loaded
grep -q ENCRYPTED ~/.ssh/id_ed25519 && echo "key IS passphrase-protected" \
                                    || echo "key has NO passphrase"
cat ~/.ssh/config 2>/dev/null
```

### B2. Fix

Add `AddKeysToAgent yes` so the key is loaded into the running agent on
first use — passphrase once per login instead of every push. Keep the
existing `github.com` block; do not remove `IdentityFile`.

```sh
# Only add if absent
grep -q '^[[:space:]]*AddKeysToAgent' ~/.ssh/config 2>/dev/null || \
  printf 'Host *\n    AddKeysToAgent yes\n\n' | cat - ~/.ssh/config > /tmp/sshcfg \
  && mv /tmp/sshcfg ~/.ssh/config
chmod 600 ~/.ssh/config
cat ~/.ssh/config
```

`~/.ssh/config` is deliberately **not** in the stow repo (it sits beside
private key material), so this edit is machine-local and must be made here.

If `SSH_AUTH_SOCK` was UNSET, no agent is running in the session — report
that; the session normally provides one at
`/run/user/$UID/ssh-agent.socket`.

### B3. Verify

```sh
ssh-add ~/.ssh/id_ed25519     # enter passphrase ONCE
ssh-add -l                    # key now listed
cd ~/stow && git fetch        # should NOT prompt
```

Then log out/in and run `git fetch` again: expect **one** passphrase prompt
on the session's first key use, and silence thereafter.

---

## Reporting back

Summarize: which diagnostics were MISSING, what you changed, and the
verification result. Explicitly flag anything needing root or anything that
still prompts after a clean login — do not mark it fixed on the strength of
a by-hand run that a login might not reproduce.
