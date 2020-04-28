local -i force=0

local opt
while getopts 'f' opt; do
  case $opt in
    f)  force=1;;
    +f) force=0;;
    \?) return 1;;
  esac
done

if (( OPTIND <= ARGC )); then
  print -lr -- "wizard.zsh: invalid arguments: $@" >&2
  return 1
fi

(( $+terminfo[smcup] && $+terminfo[rmcup] )) && echoti smcup

local -ri force

local -r font_base_url='https://github.com/romkatv/powerlevel10k-media/raw/master'

local -ri prompt_indent=2

local -rA pure_original=(grey 242 red 1 yellow 3 blue 4 magenta 5 cyan 6 white 7)
local -rA pure_snazzy=(grey 242 red '#FF5C57' yellow '#F3F99D' blue '#57C7FF' magenta '#FF6AC1' cyan '#9AEDFE' white '#F1F1F0')
local -ra bg_color=(240 238 236 234)
local -ra sep_color=(248 246 244 242)
local -ra prefix_color=(250 248 246 244)

local -r left_circle='\uE0B6'
local -r right_circle='\uE0B4'
local -r left_arc='\uE0B7'
local -r right_arc='\uE0B5'
local -r left_triangle='\uE0B2'
local -r right_triangle='\uE0B0'
local -r left_angle='\uE0B3'
local -r right_angle='\uE0B1'
local -r fade_in='░▒▓'
local -r fade_out='▓▒░'
local -r vertical_bar='\u2502'

local -r cursor='%1{\e[07m \e[27m%}'

local -r time_24h='16:23:42'
local -r time_12h='04:23:42 PM'

local -ra lean_left=(
  '%$frame_color[$color]F╭─ ' '${extra_icons[1]:+%f$extra_icons[1] }%31F$extra_icons[2]%B%39F~%b%31F/%B%39Fsrc%b%f $prefixes[1]%76F$extra_icons[3]master%f '
  '%$frame_color[$color]F╰─' '%76F$prompt_char%f ${buffer:-$cursor}'
)

local -ra lean_right=(
  ' $prefixes[2]%101F$extra_icons[4]5s%f${time:+ $prefixes[3]%66F$extra_icons[5]$time%f}' ' %$frame_color[$color]F─╮%f'
  '' ' %$frame_color[$color]F─╯%f'
)

local -ra lean_8colors_left=(
  '%$frame_color[$color]F╭─ ' '${extra_icons[1]:+%f$extra_icons[1] }%4F$extra_icons[2]%4F~/src%f $prefixes[1]%2F$extra_icons[3]master%f '
  '%$frame_color[$color]F╰─' '%2F$prompt_char%f ${buffer:-$cursor}'
)

local -ra lean_8colors_right=(
  ' $prefixes[2]%3F$extra_icons[4]5s%f${time:+ $prefixes[3]%6F$extra_icons[5]$time%f}' ' %$frame_color[$color]F─╮%f'
  '' ' %$frame_color[$color]F─╯%f'
)

local -ra classic_left=(
  '%$frame_color[$color]F╭─' '%F{$bg_color[$color]}$left_tail%K{$bg_color[$color]} ${extra_icons[1]:+%255F$extra_icons[1] %$sep_color[$color]F$left_subsep%f }%31F$extra_icons[2]%B%39F~%b%K{$bg_color[$color]}%31F/%B%39Fsrc%b%K{$bg_color[$color]} %$sep_color[$color]F$left_subsep%f %$prefix_color[$color]F$prefixes[1]%76F$extra_icons[3]master %k%$bg_color[$color]F$left_head%f'
  '%$frame_color[$color]F╰─' '%f ${buffer:-$cursor}'
)

local -ra classic_right=(
  '%$bg_color[$color]F$right_head%K{$bg_color[$color]}%f %$prefix_color[$color]F$prefixes[2]%101F5s $extra_icons[4]${time:+%$sep_color[$color]F$right_subsep %$prefix_color[$color]F$prefixes[3]%66F$time $extra_icons[5]}%k%F{$bg_color[$color]}$right_tail%f' '%$frame_color[$color]F─╮%f'
  '' '%$frame_color[$color]F─╯%f'
)

local -ra pure_left=(
  '' '%F{$pure_color[blue]}~/src%f %F{$pure_color[grey]}master%f ${pure_use_rprompt-%F{$pure_color[yellow]\}5s%f }'
  '' '%F{$pure_color[magenta]}$prompt_char%f ${buffer:-$cursor}'
)

local -ra pure_right=(
  '${pure_use_rprompt+%F{$pure_color[yellow]\}5s%f${time:+ }}${time:+%F{$pure_color[grey]\}$time%f}' ''
  '' ''
)

local -ra rainbow_left=(
  '%$frame_color[$color]F╭─' '%F{${${extra_icons[1]:+7}:-4}}$left_tail${extra_icons[1]:+%K{7\}%232F $extra_icons[1] %K{4\}%7F$left_sep}%K{4}%254F $extra_icons[2]%B%255F~%b%K{4}%254F/%B%255Fsrc%b%K{4} %K{2}%4F$left_sep %0F$prefixes[1]$extra_icons[3]master %k%2F$left_head%f'
  '%$frame_color[$color]F╰─' '%f ${buffer:-$cursor}'
)

local -ra rainbow_right=(
  '%3F$right_head%K{3} %0F$prefixes[2]5s $extra_icons[4]%3F${time:+%7F$right_sep%K{7\} %0F$prefixes[3]$time $extra_icons[5]%7F}%k$right_tail%f' '%$frame_color[$color]F─╮%f'
  '' '%$frame_color[$color]F─╯%f'
)

function prompt_length() {
  local COLUMNS=1024
  local -i x y=$#1 m
  if (( y )); then
    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ));
    done
    local xy
    while (( y > x + 1 )); do
      m=$(( x + (y - x) / 2 ))
      typeset ${${(%):-$1%$m(l.x.y)}[-1]}=$m
    done
  fi
  REPLY=$x
}

