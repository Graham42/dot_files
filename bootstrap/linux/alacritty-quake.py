#!/usr/bin/env python3

"""Sets up a Guake-style drop-down Alacritty on GNOME: press one key, a terminal
slides down from the top; press it again, it goes away. It also gives Alacritty
a color theme, since the terminal is no use without one.

Why it's built this way:

  - Wayland gives applications no global hotkeys - the compositor owns the
    keyboard - so the hotkey has to be registered with GNOME, not Alacritty.
  - Alacritty will never grow a drop-down mode of its own; upstream closed
    that request as wontfix (alacritty/alacritty#1119).
  - The usual X11 answers (tdrop, xdotool, wmctrl) are dead here: GNOME 50
    removed the X11 session entirely, so there's no /usr/share/xsessions.

  That leaves a GNOME Shell extension owning both the hotkey and the
  show/hide. Quake Terminal is the maintained one (declares GNOME 45-50).

The drop-down gets its own app id (--class) and its own config file rather
than reusing the stock Alacritty.desktop, because the extension adopts
`app.get_windows()[0]` of whatever app it's pointed at - aimed at plain
Alacritty it would grab an ordinary terminal window you already had open.

Python rather than bash, unlike the rest of this directory, because most of
the work is editing config files - TOML, YAML and the JSON that
extensions.gnome.org answers with - which bash can only do with a pile of sed.
Only the standard library is used, so there is nothing to install first.
"""

import argparse
import ast
import json
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

EXTENSION_UUID = "quake-terminal@diegodario88.github.io"
EXTENSION_PAGE = "https://extensions.gnome.org/extension/6307/quake-terminal/"
EXTENSION_INFO_URL = "https://extensions.gnome.org/extension-info/"
APP_ID = "alacritty-quake"
HOME = Path.home()
DESKTOP_FILE = HOME / ".local/share/applications" / (APP_ID + ".desktop")
ALACRITTY_DIR = HOME / ".config/alacritty"
QUAKE_CONFIG = ALACRITTY_DIR / "quake.toml"
MAIN_CONFIG = ALACRITTY_DIR / "alacritty.toml"
THEMES_DIR = ALACRITTY_DIR / "themes"
GOGH_THEMES_URL = "https://raw.githubusercontent.com/Gogh-Co/Gogh/master/themes"
DEFAULT_THEME = "Night Owl"
SCHEMA_ID = "org.gnome.shell.extensions.quake-terminal"

# Drop-down geometry. Sizes are percentages of the monitor's work area - the
# screen minus the top bar and dock - not of the whole screen. The extension
# re-applies these every time the window is shown, so resizing the window by
# hand never sticks; this is the only durable place to set it.
VERTICAL_SIZE = 100  # height, % (the prefs UI allows 10-100)
HORIZONTAL_SIZE = 100  # width, %  (the prefs UI allows 30-100)
HORIZONTAL_ALIGNMENT = 2  # 0 = left, 1 = right, 2 = center
# Duration of the slide-down animation in milliseconds. 0 is a supported value
# (the prefs spinner goes 0-500), not a hack - the window just snaps into place.
ANIMATION_TIME = 0


def log(message=""):
    print("\033[34m%s\033[0m" % message)


def warn(message=""):
    print("\033[33m%s\033[0m" % message, file=sys.stderr)


def die(*messages):
    for message in messages:
        print(message, file=sys.stderr)
    sys.exit(1)


def run(*command, check=True, capture=False, quiet=False):
    """Run a command. Returns its stdout when capture=True, else whether it
    succeeded (with check=False, which is how the optional steps below ask
    'did that work?' without blowing up the whole run)."""
    result = subprocess.run(
        command,
        check=check,
        text=True,
        stdout=subprocess.PIPE if capture else (subprocess.DEVNULL if quiet else None),
        stderr=subprocess.DEVNULL if quiet else None,
    )
    return result.stdout.strip() if capture else result.returncode == 0


def fetch(url):
    """GET a URL, or raise urllib.error.URLError (HTTPError is a subclass)."""
    with urllib.request.urlopen(url) as response:
        return response.read()


