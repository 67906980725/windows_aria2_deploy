if (!$GITHUB_PROXY) { $GITHUB_PROXY = "https://cors.isteed.cc/" }
$DOWN_PATH = "${home}\Downloads"

function update_bt_tracker {
  "开始更新 bt tracker"
  $log_file = "$PSScriptRoot/update_bt_tracker_time.log"
  if (Test-Path -Path $log_file) {
    $update_time = Get-Content $log_file | Get-Date
    if (($(Get-Date) - $update_time).Days -lt 1) {
      "距上次更新不足一天, 返回"
      return
    }
  }

  Invoke-WebRequest "${GITHUB_PROXY}https://github.com/ngosang/trackerslist/archive/refs/heads/master.zip" -OutFile $DOWN_PATH\trackerslist.zip
  Expand-Archive -Force -Path $DOWN_PATH\trackerslist.zip -DestinationPath $DOWN_PATH
  Remove-Item $DOWN_PATH\trackerslist.zip

  # $u = "trackers_best.txt"
  $u = "trackers_all.txt"
  $tks = (Get-Content "$DOWN_PATH\trackerslist-master\$u") | Where-Object { $_ -match '\S' }
  $tks = $tks -join ","
  (Get-Content "$PSScriptRoot\aria2.conf") | Foreach-Object { $_ -replace '^bt-tracker=.*', "bt-tracker=$tks" } | Set-Content "$PSScriptRoot\aria2.conf"
  Get-Date | Out-File $log_file -NoNewline
  Remove-Item $DOWN_PATH\trackerslist-master -Recurse -Force
  "结束更新"
}

update_bt_tracker