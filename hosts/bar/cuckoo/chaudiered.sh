#! /usr/bin/env bash

set -xeuo pipefail

now="$(@coreutils@/bin/date --iso=seconds)"
nowFormatted="$(@coreutils@/bin/date +"on %F, at %T")"

doNotify() {
  @curl@/bin/curl -i -X POST -H 'Content-Type: application/json' -d '{"text": "'"The boiler broke down ${nowFormatted} :/"'"}' "${MATTERMOST_WEBHOOK}"
}

imageFilename="chaudiered-${now}.jpg"
imageFile="@htmlDir@/${imageFilename}"

smileys=( ":/" ":D" )
messages=( "The fucking boiler is broken, again..." "The boiler is working properly." )
backgroundColors=( "FCC" "CCF" )

isWorking=0

@fswebcam@/bin/fswebcam -d /dev/video0 --save "${imageFile}"

luminosity="$(@imagemagick@/bin/identify -format %[mean] "${imageFile}" | @coreutils@/bin/cut -d'.' -f1)"

if [[ "${luminosity}" > 6300 ]]; then
  isWorking=1
else
  isWorking=0
fi

cat <<EOF > "@htmlDir@/metrics"
chaudiered_status ${isWorking}
chaudiered_luminosity ${luminosity}
EOF

cat <<EOF > "@htmlDir@/index.html"
<!DOCTYPE html>
<html lang='en'>
<head>
  <meta http-equiv="content-type" content="text/html; charset=UTF-8">
  <title>systemd-chaudiered</title>

  <style>
    body {
      background-color: #${backgroundColors[${isWorking}]};
    }

    .small {
      color: #4F4F4F;
    }
    .medium {
      font-size: 50px;
    }
    .big {
      font-size: 100px;
    }

    body > div {
      margin-left: -50px;
      padding-left: 50%;
    }
  </style>
</head>

<body>
  <div>
    <p class="big">${smileys[${isWorking}]}</p>
    <p class="medium">${messages[${isWorking}]}</p>
    <p class="small">Last update ${nowFormatted}</p>
    <img src="/${imageFilename}" />
  </div>
</body>
</html>
EOF

if [[ "${isWorking}" == 0 ]]; then
  doNotify
fi
