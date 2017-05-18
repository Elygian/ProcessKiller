param(
    [string]$serviceToKill
    )

$ProcessId = get-wmiobject win32_service | where {$_.name -eq $serviceToKill} | Select-Object -expand ProcessId


Try {

    if ($ProcessId -ne 0) {
    Write-Host "Killing process: $serviceToKill"
        Stop-Process -id $ProcessId -Force | Wait-Process $ProcessId

        $isStopped = get-wmiobject win32_service | where {$_.name -eq $serviceToKill} | Select-Object -expand ProcessId

        if ($isStopped -eq 0) {
            Start-Service -name $serviceToKill
            Write-Host "Service starting..."
        }

    }

    Else {
           Write-Host "Process $serviceToKill is not running. Starting process"
           Start-Service -name $serviceToKill
         }

}

Catch {

    Write-Host "Error: Parameter passed is null, please check arguments"

}