function print_prompt() {
  local left=${style}_left
  local right=${style}_right
  left=("${(@P)left}")
  right=("${(@P)right}")
  (( disable_rprompt )) && right=()
  eval "left=(${(@)left:/(#b)(*)/\"$match[1]\"})"
  eval "right=(${(@)right:/(#b)(*)/\"$match[1]\"})"
  if (( num_lines == 1)); then
    left=($left[2] $left[4])
    right=($right[1] $right[3])
  else
    local c=76
    [[ $style == pure ]] && c=$pure_color[magenta]
    [[ $style == lean_8colors ]] && c=2
    (( left_frame )) || left=('' $left[2] '' "%F{$c}$prompt_char%f ${buffer:-$cursor}")
    (( right_frame )) || right=($right[1] '' '' '')
  fi
  local -i left_indent=prompt_indent
  local -i right_indent=prompt_indent
  prompt_length ${(g::):-$left[1]$left[2]$right[1]$right[2]}
  local -i width=REPLY
  while (( wizard_columns - width <= left_indent + right_indent )); do
    if (( right_indent )); then
      (( --right_indent ))
    elif (( left_indent )); then
      (( --left_indent ))
    else
      break  # not supposed to happen; will result in overflow if it does
    fi
  done
  local -i i
  for ((i = 1; i < $#left; i+=2)); do
    local l=${(g::):-$left[i]$left[i+1]}
    local r=${(g::):-$right[i]$right[i+1]}
    prompt_length $l$r
    local -i gap=$((wizard_columns - left_indent - right_indent - REPLY))
    (( num_lines == 2 && i == 1 )) && local fill=$gap_char || local fill=' '
    print -n  -- ${(pl:$left_indent:: :)}
    print -nP -- $l
    print -nP -- "%$frame_color[$color]F${(pl:$gap::$fill:)}%f"
    print -P  -- $r
  done
}

function href() {
  local url=${${1//\%/%%}//\\/\\\\}
  if (( _p9k_term_has_href )); then
    print -r -- '%{\e]8;;'$url'\a%}'$url'%{\e]8;;\a%}'
  else
    print -r -- $url
  fi
}

function flowing() {
  local opt
  local -i centered indentation
  while getopts 'ci:' opt; do
    case $opt in
      i)  indentation=$OPTARG;;
      c)  centered=1;;
      +c) centered=0;;
      \?) exit 1;;
    esac
  done
  shift $((OPTIND-1))
  local line word lines=()
  for word in "$@"; do
    prompt_length ${(g::):-"$line $word"}
    if (( REPLY > wizard_columns )); then
      [[ -z $line ]] || lines+=$line
      line=
    fi
    if [[ -n $line ]]; then
      line+=' '
    elif (( $#lines )); then
      line=${(pl:$indentation:: :)}
    fi
    line+=$word
  done
  [[ -z $line ]] || lines+=$line
  for line in $lines; do
    prompt_length ${(g::)line}
    (( centered && REPLY < wizard_columns )) && print -n -- ${(pl:$(((wizard_columns - REPLY) / 2)):: :)}
    print -P -- $line
  done
}

function clear() {
  if (( $+commands[clear] )); then
    command clear
  elif zmodload zsh/termcap 2>/dev/null; then
    echotc cl
  else
    print -n -- "\e[H\e[J"
  fi
}

function quit() {
  if [[ $1 == '-c' ]]; then
    print -P ""
  else
    if (( $+terminfo[smcup] && $+terminfo[rmcup] )); then
      echoti rmcup
      print
    else
      clear
    fi
  fi
  if (( force )); then
    print -P "Powerlevel10k configuration wizard has been aborted. To run it again, type:"
    print -P ""
    print -P "  %2Fp10k%f %Bconfigure%b"
    print -P ""
  else
    print -P "Powerlevel10k configuration wizard has been aborted. It will run again"
    print -P "next time unless you define at least one Powerlevel10k configuration option."
    print -P "To define an option that does nothing except for disabling Powerlevel10k"
    print -P "configuration wizard, type the following command:"
    print -P ""
    print -P "  %2Fecho%f %3F'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true'%f >>! $__p9k_zshrc_u"
    print -P ""
    print -P "To run Powerlevel10k configuration wizard right now, type:"
    print -P ""
    print -P "  %2Fp10k%f %Bconfigure%b"
    print -P ""
  fi
  exit 1
}

local -i greeting_printed=0

function print_greeting() {
  (( greeting_printed )) && return
  if (( force )); then
    flowing -c This is %4FPowerlevel10k configuration wizard%f. \
               It will ask you a few questions and configure your prompt.
  else
    flowing -c This is %4FPowerlevel10k configuration wizard%f.   \
               You are seeing it because you haven\'t defined any \
               Powerlevel10k configuration options. It will ask   \
               you a few questions and configure your prompt.
  fi
  print -P ""
}

function iterm_get() {
  /usr/libexec/PlistBuddy -c "Print :$1" ~/Library/Preferences/com.googlecode.iterm2.plist
}

local terminal iterm2_font_size iterm2_old_font=0 can_install_font=0

() {
  [[ $P9K_SSH == 0 ]] || return
  if [[ "$(uname)" == Linux && "$(uname -o)" == Android ]]; then
    (( $+commands[termux-reload-settings] )) || return
    (( $+commands[curl] )) || return
    if [[ -f ~/.termux/font.ttf ]]; then
      [[ -r ~/.termux/font.ttf ]] || return
      [[ -w ~/.termux/font.ttf ]] || return
      ! grep -q 'MesloLGS NF' ~/.termux/font.ttf 2>/dev/null || return
    fi
    if [[ -f ~/.termux ]]; then
      [[ -d ~/.termux && -w ~/.termux ]] || return
    else
      [[ -w ~ ]] || return
    fi
    terminal=Termux
    return 0
  fi
  if [[ "$(uname)" == Darwin && $TERM_PROGRAM == iTerm.app ]]; then
    (( $+commands[curl] )) || return
    [[ $TERM_PROGRAM_VERSION == [2-9]* ]] || return
    if [[ -f ~/Library/Fonts ]]; then
      [[ -d ~/Library/Fonts && -w ~/Library/Fonts ]] || return
    else
      [[ -d ~/Library && -w ~/Library ]] || return
    fi
    [[ -x /usr/libexec/PlistBuddy ]] || return
    [[ -x /usr/bin/plutil ]] || return
    [[ -x /usr/bin/defaults ]] || return
    [[ -f ~/Library/Preferences/com.googlecode.iterm2.plist ]] || return
    [[ -r ~/Library/Preferences/com.googlecode.iterm2.plist ]] || return
    [[ -w ~/Library/Preferences/com.googlecode.iterm2.plist ]] || return
    local guid1 && guid1="$(iterm_get '"Default Bookmark Guid"' 2>/dev/null)" || return
    local guid2 && guid2="$(iterm_get '"New Bookmarks":0:"Guid"' 2>/dev/null)" || return
    local font && font="$(iterm_get '"New Bookmarks":0:"Normal Font"' 2>/dev/null)" || return
    [[ $guid1 == $guid2 ]] || return
    [[ $font != 'MesloLGS-NF-Regular '<-> ]] || return
    [[ $font == (#b)*' '(<->) ]] || return
    [[ $font == 'MesloLGSNer-Regular '<-> ]] && iterm2_old_font=1
    iterm2_font_size=$match[1]
    terminal=iTerm2
    return 0
  fi
  return 1
} && can_install_font=1

function run_command() {
  local msg=$1
  shift
  [[ -n $msg ]] && print -nP -- "$msg ..."
  local err && err="$("$@" 2>&1)" || {
    print -P " %1FERROR%f"
    print -P ""
    print -nP "%BCommand:%b "
    print -r -- "${(@q)*}"
    if [[ -n $err ]]; then
      print -P ""
      print -r -- $err
    fi
    quit -c
  }
  [[ -n $msg ]] && print -P " %2FOK%f"
}

function install_font() {
  clear
  case $terminal in
    Termux)
      mkdir -p ~/.termux || quit -c
      run_command "Downloading %BMesloLGS NF Regular.ttf%b" \
        curl -fsSL -o ~/.termux/font.ttf "$font_base_url/MesloLGS%20NF%20Regular.ttf"
      run_command "Reloading %BTermux%b settings" termux-reload-settings
    ;;
    iTerm2)
      mkdir -p ~/Library/Fonts || quit -c
      local style
      for style in Regular Bold Italic 'Bold Italic'; do
        local file="MesloLGS NF ${style}.ttf"
        run_command "Downloading %B$file%b" \
          curl -fsSL -o ~/Library/Fonts/$file.tmp "$font_base_url/${file// /%20}"
        zf_mv -f -- ~/Library/Fonts/$file{.tmp,} || quit -c
      done
      print -nP -- "Changing %BiTerm2%b settings ..."
      local size=$iterm2_font_size
      [[ $size == 12 ]] && size=13
      local k t v settings=(
        '"Normal Font"'            string '"MesloLGS-NF-Regular '$size'"'
        '"Terminal Type"'          string '"xterm-256color"'
        '"Horizontal Spacing"'     real   1
        '"Vertical Spacing"'       real   1
        '"Minimum Contrast"'       real   0
        '"Use Bold Font"'          bool   1
        '"Use Bright Bold"'        bool   1
        '"Use Italic Font"'        bool   1
        '"ASCII Anti Aliased"'     bool   1
        '"Non-ASCII Anti Aliased"' bool   1
        '"Use Non-ASCII Font"'     bool   0
        '"Ambiguous Double Width"' bool   0
        '"Draw Powerline Glyphs"'  bool   1
      )
      for k t v in $settings; do
        /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:$k $v" \
          ~/Library/Preferences/com.googlecode.iterm2.plist && continue
        run_command "" /usr/libexec/PlistBuddy -c \
          "Add :\"New Bookmarks\":0:$k $t $v" ~/Library/Preferences/com.googlecode.iterm2.plist
      done
      print -P " %2FOK%f"
      print -nP "Updating %BiTerm2%b settings cache ..."
      run_command "" /usr/bin/defaults read com.googlecode.iterm2
      sleep 3
      print -P " %2FOK%f"
      clear
      flowing +c "%2FMeslo Nerd Font%f" successfully installed.
      print -P ""
      flowing +c Please "%Brestart iTerm2%b" for the changes to take effect.
      print -P ""
      while true; do
        flowing +c -i 5 "  1. Click" "%BiTerm2 → Quit iTerm2%b" or press "%B⌘ Q%b."
        flowing +c -i 5 "  2. Open %BiTerm2%b."
        print -P ""
        local key=
        read -k key${(%):-"?%BWill you restart iTerm2 before proceeding? [yN]: %b"} || quit -c
        if [[ $key = (y|Y) ]]; then
          print -P ""
          print -P ""
          exit 69
        fi
        print -P ""
        print -P ""
        flowing +c "It's" important to "%Brestart iTerm2%b" for the changes to take effect.
        print -P ""
      done
    ;;
  esac

  return 0
}

function ask_font() {
  (( can_install_font )) || return 0
  {
    while true; do
      clear
      (( greeting_printed )) || print_greeting
      if (( iterm2_old_font )); then
        flowing -c A new version of '%2FMeslo Nerd Font%f' is available. "%BInstall?"
      else
        flowing -c "%BInstall %b%2FMeslo Nerd Font%f%B?%b"
      fi
      print -P ""
      print -P ""
      print -P "%B(y)  Yes (recommended).%b"
      print -P ""
      print -P "%B(n)  No. Use the current font.%b"
      print -P ""
      print -P "(q)  Quit and do nothing."
      print -P ""

      local key=
      read -k key${(%):-"?%BChoice [ynq]: %b"} || quit -c
      case $key in
        q) quit;;
        y) ask_remove_font || return; install_font; break;;
        n) break;;
      esac
    done

    return 0
  } always {
    greeting_printed=1
  }
}