################################################################################
# gsettings
################################################################################


def gsettings_get(schema, key, schemadir=None):
    command = ["gsettings"]
    if schemadir:
        command += ["--schemadir", str(schemadir)]
    return run(*command, "get", schema, key, capture=True)


def gsettings_set(schema, key, value, schemadir=None):
    command = ["gsettings"]
    if schemadir:
        command += ["--schemadir", str(schemadir)]
    run(*command, "set", schema, key, value)


def gvariant_string_list(value):
    """Read a GVariant array of strings as printed by `gsettings get`, e.g.
    "['a', 'b']". The empty array prints as "@as []", which isn't a python
    literal, hence the special case."""
    value = value.strip()
    if value.startswith("@as"):
        value = value[len("@as"):].strip()
    return [str(item) for item in ast.literal_eval(value)]


def format_gvariant_string_list(items):
    # gsettings needs the type prefix on an empty array; it can't infer the
    # element type from "[]" alone.
    if not items:
        return "@as []"
    return "[%s]" % ", ".join("'%s'" % item for item in items)


################################################################################
# Color theme
################################################################################

# Gogh (https://github.com/Gogh-Co/Gogh) is a collection of terminal themes,
# one YAML file per theme. Its own Alacritty installer isn't used here: it
# rewrites alacritty.toml in place - dropping anything it doesn't understand -
# and needs python packages (tomli, tomli_w, ruamel.yaml) that aren't in the
# Ubuntu repos. The theme file is plain enough to convert directly, so the
# colors land in a file of their own under themes/ and the main config just
# imports it. Generated code stays out of the hand-written config, and
# switching themes is one re-run.

# The slot-by-slot mapping is Gogh's own (see apply_alacritty in its
# apply-colors.sh): color_01-08 are the normal colors, 09-16 the bright ones.
COLOR_NAMES = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]


def theme_file_for(theme):
    return THEMES_DIR / (theme.lower().replace(" ", "-") + ".toml")


def theme_url_for(theme):
    # Theme names have spaces in them ("Night Owl.yml"), which a URL doesn't.
    return "%s/%s.yml" % (GOGH_THEMES_URL, urllib.parse.quote(theme))


def gogh_theme_to_toml(theme, yaml_text):
    """Convert a Gogh theme file to an Alacritty color config."""
    # A Gogh theme is a flat list of "key: '#RRGGBB'  # comment" lines, so a
    # regex reads it without pulling in a YAML parser.
    colors = dict(re.findall(r"^(\w+):\s*'([^']*)'", yaml_text, re.M))

    wanted = ["background", "foreground"] + ["color_%02d" % i for i in range(1, 17)]
    missing = [key for key in wanted if not colors.get(key)]
    if missing:
        die("The %s theme is missing %s - is it a Gogh theme file?"
            % (theme, ", ".join(missing)))

    lines = [
        "# %s, converted from the Gogh theme of the same name by" % theme,
        "# alacritty-quake.py. Rewritten every time that script runs, so put",
        "# your own tweaks in alacritty.toml instead.",
        "",
        "[colors.primary]",
        "background = %s" % json.dumps(colors["background"]),
        "foreground = %s" % json.dumps(colors["foreground"]),
    ]

    # Gogh's own Alacritty support stops at the 16 colors plus the primaries,
    # but the theme file carries a cursor color too. `text` is what shows
    # through the block cursor, so pinning it to the background keeps the
    # character under the cursor readable.
    if colors.get("cursor"):
        lines += [
            "",
            "[colors.cursor]",
            "cursor = %s" % json.dumps(colors["cursor"]),
            "text = %s" % json.dumps(colors["background"]),
        ]

    for table, offset in (("normal", 0), ("bright", 8)):
        lines += ["", "[colors.%s]" % table]
        lines += ["%s = %s" % (name, json.dumps(colors["color_%02d" % (offset + i + 1)]))
                  for i, name in enumerate(COLOR_NAMES)]

    return "\n".join(lines) + "\n"


