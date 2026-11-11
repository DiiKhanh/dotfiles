#!/bin/sh
# Prints AI subscription quota used for the herdr tab bar, e.g.
#   claude 5h 11% (36m) wk 44%  codex 5h 13% (1h28m) wk 29%
# The parenthesised value is the time until the 5h session window resets.
# herdr shows the last output line; empty output or failure hides the entry.
set -eu

# herdr runs status commands via `/bin/sh -lc`, which does not read .zshrc,
# so nvm (where quota-axi and node live) has to be loaded explicitly.
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  . "$HOME/.nvm/nvm.sh" >/dev/null
fi

# --max-age reuses a recent vendor reading instead of calling the API every run.
quota-axi --json --max-age 4m --provider claude,codex | jq -r '
  def window_name: if .kind == "session" then "5h" else "wk" end;
  # Vendors return e.g. "...:00.400792+00:00" or "...:39.000Z"; fromdateiso8601
  # only accepts whole seconds with a Z suffix. Unparseable values yield null.
  def seconds_until_reset:
    try ((.resetsAt | sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601) - now)
    catch null;
  def countdown:
    seconds_until_reset as $s
    | if $s == null or $s <= 0 then ""
      else ($s / 60 | floor) as $m
        | if $m >= 60 then " (\($m / 60 | floor)h\($m % 60)m)" else " (\($m)m)" end
      end;
  [ .providers[]
    | select(.notSetUp != true and (.windows | length) > 0)
    | "\(.provider) " + (
        [ .windows[]
          | select(.kind == "session" or .kind == "weekly")
          | "\(window_name) \(100 - .percentRemaining)%"
            + (if .kind == "session" then countdown else "" end) ]
        | join(" "))
  ] | join("  ")'