function ask_remove_font() {
  local font
  local -a fonts
  local -i protected
  for font in {,/System,~}/Library/Fonts/**/*[Mm]eslo*.(ttf|otf)(N:A); do
    [[ -f $font && -r $font ]] || continue
    [[ $font == ~/Library/Fonts/'MesloLGS NF '(Regular|Bold|Italic|Bold\ Italic).ttf ]] && continue
    [[ "$(<$font)" == *"MesloLGS NF"$'\0'* ]] || continue
    fonts+=$font
    [[ -w ${font:h} ]] || protected=1
  done
  (( $#fonts )) || return 0
  while true; do
    clear
    flowing -c "A variant of %2FMeslo Nerd Font%f" is already installed.
    print -P ""
    for font in $fonts; do
      print -P "  %B${font//\%/%%}%b"
    done
    print -P ""
    if (( protected )); then
      if (( $#fonts == 1 )); then
        flowing Please %Bdelete%b this file and run '%2Fp10k%f %Bconfigure%b.'
      else
        flowing Please %Bdelete%b these files and run '%2Fp10k%f %Bconfigure%b.'
      fi
      print
      exit 1
    fi
    if (( $#fonts == 1 )); then
      flowing -c "%BDelete this file?%b"
    else
      flowing -c "%BDelete these files?%b"
    fi
    print -P ""
    print -P "%B(y)  Yes (recommended).%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [yrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y) zf_rm -f -- $fonts || quit -c; break;;
    esac
  done

  return 0
}

function ask_diamond() {
  while true; do
    local extra=
    clear
    print_greeting
    flowing -c "%BDoes this look like a %b%2Fdiamond%f%B (rotated square)?%b"
    flowing -c "reference: $(href https://graphemica.com/%E2%97%86)"
    print -P ""
    flowing -c -- "--->  \uE0B2\uE0B0  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    if (( can_install_font )); then
      extra+=r
      print -P "(r)  Restart from the beginning."
    fi
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [yn${extra}q]: %b"} || quit -c
    case $key in
      q) quit;;
      r) [[ $extra == *r* ]] && { greeting_printed=1; return 1 };;
      y) cap_diamond=1; break;;
      n) cap_diamond=0; break;;
    esac
  done
  greeting_printed=1
  return 0
}

function ask_lock() {
  while true; do
    clear
    [[ -n $2 ]] && flowing -c "$2"
    flowing -c "%BDoes this look like a %b%2Flock%f%B?%b"
    flowing -c "reference: $(href https://fontawesome.com/icons/lock)"
    print -P ""
    flowing -c -- "--->  $1  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y) cap_lock=1; break;;
      n) cap_lock=0; break;;
    esac
  done

  return 0
}

function ask_python() {
  while true; do
    clear
    flowing -c "%BDoes this look like a %b%2FPython logo%f%B?%b"
    flowing -c "reference: $(href https://fontawesome.com/icons/python)"
    print -P ""
    flowing -c -- "--->  \uE63C  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y) cap_python=1; break;;
      n) cap_python=0; break;;
    esac
  done

  return 0
}

function ask_arrow() {
  while true; do
    clear
    flowing -c "%BDoes this look like %b%2F><%f%B but taller and fatter?%b"
    print -P ""
    flowing -c -- "--->  \u276F\u276E  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y) cap_arrow=1; break;;
      n) cap_arrow=0; break;;
    esac
  done

  return 0
}

function ask_debian() {
  while true; do
    clear
    flowing -c "%BDoes this look like a %b%2FDebian logo%f%B (swirl/spiral)?%b"
    flowing -c "reference: $(href https://debian.org/logos/openlogo-nd.svg)"
    print -P ""
    flowing -c -- "--->  \uF306  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y) cap_debian=1; break;;
      n) cap_debian=0; break;;
    esac
  done

  return 0
}

function ask_icon_padding() {
  local -i saves=5
  if [[ $POWERLEVEL9K_MODE == (powerline|compatible|ascii) ]]; then
    POWERLEVEL9K_ICON_PADDING=none
    (( saved_columns += saves ))
    return 0
  fi
  local text="X"
  text+="%1F${icons[VCS_GIT_ICON]// }%fX"
  text+="%2F${icons[VCS_GIT_GITHUB_ICON]// }%fX"
  text+="%3F${icons[TIME_ICON]// }%fX"
  text+="%4F${icons[RUBY_ICON]// }%fX"
  text+="%5F${icons[HOME_ICON]// }%fX"
  text+="%6F${icons[HOME_SUB_ICON]// }%fX"
  text+="%1F${icons[FOLDER_ICON]// }%fX"
  text+="%2F${icons[RAM_ICON]// }%fX"
  while true; do
    clear
    flowing -c "%BDo all these icons %b%2Ffit between the crosses%f%B?%b"
    print -P ""
    flowing -c -- "--->  $text  <---"
    print -P ""
    flowing +c -i 5 "%B(y)  Yes." Icons are very close to the crosses but there is "%b%2Fno overlap%f%B.%b"
    print -P ""
    print -P "%B(n)  No. Some icons %b%2Foverlap%f%B neighbouring crosses.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y)
        POWERLEVEL9K_ICON_PADDING=none
        options+='small icons'
        (( saved_columns += saves ))
        break
      ;;
      n)
        POWERLEVEL9K_ICON_PADDING=moderate
        options+='large icons'
        up_triangle+=' '
        down_triangle+=' '
        slanted_bar='\uE0BD '
        break
      ;;
    esac
  done

  return 0
}

function ask_style() {
  if (( terminfo[colors] < 256 )); then
    style=lean_8colors
    left_frame=0
    right_frame=0
    frame_color=(0 7 2 4)
    color_name=(Black White Green Blue)
    options+=lean_8colors
    (( saved_columns += 5 ))
    return 0
  fi

  if (( cap_diamond && LINES < 26 )); then
    local nl=''
  else
    local nl=$'\n'
  fi

  while true; do
    local extra=
    clear
    flowing -c "%BPrompt Style%b"
    print -n $nl
    print -P "%B(1)  Lean.%b"
    print -n $nl
    style=lean left_frame=0 right_frame=0 print_prompt
    print -P ""
    print -P "%B(2)  Classic.%b"
    print -n $nl
    style=classic print_prompt
    print -P ""
    print -P "%B(3)  Rainbow.%b"
    print -n $nl
    style=rainbow print_prompt
    print -P ""
    if [[ $POWERLEVEL9K_MODE != ascii ]]; then
      extra+=4
      print -P "%B(4)  Pure.%b"
      print -n $nl
      style=pure print_prompt
      print -P ""
    fi
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [123${extra}rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) style=lean; left_frame=0; right_frame=0; options+=lean; (( saved_columns += 5 )); break;;
      2) style=classic; options+=classic; break;;
      3) style=rainbow; options+=rainbow; break;;
      4)
        if [[ $extra == *4* ]]; then
          style=pure
          empty_line=1
          options+=pure
          (( saved_columns += 5 ))
          break
        fi
      ;;
    esac
  done

  return 0
}

function ask_charset() {
  [[ $style == (lean*|classic|rainbow) && $POWERLEVEL9K_MODE != ascii ]] || return 0

  while true; do
    clear
    flowing -c "%BCharacter Set%b"
    print -P ""
    print -P "%B(1)  Unicode.%b"
    print -P ""
    print_prompt
    print -P ""
    print -P "%B(2)  ASCII.%b"
    print -P ""
    left_sep= right_sep= left_subsep='|' right_subsep='|' left_head= \
      right_head= prompt_char='>' left_frame=0 right_frame=0 print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) options+=unicode; break;;
      2)
        left_sep=
        right_sep=
        left_subsep='|'
        right_subsep='|'
        left_head=
        right_head=
        prompt_char='>'
        left_frame=0
        right_frame=0
        POWERLEVEL9K_MODE=ascii
        POWERLEVEL9K_ICON_PADDING=none
        cap_diamond=0
        cap_python=0
        cap_debian=0
        cap_lock=0
        cap_arrow=0
        break
      ;;
    esac
  done

  return 0
}

function ask_color_scheme() {
  (( terminfo[colors] < 256 )) && return

  if [[ $style == lean ]]; then
    while true; do
      clear
      flowing -c "%BPrompt Colors%b"
      print -P ""
      print -P "%B(1)  256 colors.%b"
      print -P ""
      style=lean print_prompt
      print -P ""
      print -P "%B(2)  8 colors.%b"
      print -P ""
      style=lean_8colors print_prompt
      print -P ""
      print -P "(r)  Restart from the beginning."
      print -P "(q)  Quit and do nothing."
      print -P ""

      local key=
      read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
      case $key in
        q) quit;;
        r) return 1;;
        1) style=lean; break;;
        2)
          style=lean_8colors
          frame_color=(0 7 2 4)
          color_name=(Black White Green Blue)
          break
        ;;
      esac
    done
    options=(${options:#lean} $style)
  elif [[ $style == pure && $has_truecolor == 1 ]]; then
    while true; do
      clear
      flowing -c "%BPrompt Colors%b"
      print -P ""
      print -P "%B(1)  Original.%b"
      print -P ""
      pure_color=(${(kv)pure_original}) print_prompt
      print -P ""
      print -P "%B(2)  Snazzy.%b"
      print -P ""
      pure_color=(${(kv)pure_snazzy}) print_prompt
      print -P ""
      print -P "(r)  Restart from the beginning."
      print -P "(q)  Quit and do nothing."
      print -P ""

      local key=
      read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
      case $key in
        q) quit;;
        r) return 1;;
        1)
          pure_color=(${(kv)pure_original})
          options+=original
          break
        ;;
        2)
          pure_color=(${(kv)pure_snazzy})
          options+=snazzy
          break
        ;;
      esac
    done
  fi

  return 0
}