def install_theme(theme):
    """Write the theme file and point the main config at it."""
    destination = theme_file_for(theme)
    url = theme_url_for(theme)

    try:
        yaml_text = fetch(url).decode("utf-8")
    except urllib.error.URLError as error:
        if destination.exists():
            warn("Couldn't fetch the %s theme from Gogh (%s) - keeping the existing %s"
                 % (theme, error, destination))
            add_theme_import(destination)
            return
        die("Couldn't fetch the '%s' theme from Gogh:" % theme,
            "    %s (%s)" % (url, error),
            "Themes are named after their file in "
            "https://github.com/Gogh-Co/Gogh/tree/master/themes")

    log("Writing %s (%s, converted from Gogh)" % (destination, theme))
    THEMES_DIR.mkdir(parents=True, exist_ok=True)
    destination.write_text(gogh_theme_to_toml(theme, yaml_text))
    add_theme_import(destination)


def add_theme_import(theme_file):
    """Hook the theme up to the main config, which is where ordinary Alacritty
    windows and (via its own import) the drop-down both read their colors from.
    Only the import is managed here; the rest of the file is the user's. Note
    the file may well not exist - nothing else in this repo writes one - in
    which case it gets created with just the import."""
    entry = json.dumps(str(theme_file))

    if not MAIN_CONFIG.exists():
        MAIN_CONFIG.parent.mkdir(parents=True, exist_ok=True)
        MAIN_CONFIG.write_text(
            "# Alacritty config. The color theme is generated by\n"
            "# alacritty-quake.py; everything else here is yours to edit.\n"
            "\n[general]\nimport = [%s]\n" % entry
        )
        log("Created %s importing the theme" % MAIN_CONFIG)
        return

    text = MAIN_CONFIG.read_text()

    # Switching themes has to take the previous one's import out. Alacritty
    # applies imports in order, so leaving it in would let the old theme paint
    # over the new one.
    text, dropped = drop_theme_imports(text, keep=str(theme_file))

    if entry in text:
        if dropped:
            MAIN_CONFIG.write_text(text)
            log("%s already imports the theme (dropped %d stale one%s)"
                % (MAIN_CONFIG, dropped, "" if dropped == 1 else "s"))
        else:
            log("%s already imports the theme" % MAIN_CONFIG)
        return

    # Alacritty 0.13.0 had a top-level `import`, 0.13.2 moved it under
    # [general]; extending whichever array is already there handles both, and a
    # multi-line array as well, since only the opening bracket is matched. The
    # theme goes first in the array so that anything imported after it, and the
    # file's own settings, still win - imports are applied in order.
    array = re.search(r"^[ \t]*import[ \t]*=[ \t]*\[", text, re.M)
    general = re.search(r"^[ \t]*\[general\][ \t]*$", text, re.M)
    if array:
        rest = text[array.end():]
        # No separator needed when the array was empty, or the file ends up
        # with a stray "[..., ]".
        separator = "" if rest.lstrip().startswith("]") else ", "
        text = text[:array.end()] + entry + separator + rest
    elif general:
        text = text[:general.end()] + "\nimport = [%s]" % entry + text[general.end():]
    else:
        # Appended rather than prepended: a bare key at the top of the file
        # would be swallowed by a [general] header put in front of it.
        text = text.rstrip("\n") + "\n\n[general]\nimport = [%s]\n" % entry

    MAIN_CONFIG.write_text(text)
    log("Added the theme import to %s" % MAIN_CONFIG)


def drop_theme_imports(text, keep=None):
    """Remove import entries pointing into the generated themes directory,
    except `keep`. Returns the new text and how many were dropped."""
    pattern = re.compile(r'"[^"]*%s/[^"]*"[ \t]*,?[ \t]*' % re.escape(str(THEMES_DIR)))

    dropped = 0

    def replace(match):
        nonlocal dropped
        if keep and keep in match.group(0):
            return match.group(0)
        dropped += 1
        return ""

    return pattern.sub(replace, text), dropped


