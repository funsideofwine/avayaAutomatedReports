$date = get-date -f yyyy-MM-dd

$source = "C:\tmp\avaya\CSV"

$destination = "C:\tmp\avaya\ZIP\$date.zip"

 If(Test-path $destination) {Remove-item $destination}

Add-Type -assembly "system.io.compression.filesystem"

[io.compression.zipfile]::CreateFromDirectory($Source, $destination) 
Remove-Item "C:\tmp\avaya\CSV\*" | Where { ! $_.PSIsContainer }