function ask_color() {
  [[ $style != classic ]] && return
  if [[ $LINES -lt 26 ]]; then
    local nl=''
  else
    local nl=$'\n'
  fi
  while true; do
    clear
    flowing -c "%BPrompt Color%b"
    print -n $nl
    print -P "%B(1)  $color_name[1].%b"
    print -n $nl
    color=1 print_prompt
    print -P ""
    print -P "%B(2)  $color_name[2].%b"
    print -n $nl
    color=2 print_prompt
    print -P ""
    print -P "%B(3)  $color_name[3].%b"
    print -n $nl
    color=3 print_prompt
    print -P ""
    print -P "%B(4)  $color_name[4].%b"
    print -n $nl
    color=4 print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [1234rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      [1-4]) color=$key; break;;
    esac
  done
  options+=${(L)color_name[color]}
  return 0
}

function ask_ornaments_color() {
  [[ $style != (rainbow|lean*) || $num_lines == 1 ]] && return
  [[ $gap_char == ' ' && $left_frame == 0 && $right_frame == 0 ]] && return
  if [[ $LINES -lt 26 ]]; then
    local nl=''
  else
    local nl=$'\n'
  fi
  local ornaments=()
  [[ $gap_char != ' ' ]]          && ornaments+=Connection
  (( left_frame || right_frame )) && ornaments+=Frame
  while true; do
    clear
    flowing -c "%B${(j: & :)ornaments} Color%b"
    print -n $nl
    print -P "%B(1)  $color_name[1].%b"
    print -n $nl
    color=1 print_prompt
    print -P ""
    print -P "%B(2)  $color_name[2].%b"
    print -n $nl
    color=2 print_prompt
    print -P ""
    print -P "%B(3)  $color_name[3].%b"
    print -n $nl
    color=3 print_prompt
    print -P ""
    print -P "%B(4)  $color_name[4].%b"
    print -n $nl
    color=4 print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [1234rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      [1-4]) color=$key; break;;
    esac
  done
  options+=${(L)color_name[color]}-ornaments
  return 0
}

function ask_time() {
  while true; do
    local extra=
    clear
    flowing -c "%BShow current time?%b"
    print -P ""
    print -P "%B(1)  No.%b"
    print -P ""
    time= print_prompt
    print -P ""
    print -P "%B(2)  24-hour format.%b"
    print -P ""
    time=$time_24h print_prompt
    print -P ""
    print -P "%B(3)  12-hour format.%b"
    print -P ""
    time=$time_12h print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [123rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) time=; (( saved_columns += 12 )); break;;
      2) time=$time_24h; options+='24h time'; (( saved_columns += 3 )); break;;
      3) time=$time_12h; options+='12h time'; break;;
    esac
  done

  return 0
}

function ask_use_rprompt() {
  [[ $style != pure ]] && return
  while true; do
    clear
    flowing -c "%BNon-permanent content location%b"
    print -P ""
    print -P "%B(1)  Left.%b"
    print -P ""
    print_prompt
    print -P ""
    print -P "%B(2)  Right.%b"
    print -P ""
    pure_use_rprompt= print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) break;;
      2) pure_use_rprompt=; options+=rpromt; break;;
    esac
  done

  return 0
}

function os_icon_name() {
  local uname="$(uname)"
  if [[ $uname == Linux && "$(uname -o 2>/dev/null)" == Android ]]; then
    echo ANDROID_ICON
  else
    case $uname in
      SunOS)                     echo SUNOS_ICON;;
      Darwin)                    echo APPLE_ICON;;
      CYGWIN_NT-* | MSYS_NT-*)   echo WINDOWS_ICON;;
      FreeBSD|OpenBSD|DragonFly) echo FREEBSD_ICON;;
      Linux)
        local os_release_id
        if [[ -r /etc/os-release ]]; then
          local lines=(${(f)"$(</etc/os-release)"})
          lines=(${(@M)lines:#ID=*})
          (( $#lines == 1 )) && os_release_id=${lines[1]#ID=}
        fi
        case $os_release_id in
          *arch*)                  echo LINUX_ARCH_ICON;;
          *debian*)                echo LINUX_DEBIAN_ICON;;
          *raspbian*)              echo LINUX_RASPBIAN_ICON;;
          *ubuntu*)                echo LINUX_UBUNTU_ICON;;
          *elementary*)            echo LINUX_ELEMENTARY_ICON;;
          *fedora*)                echo LINUX_FEDORA_ICON;;
          *coreos*)                echo LINUX_COREOS_ICON;;
          *gentoo*)                echo LINUX_GENTOO_ICON;;
          *mageia*)                echo LINUX_MAGEIA_ICON;;
          *centos*)                echo LINUX_CENTOS_ICON;;
          *opensuse*|*tumbleweed*) echo LINUX_OPENSUSE_ICON;;
          *sabayon*)               echo LINUX_SABAYON_ICON;;
          *slackware*)             echo LINUX_SLACKWARE_ICON;;
          *linuxmint*)             echo LINUX_MINT_ICON;;
          *alpine*)                echo LINUX_ALPINE_ICON;;
          *aosc*)                  echo LINUX_AOSC_ICON;;
          *nixos*)                 echo LINUX_NIXOS_ICON;;
          *devuan*)                echo LINUX_DEVUAN_ICON;;
          *manjaro*)               echo LINUX_MANJARO_ICON;;
          *void*)                  echo LINUX_VOID_ICON;;
          *)                       echo LINUX_ICON;;
        esac
        ;;
    esac
  fi
}

function ask_extra_icons() {
  local -i saves=12
  if [[ $style == pure || $POWERLEVEL9K_MODE == (powerline|compatible|ascii) ]]; then
    (( saved_columns += saves ))
    return 0
  fi
  if (( wizard_columns + saved_columns < 69 )); then
    prefixes=("$concise[@]")
    options+=concise
    (( saved_columns += saves ))
    return 0
  fi
  local os_icon=${(g::)icons[$(os_icon_name)]}
  local dir_icon=${(g::)icons[HOME_SUB_ICON]}
  local vcs_icon=${(g::)icons[VCS_GIT_GITHUB_ICON]}
  local branch_icon=${(g::)icons[VCS_BRANCH_ICON]}
  local duration_icon=${(g::)icons[EXECUTION_TIME_ICON]}
  local time_icon=${(g::)icons[TIME_ICON]}
  branch_icon=${branch_icon// }
  local few=('' '' '' '' '')
  local many=("$os_icon" "$dir_icon " "$vcs_icon $branch_icon " "$duration_icon " "$time_icon ")
  while true; do
    clear
    flowing -c "%BIcons%b"
    print -P ""
    print -P "%B(1)  Few icons.%b"
    print -P ""
    extra_icons=("$few[@]") print_prompt
    print -P ""
    print -P "%B(2)  Many icons.%b"
    print -P ""
    extra_icons=("$many[@]") print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) extra_icons=("$few[@]"); options+='few icons'; (( saved_columns += saves )); break;;
      2) extra_icons=("$many[@]"); options+='many icons'; break;;
    esac
  done

  return 0
}

function ask_prefixes() {
  local -i saves=11
  if [[ $style == pure ]]; then
    (( saved_columns += saves ))
    return 0
  fi
  if (( wizard_columns + saved_columns < 84 )); then
    prefixes=("$concise[@]")
    options+=concise
    (( saved_columns += saves ))
    return 0
  fi
  local concise=('' '' '')
  local fluent=('on ' 'took ' 'at ')
  while true; do
    clear
    flowing -c "%BPrompt Flow%b"
    print -P ""
    print -P "%B(1)  Concise.%b"
    print -P ""
    prefixes=("$concise[@]") print_prompt
    print -P ""
    print -P "%B(2)  Fluent.%b"
    print -P ""
    prefixes=("$fluent[@]") print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) prefixes=("$concise[@]"); options+=concise; (( saved_columns += saves )); break;;
      2) prefixes=("$fluent[@]"); options+=fluent; break;;
    esac
  done

  return 0
}