def remove_theme():
    if THEMES_DIR.is_dir():
        log("Removing %s" % THEMES_DIR)
        shutil.rmtree(THEMES_DIR)

    # The main config can be hand-written, so only the generated import is
    # pulled out of it - unless that import is all it ever had.
    if not MAIN_CONFIG.exists():
        return
    text = MAIN_CONFIG.read_text()
    stripped, dropped = drop_theme_imports(text)
    if not dropped:
        return

    # Nothing but comments and the now-empty import block means this file was
    # written by this script and has been untouched since.
    leftover = [line.strip() for line in stripped.splitlines() if line.strip()]
    generated = all(line.startswith("#")
                    or line == "[general]"
                    or re.fullmatch(r"import[ \t]*=[ \t]*\[\s*\]", line)
                    for line in leftover)
    if generated:
        log("Removing %s" % MAIN_CONFIG)
        MAIN_CONFIG.unlink()
    else:
        log("Removing the theme import from %s" % MAIN_CONFIG)
        MAIN_CONFIG.write_text(stripped)


################################################################################
# The extension
################################################################################


def extension_known_to_shell():
    return run("gnome-extensions", "info", EXTENSION_UUID, check=False, quiet=True)


def schema_dir():
    """Where the extension's gsettings schema lives. Local installs (what
    `gnome-extensions install` does) land in ~/.local; ask gnome-extensions
    where it actually is in case it was installed system-wide instead."""
    directory = HOME / ".local/share/gnome-shell/extensions" / EXTENSION_UUID / "schemas"
    if not directory.is_dir() and extension_known_to_shell():
        info = run("gnome-extensions", "info", EXTENSION_UUID, capture=True)
        path = re.search(r"^ *Path: *(.+)$", info, re.M)
        if path:
            directory = Path(path.group(1)) / "schemas"
    return directory


def install_extension():
    """Returns True if the extension was newly installed, meaning the session
    has to be restarted before it will run."""
    if extension_known_to_shell():
        log("Quake Terminal extension already installed")
        return False
    if (HOME / ".local/share/gnome-shell/extensions" / EXTENSION_UUID).is_dir():
        # Installed on disk but the running shell hasn't picked it up yet -
        # that's this script having been run once already without a re-login.
        log("Quake Terminal extension already installed (pending a session restart)")
        return True

    version = run("gnome-shell", "--version", capture=True)
    shell_version = re.search(r"\d+", version).group(0)
    log("Fetching Quake Terminal for GNOME Shell %s..." % shell_version)

    # extensions.gnome.org serves a different build per shell version, so ask
    # the API which one this machine needs rather than guessing a URL.
    query = urllib.parse.urlencode({"uuid": EXTENSION_UUID, "shell_version": shell_version})
    info = json.loads(fetch("%s?%s" % (EXTENSION_INFO_URL, query)))
    download_path = info.get("download_url")
    if not download_path:
        die("No Quake Terminal build for GNOME Shell %s." % shell_version,
            "Check %s for which versions it supports." % EXTENSION_PAGE)

    with tempfile.TemporaryDirectory() as tmpdir:
        zip_path = Path(tmpdir) / "quake-terminal.zip"
        zip_path.write_bytes(fetch("https://extensions.gnome.org" + download_path))
        run("gnome-extensions", "install", "--force", str(zip_path))
    log("Installed.")
    return True


def enable_extension():
    # On Wayland the shell can't be restarted in place, so a just-installed
    # extension isn't enableable over D-Bus yet. Writing the gsettings key
    # directly gets it enabled at next login either way.
    if run("gnome-extensions", "enable", EXTENSION_UUID, check=False, quiet=True):
        log("Extension enabled")
        return
    enabled = gvariant_string_list(gsettings_get("org.gnome.shell", "enabled-extensions"))
    if EXTENSION_UUID in enabled:
        log("Extension already queued to enable at next login")
        return
    gsettings_set("org.gnome.shell", "enabled-extensions",
                  format_gvariant_string_list(enabled + [EXTENSION_UUID]))
    log("Extension will be enabled at next login")


