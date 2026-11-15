#!/bin/sh
# Prints AI subscription quota used for the herdr tab bar, e.g.
#   cl 29%·3h32m 51%·3d5h  cx 28%·4h49m 36%·39m
# Providers are abbreviated (cl = claude, cx = codex). Per provider: 5h
# session window first, weekly window second, each as
# <percent used>·<time until reset>. The countdown keeps the two largest units.
# herdr shows the last output line as plain text (ANSI is stripped); empty
# output or failure hides the entry.
set -eu

# herdr runs status commands via `/bin/sh -lc`, which does not read .zshrc,
# so nvm (where quota-axi and node live) has to be loaded explicitly.
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  . "$HOME/.nvm/nvm.sh" >/dev/null
fi

# --max-age reuses a recent vendor reading instead of calling the API every run.
quota-axi --json --max-age 4m --provider claude,codex | jq -r '
  # Vendors return e.g. "...:00.400792+00:00" or "...:39.000Z"; fromdateiso8601
  # only accepts whole seconds with a Z suffix. Unparseable values yield null.
  def seconds_until_reset:
    try ((.resetsAt | sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601) - now)
    catch null;
  def countdown:
    seconds_until_reset as $s
    | if $s == null or $s <= 0 then ""
      else ($s / 60 | floor) as $m
        | if $m >= 1440 then "·\($m / 1440 | floor)d\($m % 1440 / 60 | floor)h"
          elif $m >= 60 then "·\($m / 60 | floor)h\($m % 60)m"
          else "·\($m)m" end
      end;
  def window($kind): .windows[] | select(.kind == $kind) | "\(100 - .percentRemaining)%" + countdown;
  def short_name: {"claude": "cl", "codex": "cx"}[.provider] // .provider;
  [ .providers[]
    | select(.notSetUp != true and (.windows | length) > 0)
    | "\(short_name) " + ([window("session"), window("weekly")] | join(" "))
  ] | join("  ")'
