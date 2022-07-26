
# Feel free to change these (see README), but keep in mind that changes to this file might be overwritten on update
$CoreKeeperArguments = @("-batchmode", "-logfile", "CoreKeeperServerLog.txt") + $args

$script:ckpid = $null

function Quit-CoreKeeperServer {
	if ($script:ckpid -ne $null) {
		taskkill /pid $ckpid.Id
		Wait-Process -InputObject $ckpid
		Write-Host "Stopped CoreKeeperServer.exe"
	}
}

try {
	if (Test-Path -Path "GameID.txt") {
		Remove-Item -Path "GameID.txt"
	}

	$script:ckpid = Start-Process -PassThru -FilePath %0\..\CoreKeeperServer.exe -ArgumentList $CoreKeeperArguments
	Write-Host "Started CoreKeeperServer.exe"

	# Wait for GameID
	while (!(Test-Path -Path "GameID.txt")) {
		Start-Sleep -Milliseconds 100
	}

	Write-Host -NoNewline "Game ID: "
	Get-Content "GameID.txt"
 
	Write-Host "Server is runnig. Press CTRL + C to stop."
   	While ($true) {
        if (-not (Get-Process -Id $ckpid.Id -ErrorAction SilentlyContinue)) {
        Write-Host “Server is died restarting...”
        Get-Date
        $script:ckpid = Start-Process -PassThru -FilePath %0\..\CoreKeeperServer.exe -ArgumentList $CoreKeeperArguments
        Write-Host "Started CoreKeeperServer.exe"
        Write-Host -NoNewline "Game ID: "
        Get-Content "GameID.txt"
        Write-Host "Server is runnig. Press CTRL + C to stop."
        sleep 1
        }
	}
}
finally {
	Quit-CoreKeeperServer
	pause
}