def configure_extension(shortcut):
    schemas = schema_dir()
    if not schemas.is_dir():
        die("Can't find the extension's schemas (looked in %s)" % schemas)
    # The packaged extension ships gschemas.compiled, but a source checkout
    # may not.
    if not (schemas / "gschemas.compiled").exists() and shutil.which("glib-compile-schemas"):
        run("glib-compile-schemas", str(schemas))

    log("Pointing the extension at %s, bound to %s" % (APP_ID, shortcut))
    gsettings_set(SCHEMA_ID, "terminal-id", DESKTOP_FILE.name, schemadir=schemas)
    gsettings_set(SCHEMA_ID, "terminal-shortcut",
                  format_gvariant_string_list([shortcut]), schemadir=schemas)

    # Re-applied on every run, so tweaks made in the Extensions app get
    # reverted the next time this runs - change the values at the top of this
    # script instead.
    log("Setting geometry (%d%% x %d%%) and animation (%dms)"
        % (HORIZONTAL_SIZE, VERTICAL_SIZE, ANIMATION_TIME))
    gsettings_set(SCHEMA_ID, "vertical-size", str(VERTICAL_SIZE), schemadir=schemas)
    gsettings_set(SCHEMA_ID, "horizontal-size", str(HORIZONTAL_SIZE), schemadir=schemas)
    gsettings_set(SCHEMA_ID, "horizontal-alignment", str(HORIZONTAL_ALIGNMENT), schemadir=schemas)
    gsettings_set(SCHEMA_ID, "animation-time", str(ANIMATION_TIME), schemadir=schemas)
    return schemas


def remove_extension():
    if extension_known_to_shell():
        log("Removing the Quake Terminal extension...")
        run("gnome-extensions", "disable", EXTENSION_UUID, check=False, quiet=True)
        run("gnome-extensions", "uninstall", EXTENSION_UUID, check=False, quiet=True)
    # `gnome-extensions disable` only touches this key when the shell knows
    # about the extension, so clear it directly too.
    enabled = gvariant_string_list(gsettings_get("org.gnome.shell", "enabled-extensions"))
    if EXTENSION_UUID in enabled:
        enabled.remove(EXTENSION_UUID)
        gsettings_set("org.gnome.shell", "enabled-extensions",
                      format_gvariant_string_list(enabled))


################################################################################
# Alacritty itself, and the files that make the drop-down its own app
################################################################################


def install_alacritty():
    if shutil.which("alacritty"):
        log("Alacritty already installed (%s)" % run("alacritty", "--version", capture=True))
    else:
        log("Installing alacritty...")
        run("sudo", "apt-get", "install", "-y", "alacritty")


def write_quake_config():
    # A separate config file keeps the drop-down's look (no titlebar, no
    # padding fighting the animation) from leaking into ordinary Alacritty
    # windows. The import of the main config is unconditional on purpose:
    # Alacritty skips missing imports, so this works whether or not
    # alacritty.toml exists yet.
    QUAKE_CONFIG.parent.mkdir(parents=True, exist_ok=True)
    if QUAKE_CONFIG.exists():
        log("Keeping existing %s" % QUAKE_CONFIG)
        return
    log("Writing %s" % QUAKE_CONFIG)
    QUAKE_CONFIG.write_text(
        "# Config for the drop-down Alacritty instance (see alacritty-quake.py).\n"
        "# Everything else is inherited from the main config; edit this file freely,\n"
        "# the setup script won't overwrite it.\n"
        "\n"
        "[general]\n"
        "import = [%s]\n"
        "\n"
        "[window]\n"
        "# The extension positions and sizes the window itself, so a titlebar is just\n"
        "# lost rows.\n"
        'decorations = "none"\n' % json.dumps(str(MAIN_CONFIG))
    )