function ask_separators() {
  if [[ $style != (classic|rainbow) || $cap_diamond != 1 ]]; then
    (( saved_columns += 5 ))
    return 0
  fi
  if [[ $POWERLEVEL9K_MODE == nerdfont-complete && $LINES -lt 26 ]]; then
    local nl=''
  else
    local nl=$'\n'
  fi
  while true; do
    local extra=
    clear
    flowing -c "%BPrompt Separators%b"
    if [[ -n $nl ]]; then
      print -P "              separator"
      print -P "%B(1)  Angled.%b /"
      print -P "            /"
    else
      print -P "%B(1)  Angled.%b"
    fi
    left_sep=$right_triangle right_sep=$left_triangle left_subsep=$right_angle right_subsep=$left_angle print_prompt
    print -P ""
    print -P "%B(2)  Vertical.%b"
    print -n $nl
    left_sep='' right_sep='' left_subsep=$vertical_bar right_subsep=$vertical_bar print_prompt
    print -P ""
    if [[ $POWERLEVEL9K_MODE == nerdfont-complete ]]; then
      extra+=3
      print -P "%B(3)  Slanted.%b"
      print -n $nl
      left_sep=$down_triangle right_sep=$up_triangle left_subsep=$slanted_bar right_subsep=$slanted_bar print_prompt
      print -P ""
      extra+=4
      print -P "%B(4)  Round.%b"
      print -n $nl
      left_sep=$right_circle right_sep=$left_circle left_subsep=$right_arc right_subsep=$left_arc print_prompt
      print -P ""
    fi
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12${extra}rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1)
        left_sep=$right_triangle
        right_sep=$left_triangle
        left_subsep=$right_angle
        right_subsep=$left_angle
        options+='angled separators'
        break
        ;;
      2)
        left_sep=''
        right_sep=''
        left_subsep=$vertical_bar
        right_subsep=$vertical_bar
        options+='vertical separators'
        break
        ;;
      3)
        if [[ $extra == *3* ]]; then
          left_sep=$down_triangle
          right_sep=$up_triangle
          left_subsep=$slanted_bar
          right_subsep=$slanted_bar
          options+='slanted separators'
          break
        fi
        ;;
      4)
        if [[ $extra == *4* ]]; then
          left_sep=$right_circle
          right_sep=$left_circle
          left_subsep=$right_arc
          right_subsep=$left_arc
          options+='round separators'
          break
        fi
        ;;
    esac
  done

  prompt_length $left_sep
  (( saved_columns += (2 - REPLY) * 2 ))
  prompt_length $right_sep
  (( saved_columns += (2 - REPLY) * 1 ))
  return 0
}

function ask_heads() {
  if [[ $style != (classic|rainbow) || $POWERLEVEL9K_MODE == ascii ]]; then
    (( saved_columns += 6 ))
    return 0
  fi
  if [[ $POWERLEVEL9K_MODE == nerdfont-complete && $LINES -lt 26 ]]; then
    local nl=''
  else
    local nl=$'\n'
  fi
  while true; do
    local extra=
    clear
    if 
    flowing -c "%BPrompt Heads%b"
    if (( cap_diamond )); then
      if [[ -n $nl ]]; then
        print -P "                   head"
        print -P "%B(1)  Sharp.%b         |"
        print -P "                    v"
      else
        print -P "%B(1)  Sharp.%b"
      fi
      left_head=$right_triangle right_head=$left_triangle print_prompt
    else
      print -P ""
      print -P "%B(1)  Flat.%b"
      print -P ""
      left_head= right_head= print_prompt
    fi
    print -P ""
    print -P "%B(2)  Blurred.%b"
    print -n $nl
    left_head=$fade_out right_head=$fade_in print_prompt
    print -P ""
    if [[ $POWERLEVEL9K_MODE == nerdfont-complete ]]; then
      extra+=3
      print -P "%B(3)  Slanted.%b"
      print -n $nl
      left_head=$down_triangle right_head=$up_triangle print_prompt
      print -P ""
      extra+=4
      print -P "%B(4)  Round.%b"
      print -n $nl
      left_head=$right_circle right_head=$left_circle print_prompt
      print -P ""
    fi
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12${extra}rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1)
        if (( cap_diamond )); then
          left_head=$right_triangle
          right_head=$left_triangle
          options+='sharp heads'
        else
          left_head=
          right_head=
          options+='flat heads'
        fi
        break
      ;;
      2)
        left_head=$fade_out
        right_head=$fade_in
        options+='blurred heads'
        break
      ;;
      3)
        if [[ $extra == *3* ]]; then
          left_head=$down_triangle
          right_head=$up_triangle
          options+='slanted heads'
          break
        fi
        ;;
      4)
        if [[ $extra == *4* ]]; then
          left_head=$right_circle
          right_head=$left_circle
          options+='round heads'
          break
        fi
        ;;
    esac
  done

  prompt_length $left_head
  (( saved_columns += 3 - REPLY ))
  prompt_length $right_head
  (( saved_columns += 3 - REPLY ))
  return 0
}

function ask_tails() {
  if [[ $style != (classic|rainbow) || $POWERLEVEL9K_MODE == ascii ]]; then
    (( saved_columns += 6 ))
    return 0
  fi
  if [[ $POWERLEVEL9K_MODE == nerdfont-complete && $LINES -lt 31 ]]; then
    local nl=''
  else
    local nl=$'\n'
  fi
  while true; do
    local extra=
    clear
    flowing -c "%BPrompt Tails%b"
    print -n $nl
    print -P "%B(1)  Flat.%b"
    print -n $nl
    left_tail='' right_tail='' print_prompt
    print -P ""
    print -P "%B(2)  Blurred.%b"
    print -n $nl
    left_tail=$fade_in right_tail=$fade_out print_prompt
    print -P ""
    if (( cap_diamond )); then
      extra+=3
      print -P "%B(3)  Sharp.%b"
      print -n $nl
      left_tail=$left_triangle right_tail=$right_triangle print_prompt
      print -P ""
      if [[ $POWERLEVEL9K_MODE == nerdfont-complete ]]; then
        extra+=4
        print -P "%B(4)  Slanted.%b"
        print -n $nl
        left_tail=$up_triangle right_tail=$down_triangle print_prompt
        print -P ""
        if (( LINES >= 25 )); then
          extra+=5
          print -P "%B(5)  Round.%b"
          print -n $nl
          left_tail=$left_circle right_tail=$right_circle print_prompt
          print -P ""
        fi
      fi
    fi
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12${extra}rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) left_tail='';       right_tail='';        options+='flat tails';    break;;
      2) left_tail=$fade_in; right_tail=$fade_out; options+='blurred tails'; break;;
      3)
        if [[ $extra == *3* ]]; then
          left_tail=$left_triangle
          right_tail=$right_triangle
          options+='sharp tails'
          break
        fi
        ;;
      4)
        if [[ $extra == *4* ]]; then
          left_tail=$up_triangle
          right_tail=$down_triangle
          options+='slanted tails'
          break
        fi
        ;;
      5)
        if [[ $extra == *5* ]]; then
          left_tail=$left_circle
          right_tail=$right_circle
          options+='round tails'
          break
        fi
        ;;
    esac
  done

  prompt_length $left_tail
  (( saved_columns += 3 - REPLY ))
  prompt_length $right_tail
  (( saved_columns += 3 - REPLY ))
  return 0
}

function ask_num_lines() {
  while true; do
    clear
    flowing -c "%BPrompt Height%b"
    print -P ""
    print -P "%B(1)  One line.%b"
    print -P ""
    num_lines=1 print_prompt
    print -P ""
    print -P "%B(2)  Two lines.%b"
    print -P ""
    num_lines=2 print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) num_lines=1; options+='1 line'; break;;
      2) num_lines=2; options+='2 lines'; break;;
    esac
  done

  return 0
}

function ask_gap_char() {
  [[ $num_lines != 2 || $style == pure ]] && return
  if [[ $POWERLEVEL9K_MODE == ascii ]]; then
    local dot='.'
    local dash='-'
  else
    local dot='·'
    local dash='─'
  fi
  while true; do
    clear
    flowing -c "%BPrompt Connection%b"
    print -P ""
    print -P "%B(1)  Disconnected.%b"
    print -P ""
    gap_char=" " print_prompt
    print -P ""
    print -P "%B(2)  Dotted.%b"
    print -P ""
    gap_char=$dot print_prompt
    print -P ""
    print -P "%B(3)  Solid.%b"
    print -P ""
    gap_char=$dash print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [123rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) gap_char=" "; options+=disconnected; break;;
      2) gap_char=$dot; options+=dotted; break;;
      3) gap_char=$dash; options+=solid; break;;
    esac
  done

  return 0
}

function ask_frame() {
  if [[ $style != (classic|rainbow|lean*) || $num_lines != 2 || $POWERLEVEL9K_MODE == ascii ]]; then
    (( saved_columns += 4 ))
    return 0
  fi

  (( LINES >= 26 )) && local nl=$'\n' || local nl=''
  while true; do
    clear
    flowing -c "%BPrompt Frame%b"
    print -n $nl
    print -P "%B(1)  No frame.%b"
    print -n $nl
    left_frame=0 right_frame=0 print_prompt
    print -P ""
    print -P "%B(2)  Left.%b"
    print -n $nl
    left_frame=1 right_frame=0 print_prompt
    print -P ""
    print -P "%B(3)  Right.%b"
    print -n $nl
    left_frame=0 right_frame=1 print_prompt
    print -P ""
    print -P "%B(4)  Full.%b"
    print -n $nl
    left_frame=1 right_frame=1 print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [1234rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) left_frame=0; right_frame=0; options+='no frame';    break;;
      2) left_frame=1; right_frame=0; options+='left frame';  break;;
      3) left_frame=0; right_frame=1; options+='right frame'; break;;
      4) left_frame=1; right_frame=1; options+='full frame';  break;;
    esac
  done

  (( left_frame  )) || (( saved_columns += 2 ))
  (( right_frame )) || (( saved_columns += 2 ))
  return 0
}

function ask_empty_line() {
  while true; do
    clear
    flowing -c "%BPrompt Spacing%b"
    print -P ""
    print -P "%B(1)  Compact.%b"
    print -P ""
    print_prompt
    print_prompt
    print -P ""
    print -P "%B(2)  Sparse.%b"
    print -P ""
    print_prompt
    print -P ""
    print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) empty_line=0; options+='compact'; break;;
      2) empty_line=1; options+='sparse';  break;;
    esac
  done

  return 0
}

