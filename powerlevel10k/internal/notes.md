battery: use the same technique as in vpn_ip to avoid reset=2.

---

implement fake gitstatus api on top of vcs_info (or plain git?) + worker and use it if there is no
gitstatus.

---

- call vcs_info on worker. the tricky question is what to display while "loading".

---

- add _SHOW_SYSTEM to all *env segments.

---

- support states in SHOW_ON_COMMAND: POWERLEVEL9K_SEGMENT_STATE_SHOW_ON_COMMAND='...'

---

add POWERLEVEL9K_${SEGMENT}_${STATE}_SHOW_IN_DIR='pwd_pattern'; implement the same way as
SHOW_ON_UPGLOB. how should it interact with POWERLEVEL9K_${SEGMENT}_DISABLED_DIR_PATTERN?

---

add `p10k upglob`; returns 0 on match and sets REPLY to the directory where match was found.

---

when directory cannot be shortened any further, start chopping off segments from the left and
replacing the chopped off part with `…`. e.g., `…/x/anchor/y/anchor`. the shortest dir
representation is thus `…/last` or `…/last` depending on whether the last segment is an anchor.
the replacement parameter's value is `…/` (with a slash) to allow for `x/anchor/y/anchor`.

---

- add to faq: how do i display an environment variable in prompt? link it from "extensible"

---

- add to faq: how do i display an icon in prompt? link it from "extensible"

---

- add root_indicator to config templates

---

- test chruby and add it to config templates

---

- add ssh to config templates

---

- add swift version to config templates; see if there is a good pattern for PROJECT_ONLY

---

- add swiftenv

---

- add faq: how to customize directory shortening? mention POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER,
POWERLEVEL9K_DIR_MAX_LENGTH and co., and truncate_to_last.

---

fix a bug in zsh: https://github.com/romkatv/powerlevel10k/issues/502. to reproduce:

```zsh
emulate zsh -o prompt_percent -c 'print -P "%F{#ff0000}red%F{green}%B bold green"'
```

---

bug: open a new tab and hit ctrl-p. an empty line will appear before prompt.

---

take a look at https://github.com/skywind3000/z.lua. it claims to have fzf support. would be nice
if alt-down showed two groups -- one for subdirs and another for directory history (sorted by
frequency of use? by last use? three sections? more key bindings?).

---

add `p10k explain` that prints something like this:

```text
segment     icons meaning

---

---

---

---

---

---

---

---
--
status      ✔  ✘  exit code of the last command
```

implement it the hard way: for every enabled segment go over all its {state,icon} pairs, resolve
the icon (if not absolute), apply VISUAL_IDENTIFIER_EXPANSION, remove leading and trailing
whitespace and print without formatting (sort of like `print -P | cat`); print segment names in
green and icons in bold; battery can have an unlimited number of icons, so `...` would be needed
(based on total length of concatenated icons rather than the number of icons); user-defined
segments would have "unknown" icons by default (yellow and not bold); can allow them to
participate by defining `explainprompt_foo` that populates array `reply` with strings like this:
'-s STATE -i LOCK_ICON +r'; the first element must be segment description.

---

add `docker_context` prompt segment; similar to `kubecontext`; the data should come from
`currentContext` field in `~/.docker/config.json` (according to
https://github.com/starship/starship/issues/995); there is also `DOCKER_CONTEXT`; more info:
https://docs.docker.com/engine/reference/commandline/context_use; also
https://github.com/starship/starship/pull/996.

---

support `env` precommand in parser.zsh.

---

Add ruler to configuration wizard. Options: `─`, `·`, `╌`, `┄`, `▁`, `═`.

---

Add frame styles to the wizard.

```text
╭─
╰─

┌─
└─

┏━
┗━

╔═
╚═

▛▀
▙▄
```

Prompt connection should have matching options.

---

Add `POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_MIRROR_SEPARATOR`. If set, left segments get separated with
`POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR` followed by `POWERLEVEL9K_LEFT_SEGMENT_MIRROR_SEPARATOR`.
Each is drawn without background. The first with the foreground of left segment, the second with
the background of right segment. To insert space in between, embed it in one of these parameters.
`POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR` is unused.

---

Add *Segment Connection* screen to configuration wizard with options *Fused*, *Touching* and
*Disjoint*. The last two differ by the absence/presence of space between `SEGMENT_SEPARATOR` and
`SEGMENT_MIRROR_SEPARATOR`.

*Fused* requires line separator (there is already a screen for it) but the other two options require
two filled separators similar to heads and tail. Figure out how to present this choice.

---

Get rid of `saved_columns` in the wizard and always present all options as if horizontal space was
unlimited. `print_prompt` should print something like this if prompt is too wide:

  Terminal window too narrow to display prompt.
  Make it wider and press ENTER to refresh.

Terminal dimensions will need to be checked more often.

Try getting rid of the "press ENTER" requirement by trapping `SIGWINCH`. Might need to run `read -k`
with timeout in a loop.

Print all text with a helper function that keeps track of the number of lines remaining on screen.
`print_prompt` will then be able to show a similar message for Terminal window being too short. This
makes sense only for two-line prompts. This is probably OK.

If `print_prompt` can be told in advance how many prompts we are going to display, it might be able
to insert or avoid inserting `\n` in between, depending on terminal height. There is one screen
where one prompt is a one-liner while another is a two-liner. This is fine because there are only
two options. `print_prompt` can assume that all options will use the current prompt height.

Don't use `print_prompt` directly. Create `ask_prompt` and use it like this:

```zsh
ask_prompt \
  1 "No frame"   "left_frame=0 right_frame=0" \
  2 "Left frame" "left_frame=1 right_frame=0" \
  ...
```

There are two prompt questions that don't fit this pattern: `ask_empty_line` and
`ask_transient_prompt`. The first is easy to adapt (`print_prompt` can print prompt twice if
`empty_line=1`) but the second will probably have to be hand-coded.

---

Revert `3ef4e68b5fdae654f323af644cbca40f27a8ab97`. Instead of it use `zf_rm -f -- $dst` before
`zf_mv -f -- $src $dst`. `zwc` files are readonly and `zf_mv` fails on NTFS if the target file
exists and is readonly.

---

Optimize auto-wizard check.

```text
time ( repeat 1000 [[ -z "${parameters[(I)POWERLEVEL9K_*~(POWERLEVEL9K_MODE|POWERLEVEL9K_CONFIG_FILE)]}" ]] )
user=0.21s system=0.05s cpu=99% total=0.264

time ( repeat 1000 [[ -z "${parameters[(I)POWERLEVEL9K_*]}" ]] )
user=0.17s system=0.00s cpu=99% total=0.175
```