def write_desktop_file():
    # Requirements this file has to satisfy, both from the extension's app
    # picker (src/prefs.js): Categories must contain "terminal", and it must
    # not be NoDisplay, or it can't be selected in the preferences UI. The
    # script sets the app via gsettings anyway, but the picker should still
    # work.
    log("Writing %s" % DESKTOP_FILE)
    DESKTOP_FILE.parent.mkdir(parents=True, exist_ok=True)
    DESKTOP_FILE.write_text(
        "[Desktop Entry]\n"
        "Type=Application\n"
        "Name=Alacritty (Quake)\n"
        "Comment=Alacritty instance dedicated to the drop-down terminal\n"
        "Exec=alacritty --class {app_id} --config-file {config}\n"
        "Icon=Alacritty\n"
        "Terminal=false\n"
        "Categories=System;TerminalEmulator;\n"
        "StartupWMClass={app_id}\n".format(app_id=APP_ID, config=QUAKE_CONFIG)
    )
    update_desktop_database()


def update_desktop_database():
    if shutil.which("update-desktop-database"):
        run("update-desktop-database", str(DESKTOP_FILE.parent), check=False, quiet=True)


################################################################################
# Entry point
################################################################################


def parse_args():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--shortcut", default="XF86Launch5", metavar="ACCEL",
        help="GTK accelerator for the toggle. Default: %(default)s, which is "
             "what the F14 that remap-keys.sh puts on Caps Lock actually sends "
             "- xkb renames F13-F18 to XF86 keysyms, so \"F14\" as an "
             "accelerator never fires. Other examples: '<Super>Return', "
             "'<Super>grave', 'F12'.",
    )
    parser.add_argument(
        "--theme", default=DEFAULT_THEME, metavar="NAME",
        help="Color theme from Gogh, named after its file in "
             "https://github.com/Gogh-Co/Gogh/tree/master/themes minus the "
             ".yml. Default: %(default)s. Pass --theme '' to leave the colors "
             "alone.",
    )
    parser.add_argument(
        "--uninstall", action="store_true",
        help="Undo everything above except the alacritty package.",
    )
    return parser.parse_args()


def uninstall():
    remove_extension()
    for path in (DESKTOP_FILE, QUAKE_CONFIG):
        if path.exists():
            log("Removing %s" % path)
            path.unlink()
    remove_theme()
    update_desktop_database()
    log("Done. The alacritty package was left installed; "
        "remove it with 'sudo apt remove alacritty'.")


def whats_left_by_hand(shortcut, schemas, fresh_install):
    keyd_config = Path("/etc/keyd/default.conf")
    maps_f14 = keyd_config.exists() and "f14" in keyd_config.read_text()
    if shortcut == "XF86Launch5" and not maps_f14:
        warn()
        warn("Heads up: the shortcut is XF86Launch5, which is what F14 sends, but no")
        warn("keyd config maps anything to f14 - so no key on the keyboard will")
        warn("trigger it. Either run ./remap-keys.sh to put F14 on Caps Lock, or")
        warn("re-run this with e.g.")
        warn("    %s --shortcut '<Super>grave'" % sys.argv[0])

    log()
    if fresh_install:
        log("Log out and back in to load the extension "
            "(Wayland can't restart the shell in place).")
        log("Then press %s." % shortcut)
    else:
        log("Done - press %s." % shortcut)
    log("Everything this script doesn't set (monitor choice, auto-hide, always-on-top)")
    log("is in the Extensions app, or:")
    log("    gsettings --schemadir %s list-recursively %s" % (schemas, SCHEMA_ID))


def main():
    args = parse_args()

    if not shutil.which("gnome-shell"):
        die("This needs GNOME Shell - the extension it relies on is GNOME-only.")

    if args.uninstall:
        uninstall()
        return

    install_alacritty()
    if args.theme:
        install_theme(args.theme)
    write_quake_config()
    write_desktop_file()
    fresh_install = install_extension()
    enable_extension()
    schemas = configure_extension(args.shortcut)
    whats_left_by_hand(args.shortcut, schemas, fresh_install)


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        die("Command failed (exit %d): %s" % (error.returncode, " ".join(error.cmd)))
    except KeyboardInterrupt:
        sys.exit(130)
