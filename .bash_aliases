alias l='ls -lFGh'
alias la='ls -alFGh'
alias ll='ls -alFh'
alias displayoff='pmset displaysleepnow' # For OSX only
alias bi='bundle install --jobs 4'

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
