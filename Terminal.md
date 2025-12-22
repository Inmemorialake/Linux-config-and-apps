# Terminal Emulators Testing Guide

Author: @Inmemorialake  
Purpose: Evaluate and compare terminal emulators before settling on a default one  
Scope: Arch Linux + KDE + Fish + Starship

---

## 0. Ground Rules (Very Important)

- Starship configuration must be the **same** for all tests.
- Fish is the shell for all emulators.
- Fonts, font size, and color scheme should be kept **as similar as possible**.
- No heavy theming or ricing during testing.
- Focus on **feel, ergonomics, and friction**, not screenshots.

---

## 1. Shared Prerequisites

Install once, shared by all terminals:

```bash
sudo pacman -S fish starship ttf-jetbrains-mono-nerd
```

Set fish as default shell (if not already):

```bash
chsh -s /usr/bin/fish
```

Ensure Starship is enabled in `config.fish`:

```fish
starship init fish | source
```

---

## 2. Baseline Test Criteria

For each terminal, evaluate the following:

- Startup speed
- Font rendering quality
- Starship prompt behavior
- Copy / paste ergonomics
- Tab / split workflow
- KDE integration
- Configuration complexity
- Overall comfort after ~20 minutes of use

Keep notes after each test.

---

## 3. Terminals to Test

### 3.1 Konsole (Baseline Reference)

Install:

```bash
sudo pacman -S konsole
```

Notes:

- Use default KDE profile first
- Then test with a custom profile (font + colors only)
- This is the **control group**

Config location:

```text
~/.local/share/konsole/
```

---

### 3.2 Alacritty (Minimal & Performance)

Install:

```bash
sudo pacman -S alacritty
```

Config file:

```text
~/.config/alacritty/alacritty.yml
```

Test focus:

- Raw speed
- Keyboard-driven workflow
- Starship rendering

Limitations to observe:

- No tabs (tmux needed)
- Mouse interaction

---

### 3.3 Kitty (Power User Terminal)

Install:

```bash
sudo pacman -S kitty
```

Config file:

```text
~/.config/kitty/kitty.conf
```

Test focus:

- Tabs and splits
- Keybindings
- Font ligatures
- GPU rendering stability

---

### 3.4 Ghostty (Modern & Clean)

Install (AUR):

```bash
paru -S ghostty
```

Config file:

```text
~/.config/ghostty/config
```

Test focus:

- Startup speed
- UI cleanliness
- Wayland/X11 behavior
- Overall "modern" feel

Notes:

- Project is young
- Expect fewer customization knobs

---

### 3.5 Warp (IDE-like Experience)

Install (AUR or official binary):

```bash
paru -S warp-terminal
```

Test focus:

- Command blocks
- UX differences vs traditional terminals
- Productivity features
- Account / cloud dependency

Important:

- Evaluate if this philosophy aligns with Arch minimalism

---

## 4. Testing Procedure (Recommended)

For **each terminal**:

1. Open terminal
2. Navigate large directories
3. Run git commands
4. Trigger command errors
5. Open multiple tabs/splits
6. Leave it open for 15–30 minutes
7. Write immediate impressions

Do **not** tweak configs during first pass.

---

## 5. Evaluation Template

After each test, write something like:

```text
Terminal: <name>

Pros:
- 
- 

Cons:
- 
- 

Feeling:
- 

Decision:
- Keep testing / Discard / Strong candidate
```

---

## 6. Decision Criteria (Final)

Choose the terminal that:

- You forget about while working
- Never makes you think "this is annoying"
- Fits your KDE + Arch workflow naturally
- Makes Starship feel at home

Remember:

> The terminal is a tool, not the rice itself.

---

## 7. Final Notes

- It is OK to keep **Konsole** as default.
- It is OK to change terminals later.
- Starship + shell consistency matters more than emulator choice.

Document the final decision in `README.md`.