function ask_instant_prompt() {
  if ! is-at-least 5.4; then
    instant_prompt=off
    return 0
  fi
  if (( LINES < 24 )); then
    local nl=''
  else
    local nl=$'\n'
  fi
  while true; do
    clear
    flowing -c "%BInstant Prompt Mode%b"
    print -n $nl
    flowing -c "$(href 'https://github.com/romkatv/powerlevel10k/blob/master/README.md#instant-prompt')"
    print -P ""
    flowing +c -i 5 "%B(1)  Off.%b" Disable instant prompt. Choose this if you\'ve tried instant  \
      prompt and found it incompatible with your zsh configuration files.
    print -n $nl
    flowing +c -i 5 "%B(2)  Quiet.%b" Enable instant prompt and %Bdon\'t print warnings%b when    \
      detecting console output during zsh initialization. Choose this if you\'ve read and         \
      understood the documentation linked above.
    print -n $nl
    flowing +c -i 5 "%B(3)  Verbose.%b"  Enable instant prompt and %Bprint a warning%b when       \
      detecting console output during zsh initialization. %BChoose this if you\'ve never tried    \
      instant prompt, haven\'t seen the warning, or if you are unsure what this all means%b.
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [123rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) instant_prompt=off; options+=instant_prompt=off; break;;
      2) instant_prompt=quiet; options+=instant_prompt=quiet; break;;
      3) instant_prompt=verbose; options+=instant_prompt=verbose; break;;
    esac
  done

  return 0
}

function ask_transient_prompt() {
  local disable_rprompt=$((num_lines == 1))
  local p=76
  [[ $style == pure ]] && p=$pure_color[magenta]
  [[ $style == lean_8colors ]] && p=2
  p="%F{$p}$prompt_char%f"
  while true; do
    clear
    flowing -c "%BEnable Transient Prompt?%b"
    print -P ""
    print -P "%B(y)  Yes.%b"
    if (( LINES >= 25 || num_lines == 1 )); then
      print -P ""
      print -P "${(pl:$prompt_indent:: :)}$p %2Fgit%f pull"
    elif (( LINES < 23 )); then
      print -P ""
    else
      print -P "${(pl:$prompt_indent:: :)}$p %2Fgit%f pull"
    fi
    print -P "${(pl:$prompt_indent:: :)}$p %2Fgit%f branch x"
    (( empty_line )) && echo
    buffer="%2Fgit%f checkout x█" print_prompt
    print -P ""
    print -P "%B(n)  No.%b"
    if (( LINES >= 25 || num_lines == 1 )); then
      print -P ""
      buffer="%2Fgit%f pull" print_prompt
      (( empty_line )) && echo
    elif (( LINES < 23 )); then
      print -P ""
    else
      buffer="%2Fgit%f pull" print_prompt
      (( empty_line )) && echo
    fi
    buffer="%2Fgit%f branch x" print_prompt
    (( empty_line )) && echo
    buffer="%2Fgit%f checkout x█" print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y) transient_prompt=1; options+=transient_prompt; break;;
      n) transient_prompt=0; break;;
    esac
  done

  return 0
}

function ask_config_overwrite() {
  config_backup=
  config_backup_u=0
  if [[ ! -e $__p9k_cfg_path ]]; then
    return 0
  fi
  while true; do
    clear
    flowing -c "Powerlevel10k config file already exists."
    flowing -c "%BOverwrite" "%b%2F${__p9k_cfg_path_u//\\/\\\\}%f%B?%b"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [yrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y)
        config_backup="$(mktemp ${TMPDIR:-/tmp}/$__p9k_cfg_basename.XXXXXXXXXX)" || quit -c
        cp $__p9k_cfg_path $config_backup                                        || quit -c
        config_backup_u=${${TMPDIR:+\$TMPDIR}:-/tmp}/${(q-)config_backup:t}
        break
        ;;
    esac
  done

  return 0
}

