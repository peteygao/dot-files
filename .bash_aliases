# Terminal navigation aliases
alias l='ls -lFGh'
alias la='ls -alFGh'
alias ll='ls -alFh'

# Handy aliases
alias bi='bundle install --jobs 4'
alias clip='kitty +kitten clipboard'
alias compact-memory='echo 1 | sudo tee -a /proc/sys/vm/compact_memory > /dev/null'
alias cpu='cat /proc/cpuinfo | grep "cpu MHz"'
alias displayoff='pmset displaysleepnow' # For OSX only
alias gdiff='kitty +kitten diff'
alias mongodb='docker run -d -p 27017:27017 -v ~/.mongodb/data:/data/db mongo'
alias temps="paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'"

function rgrep {
  grep -Irn --color "$@" .
}

function wsize {
  if command -v wget >/dev/null 2>&1; then
    wget -O /dev/null -S --spider $@ 2>&1 | grep ^Length:
  else
    echo $(curl -Is $@ | grep Content-Length | cut -d" " -f2 | tr -d "[:cntrl:]") | humanreadable
  fi
}

function humanreadable {
  awk 'function human(x) {
         s=" B   KiB MiB GiB TiB EiB PiB YiB ZiB"
         while (x>=1024 && length(s)>1)
               {x/=1024; s=substr(s,5)}
         s=substr(s,1,4)
         xf=(s==" B  ")?"%5d   ":"%8.2f"
         return sprintf( xf"%s\n", x, s)
      }
      {gsub(/^[0-9]+/, human($1)); print}'
}
