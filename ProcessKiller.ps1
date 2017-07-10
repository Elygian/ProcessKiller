param(
    [string]$serviceToKill
    )

$ProcessId = get-wmiobject win32_service | where {$_.name -eq $serviceToKill} | Select-Object -expand ProcessId
Set-Service -Name $serviceToKill -StartupType Auto

Try {

    if ($ProcessId -ne 0) {
        Write-Host "Killing process: $serviceToKill"
        Stop-Process -id $ProcessId -Force

        $doLoopTimeOut = Get-Date

        Do {

            $isStopped = get-wmiobject win32_service | where {$_.name -eq $serviceToKill} | Select-Object -expand ProcessId

            if ($isStopped -eq 0) {
                Start-Service -name $serviceToKill

                Write-Host "Service starting..."
            }
        }
        While ($isStopped -eq 0 -or $doLoopTimeOut.AddSeconds(5) -gt (Get-Date))

    }

    Else {
       Write-Host "Process $serviceToKill is not running. Starting process"
       Start-Service -name $serviceToKill

       Do {

        $ifStoppedTimeOut = Get-Date

        $isStopped = get-wmiobject win32_service | where {$_.name -eq $serviceToKill} | Select-Object -expand ProcessId

        if ($isStopped -eq 0) {
            Start-Service -name $serviceToKill
            Write-Host "Service starting..."
        }
    }
    While ($isStopped -eq 0 -and $ifStoppedTimeOut.AddMinutes(1) -gt (Get-Date))
}

}

Catch {

    Write-Host "Error: Parameter passed is null, please check service name"

}