function ask_zshrc_edit() {
  zshrc_content=
  zshrc_backup=
  zshrc_backup_u=
  zshrc_has_cfg=0
  zshrc_has_instant_prompt=0
  write_zshrc=0

  if (( $+functions[z4h] )); then
    zshrc_has_cfg=1
    zshrc_has_instant_prompt=1
  fi

  [[ $instant_prompt == off ]] && zshrc_has_instant_prompt=1

  if [[ -e $__p9k_zshrc ]]; then
    zshrc_content="$(<$__p9k_zshrc)" || quit -c
    local lines=(${(f)zshrc_content})
    local f0=$__p9k_cfg_path_o
    local f1=${(q)f0}
    local f2=${(q-)f0}
    local f3=${(qq)f0}
    local f4=${(qqq)f0}
    local g1=${${(q)__p9k_cfg_path_o}/#(#b)${(q)HOME}\//'~/'}
    local h0='${ZDOTDIR:-~}/.p10k.zsh'
    local h1='${ZDOTDIR:-$HOME}/.p10k.zsh'
    local h2='"${ZDOTDIR:-$HOME}/.p10k.zsh"'
    local h3='"${ZDOTDIR:-$HOME}"/.p10k.zsh'
    local h4='${ZDOTDIR}/.p10k.zsh'
    local h5='"${ZDOTDIR}/.p10k.zsh"'
    local h6='"${ZDOTDIR}"/.p10k.zsh'
    local h7='$ZDOTDIR/.p10k.zsh'
    local h8='"$ZDOTDIR/.p10k.zsh"'
    local h9='"$ZDOTDIR"/.p10k.zsh'
    if [[ -n ${(@M)lines:#(#b)[^#]#([^[:IDENT:]]|)source[[:space:]]##($f1|$f2|$f3|$f4|$g1|$h0|$h1|$h2|$h3|$h4|$h5|$h6|$h7|$h8|$h9)(|[[:space:]]*|'#'*)} ]]; then
      zshrc_has_cfg=1
    fi
    local pre='${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh'
    if [[ -n ${(@M)lines:#(#b)[^#]#([^[:IDENT:]]|)source[[:space:]]##($pre|\"$pre\")(|[[:space:]]*|'#'*)} ]]; then
      zshrc_has_instant_prompt=1
    fi
    (( zshrc_has_cfg && zshrc_has_instant_prompt )) && return
  fi

  while true; do
    clear
    flowing -c "%BApply changes to %b%2F${__p9k_zshrc_u//\\/\\\\}%f%B?%b"
    print -P ""
    local modifiable=y
    if [[ -e $__p9k_zshrc && ! -w $__p9k_zshrc ]]; then
      local -a stat
      zstat -A stat +uid -- $__p9k_zshrc || quit -c
      if (( stat[1] == EUID )); then
        flowing -c %3FNOTE:%f %2F${__p9k_zshrc_u//\\/\\\\}%f %3Fis readonly.%f
      else
        modifiable=
        flowing -c                                                        \
          %3FWARNING:%f %2F${__p9k_zshrc_u//\\/\\\\}%f %3Fis readonly and \
          not owned by the user. Cannot modify it.%f
      fi
      print -P ""
    fi
    if [[ $modifiable == y ]]; then
      print -P "%B(y)  Yes (recommended).%b"
    else
      print -P "%1F(y)  Yes (disabled).%f"
    fi
    print -P ""
    print -P "%B(n)  No. I know which changes to apply and will do it myself.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [${modifiable}nrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      n) return 0;;
      y)
        [[ $modifiable == y ]] || continue
        write_zshrc=1
        if [[ -n $zshrc_content ]]; then
          zshrc_backup="$(mktemp ${TMPDIR:-/tmp}/.zshrc.XXXXXXXXXX)" || quit -c
          cp -p $__p9k_zshrc $zshrc_backup                           || quit -c
          local -i writable=1
          if [[ ! -w $zshrc_backup ]]; then
            chmod u+w -- $zshrc_backup                               || quit -c
            writable=0
          fi
          print -r -- $zshrc_content >$zshrc_backup                  || quit -c
          (( writable )) || chmod u-w -- $zshrc_backup               || quit -c
          zshrc_backup_u=${${TMPDIR:+\$TMPDIR}:-/tmp}/${(q-)zshrc_backup:t}
        fi
        break
      ;;
    esac
  done

  return 0
}

function generate_config() {
  local base && base="$(<$__p9k_root_dir/config/p10k-${style//_/-}.zsh)" || return
  local lines=("${(@f)base}")

  function sub() {
    lines=("${(@)lines/#(#b)([[:space:]]#)typeset -g POWERLEVEL9K_$1=*/$match[1]typeset -g POWERLEVEL9K_$1=$2}")
  }

  function uncomment() {
    lines=("${(@)lines/#(#b)([[:space:]]#)\# $1(  |)/$match[1]$1$match[2]$match[2]}")
  }

  function rep() {
    lines=("${(@)lines//$1/$2}")
  }

  if [[ $style == pure ]]; then
    rep "local grey=242" "local grey='$pure_color[grey]'"
    rep "local red=1" "local red='$pure_color[red]'"
    rep "local yellow=3" "local yellow='$pure_color[yellow]'"
    rep "local blue=4" "local blue='$pure_color[blue]'"
    rep "local magenta=5" "local magenta='$pure_color[magenta]'"
    rep "local cyan=6" "local cyan='$pure_color[cyan]'"
    rep "local white=7" "local white='$pure_color[white]'"
  else
    sub MODE $POWERLEVEL9K_MODE

    sub ICON_PADDING $POWERLEVEL9K_ICON_PADDING

    if [[ $POWERLEVEL9K_MODE == compatible ]]; then
      sub STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION "'х'"
      sub STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION "'х'"
      sub STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION "'х'"
    fi

    if [[ $POWERLEVEL9K_MODE == (compatible|powerline) ]]; then
      uncomment 'typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION'
      sub DIR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION "'∅'"
      uncomment 'typeset -g POWERLEVEL9K_RANGER_VISUAL_IDENTIFIER_EXPANSION'
      sub RANGER_VISUAL_IDENTIFIER_EXPANSION "'▲'"
      uncomment 'typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_VISUAL_IDENTIFIER_EXPANSION'
      sub KUBECONTEXT_DEFAULT_VISUAL_IDENTIFIER_EXPANSION "'○'"
      uncomment 'typeset -g POWERLEVEL9K_AZURE_VISUAL_IDENTIFIER_EXPANSION'
      sub AZURE_VISUAL_IDENTIFIER_EXPANSION "'az'"
      uncomment 'typeset -g POWERLEVEL9K_AWS_EB_ENV_VISUAL_IDENTIFIER_EXPANSION'
      sub AWS_EB_ENV_VISUAL_IDENTIFIER_EXPANSION "'eb'"
      uncomment 'typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION'
      sub BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION "'≡'"
    fi

    if [[ $POWERLEVEL9K_MODE == (awesome-patched|awesome-fontconfig) && $cap_python == 0 ]]; then
      uncomment 'typeset -g POWERLEVEL9K_VIRTUALENV_VISUAL_IDENTIFIER_EXPANSION'
      uncomment 'typeset -g POWERLEVEL9K_ANACONDA_VISUAL_IDENTIFIER_EXPANSION'
      uncomment 'typeset -g POWERLEVEL9K_PYENV_VISUAL_IDENTIFIER_EXPANSION'
      uncomment 'typeset -g POWERLEVEL9K_PYTHON_ICON'
      sub VIRTUALENV_VISUAL_IDENTIFIER_EXPANSION "'🐍'"
      sub ANACONDA_VISUAL_IDENTIFIER_EXPANSION "'🐍'"
      sub PYENV_VISUAL_IDENTIFIER_EXPANSION "'🐍'"
      sub PYTHON_ICON "'🐍'"
    fi

    if [[ $POWERLEVEL9K_MODE == nerdfont-complete ]]; then
      sub BATTERY_STAGES "'\uf58d\uf579\uf57a\uf57b\uf57c\uf57d\uf57e\uf57f\uf580\uf581\uf578'"
    fi

    if [[ $style == (classic|rainbow) ]]; then
      if [[ $style == classic ]]; then
        sub BACKGROUND $bg_color[$color]
        sub LEFT_SUBSEGMENT_SEPARATOR "'%$sep_color[$color]F$left_subsep'"
        sub RIGHT_SUBSEGMENT_SEPARATOR "'%$sep_color[$color]F$right_subsep'"
        sub VCS_LOADING_FOREGROUND $sep_color[$color]
        rep '%248F' "%$prefix_color[$color]F"
      else
        sub LEFT_SUBSEGMENT_SEPARATOR "'$left_subsep'"
        sub RIGHT_SUBSEGMENT_SEPARATOR "'$right_subsep'"
      fi
      sub RULER_FOREGROUND $frame_color[$color]
      sub MULTILINE_FIRST_PROMPT_GAP_FOREGROUND $frame_color[$color]
      sub MULTILINE_FIRST_PROMPT_PREFIX "'%$frame_color[$color]F╭─'"
      sub MULTILINE_NEWLINE_PROMPT_PREFIX "'%$frame_color[$color]F├─'"
      sub MULTILINE_LAST_PROMPT_PREFIX "'%$frame_color[$color]F╰─'"
      sub MULTILINE_FIRST_PROMPT_SUFFIX "'%$frame_color[$color]F─╮'"
      sub MULTILINE_NEWLINE_PROMPT_SUFFIX "'%$frame_color[$color]F─┤'"
      sub MULTILINE_LAST_PROMPT_SUFFIX "'%$frame_color[$color]F─╯'"
      sub LEFT_SEGMENT_SEPARATOR "'$left_sep'"
      sub RIGHT_SEGMENT_SEPARATOR "'$right_sep'"
      sub LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL "'$left_tail'"
      sub LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL "'$left_head'"
      sub RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL "'$right_head'"
      sub RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL "'$right_tail'"
    fi

    if [[ -n ${(j::)extra_icons} ]]; then
      local branch_icon=${icons[VCS_BRANCH_ICON]// }
      sub VCS_BRANCH_ICON "'$branch_icon '"
      uncomment os_icon
    else
      uncomment 'typeset -g POWERLEVEL9K_DIR_CLASSES'
      uncomment 'typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION'
      uncomment 'typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION'
      uncomment 'typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION'
      sub VCS_VISUAL_IDENTIFIER_EXPANSION ''
      sub COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION ''
      sub TIME_VISUAL_IDENTIFIER_EXPANSION ''
    fi

    if [[ -n ${(j::)prefixes} ]]; then
      uncomment 'typeset -g POWERLEVEL9K_VCS_PREFIX'
      uncomment 'typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX'
      uncomment 'typeset -g POWERLEVEL9K_CONTEXT_PREFIX'
      uncomment 'typeset -g POWERLEVEL9K_KUBECONTEXT_PREFIX'
      uncomment 'typeset -g POWERLEVEL9K_TIME_PREFIX'
      if [[ $style == (lean|classic) ]]; then
        [[ $style == classic ]] && local fg="%$prefix_color[$color]F" || local fg="%f"
        sub VCS_PREFIX "'${fg}on '"
        sub COMMAND_EXECUTION_TIME_PREFIX "'${fg}took '"
        sub CONTEXT_PREFIX "'${fg}with '"
        sub KUBECONTEXT_PREFIX "'${fg}at '"
        sub TIME_PREFIX "'${fg}at '"
      fi
    fi

    sub MULTILINE_FIRST_PROMPT_GAP_CHAR "'$gap_char'"

    if [[ $style == (classic|rainbow) && $num_lines == 2 ]]; then
      if (( ! right_frame )); then
        sub MULTILINE_FIRST_PROMPT_SUFFIX ''
        sub MULTILINE_NEWLINE_PROMPT_SUFFIX ''
        sub MULTILINE_LAST_PROMPT_SUFFIX ''
      fi
      if (( ! left_frame )); then
        sub MULTILINE_FIRST_PROMPT_PREFIX ''
        sub MULTILINE_NEWLINE_PROMPT_PREFIX ''
        sub MULTILINE_LAST_PROMPT_PREFIX ''
        sub STATUS_OK false
        sub STATUS_ERROR false
      fi
    fi

    if [[ $style == lean* ]]; then
      sub RULER_FOREGROUND $frame_color[$color]
      sub MULTILINE_FIRST_PROMPT_GAP_FOREGROUND $frame_color[$color]
      if (( right_frame )); then
        sub MULTILINE_FIRST_PROMPT_SUFFIX "'%$frame_color[$color]F─╮'"
        sub MULTILINE_NEWLINE_PROMPT_SUFFIX "'%$frame_color[$color]F─┤'"
        sub MULTILINE_LAST_PROMPT_SUFFIX "'%$frame_color[$color]F─╯'"
        sub RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL "' '"
      fi
      if (( left_frame )); then
        sub MULTILINE_FIRST_PROMPT_PREFIX "'%$frame_color[$color]F╭─'"
        sub MULTILINE_NEWLINE_PROMPT_PREFIX "'%$frame_color[$color]F├─'"
        sub MULTILINE_LAST_PROMPT_PREFIX "'%$frame_color[$color]F╰─'"
        sub LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL "' '"
      fi
    fi

    if [[ $style == (classic|rainbow) ]]; then
      if (( num_lines == 2 && ! left_frame )); then
        uncomment prompt_char
      else
        uncomment vi_mode
      fi
    fi

    if [[ $POWERLEVEL9K_MODE == ascii ]]; then
      sub 'STATUS_OK_VISUAL_IDENTIFIER_EXPANSION' "'ok'"
      sub 'STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION' "'ok'"
      sub 'STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION' "'err'"
      sub 'STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION' ""
      sub 'STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION' "'err'"
      sub 'BATTERY_STAGES' "('battery')"
      sub 'PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION' "'>'"
      sub 'PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION' "'<'"
      sub 'PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION' "'V'"
      sub 'PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION' "'^'"
      rep "-i '⭐'" "-i '*'"
      rep '…' '..'
      rep '⇣' '<'
      rep '⇡' '>'
      rep '⇠' '<-'
      rep '⇢' '->'
      rep '─' '-'
    fi
  fi

  if (( $+pure_use_rprompt )); then
    local segment
    for segment in command_execution_time virtualenv context; do
      rep "    $segment" "    tmp_$segment"
      uncomment $segment
      rep "    tmp_$segment  " "    # $segment"
    done
  fi

  if [[ -n $time ]]; then
    uncomment time
    if [[ $time == $time_12h ]]; then
      sub TIME_FORMAT "'%D{%I:%M:%S %p}'"
    fi
  fi

  if (( num_lines == 1 )); then
    local -a tmp
    local line
    for line in "$lines[@]"; do
      [[ $line == ('    newline'*|*'===[ Line #'*) ]] || tmp+=$line
    done
    lines=("$tmp[@]")
  fi

  (( empty_line )) && sub PROMPT_ADD_NEWLINE true || sub PROMPT_ADD_NEWLINE false

  sub INSTANT_PROMPT $instant_prompt
  (( transient_prompt )) && sub TRANSIENT_PROMPT always

  local header=${(%):-"# Generated by Powerlevel10k configuration wizard on %D{%Y-%m-%d at %H:%M %Z}."}$'\n'
  header+="# Based on romkatv/powerlevel10k/config/p10k-${style//_/-}.zsh"
  if [[ $commands[sum] == ('/bin'|'/usr/bin'|'/usr/local/bin')'/sum' ]]; then
    local -a sum
    if sum=($(sum <<<${base//$'\r\n'/$'\n'} 2>/dev/null)) && (( $#sum == 2 )); then
      header+=", checksum $sum[1]"
    fi
  fi
  header+=$'.\n'
  local line="# Wizard options: $options[1]"
  local opt
  for opt in $options[2,-1]; do
    if (( $#line + $#opt > 85 )); then
      header+=$line
      header+=$',\n'
      line="# $opt"
    else
      line+=", $opt"
    fi
  done
  header+=$line
  header+=$'.\n# Type `p10k configure` to generate another config.\n#'

  if [[ -e $__p9k_cfg_path ]]; then
    unlink $__p9k_cfg_path || return
  fi
  print -lr -- "$header" "$lines[@]" >$__p9k_cfg_path
}

function change_zshrc() {
  (( write_zshrc )) || return 0

  local tmp=$__p9k_zshrc.${(%):-%n}.tmp.$$
  [[ ! -e $__p9k_zshrc ]] || cp -p $__p9k_zshrc $tmp || return

  {
    local -i writable=1
    if [[ -e $tmp && ! -w $tmp ]]; then
      chmod u+w -- $tmp || return
      writable=0
    fi

    print -n >$tmp || return

    if (( !zshrc_has_instant_prompt )); then
      >>$tmp print -r -- "# Enable Powerlevel10k instant prompt. Should stay close to the top of ${(%)__p9k_zshrc_u}.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\" ]]; then
  source \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\"
fi" || return
    fi
    if [[ -n $zshrc_content ]]; then
      (( zshrc_has_instant_prompt )) || print >>$tmp || return
      >>$tmp print -r -- $zshrc_content || return
    fi
    if (( !zshrc_has_cfg )); then
      >>$tmp print -r -- "
# To customize prompt, run \`p10k configure\` or edit ${(%)__p9k_cfg_path_u}.
[[ ! -f ${(%)__p9k_cfg_path_u} ]] || source ${(%)__p9k_cfg_path_u}" || return
    fi
    (( writable )) || chmod u-w -- $tmp || return
    zf_mv -f -- $tmp $__p9k_zshrc || return
  } always {
    zf_rm -f -- $tmp
  }

  if [[ -n $zshrc_backup_u ]]; then
    print -rP ""
    flowing +c See "%B${__p9k_zshrc_u//\\/\\\\}%b" changes:
    print -rP  "
  %2Fdiff%f %B$zshrc_backup_u%b %B$__p9k_zshrc_u%b"
  fi
  return 0
}

if (( force )); then
  _p9k_can_configure || return
else
  _p9k_can_configure -q || return
fi

zmodload zsh/terminfo                     || return
autoload -Uz is-at-least                  || return

if is-at-least 5.7.1 && [[ $COLORTERM == (24bit|truecolor) ]]; then
  local -ir has_truecolor=1
else
  local -ir has_truecolor=0
fi

while true; do
  local instant_prompt=verbose zshrc_content= zshrc_backup= zshrc_backup_u=
  local -i zshrc_has_cfg=0 zshrc_has_instant_prompt=0 write_zshrc=0
  local POWERLEVEL9K_MODE= POWERLEVEL9K_ICON_PADDING=moderate style= config_backup= config_backup_u=
  local gap_char=' ' prompt_char='❯' down_triangle='\uE0BC' up_triangle='\uE0BA' slanted_bar='\u2571'
  local left_subsep= right_subsep= left_tail= right_tail= left_head= right_head= time=
  local -i num_lines=0 empty_line=0 color=2 left_frame=1 right_frame=1 transient_prompt=0
  local -i wizard_columns=$((COLUMNS < 88 ? COLUMNS : 88)) saved_columns=0
  local -i cap_diamond=0 cap_python=0 cap_debian=0 cap_lock=0 cap_arrow=0
  local -a extra_icons=('' '' '')
  local -a frame_color=(244 242 240 238)
  local -a color_name=(Lightest Light Dark Darkest)
  local -a prefixes=('' '')
  local -a options=()
  if (( has_truecolor )); then
    local -A pure_color=(${(kv)pure_snazzy})
  else
    local -A pure_color=(${(kv)pure_original})
  fi

  unset pure_use_rprompt

  if [[ $langinfo[CODESET] == (utf|UTF)(-|)8 ]]; then
    ask_font || continue
    ask_diamond || continue
    if [[ $AWESOME_GLYPHS_LOADED == 1 ]]; then
      POWERLEVEL9K_MODE=awesome-mapped-fontconfig
    else
      ask_lock '\uF023' || continue
      if (( ! cap_lock )); then
        ask_lock '\uE138' "Let's try another one." || continue
        if (( cap_lock )); then
          if (( cap_diamond )); then
            POWERLEVEL9K_MODE=awesome-patched
            ask_python || continue
          else
            POWERLEVEL9K_MODE=flat
          fi
        else
          if (( cap_diamond )); then
            POWERLEVEL9K_MODE=powerline
          else
            ask_arrow || continue
            (( cap_arrow )) && POWERLEVEL9K_MODE=compatible || POWERLEVEL9K_MODE=ascii
          fi
        fi
      elif (( ! cap_diamond )); then
        POWERLEVEL9K_MODE=awesome-fontconfig
      else
        ask_debian || continue
        if (( cap_debian )); then
          POWERLEVEL9K_MODE=nerdfont-complete
        else
          POWERLEVEL9K_MODE=awesome-fontconfig
          ask_python || continue
        fi
      fi
    fi
  else
    POWERLEVEL9K_MODE=ascii
  fi

  if [[ $POWERLEVEL9K_MODE == powerline ]]; then
    options+=powerline
  elif (( cap_diamond )); then
    options+="$POWERLEVEL9K_MODE + powerline"
  else
    options+="$POWERLEVEL9K_MODE"
  fi
  (( cap_python )) && options[-1]+=' + python'
  if (( cap_diamond )); then
    left_sep=$right_triangle
    right_sep=$left_triangle
    left_subsep=$right_angle
    right_subsep=$left_angle
    left_head=$right_triangle
    right_head=$left_triangle
  else
    left_sep=
    right_sep=
    left_head=
    right_head=
    if [[ $POWERLEVEL9K_MODE == ascii ]]; then
      left_subsep='|'
      right_subsep='|'
      prompt_char='>'
      left_frame=0
      right_frame=0
    else
      left_subsep=$vertical_bar
      right_subsep=$vertical_bar
    fi
  fi

  _p9k_init_icons
  ask_icon_padding     || continue
  _p9k_init_icons

  ask_style            || continue
  ask_charset          || continue
  ask_color_scheme     || continue
  ask_color            || continue
  ask_use_rprompt      || continue
  ask_time             || continue
  ask_separators       || continue
  ask_heads            || continue
  ask_tails            || continue
  ask_num_lines        || continue
  ask_gap_char         || continue
  ask_frame            || continue
  ask_ornaments_color  || continue
  ask_empty_line       || continue
  ask_extra_icons      || continue
  ask_prefixes         || continue
  ask_transient_prompt || continue
  ask_instant_prompt   || continue
  ask_config_overwrite || continue
  ask_zshrc_edit       || continue
  break
done

if (( $+terminfo[smcup] && $+terminfo[rmcup] )); then
  echoti rmcup
  print
else
  clear
fi

flowing +c New config: "%B${__p9k_cfg_path_u//\\/\\\\}%b."
if [[ -n $config_backup ]]; then
  flowing +c Backup of the old config: "%B${config_backup_u//\\/\\\\}%b."
fi
if [[ -n $zshrc_backup ]]; then
  flowing +c Backup of "%B${__p9k_zshrc_u//\\/\\\\}%b:" "%B${zshrc_backup_u//\\/\\\\}%b."
fi

generate_config || return
change_zshrc    || return

print -rP ""
flowing +c File feature requests and bug reports at "$(href https://github.com/romkatv/powerlevel10k/issues)"
print -rP ""
