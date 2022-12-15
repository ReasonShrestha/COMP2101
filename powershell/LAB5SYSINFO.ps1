$input = Read-Host -Prompt "What information do you require ?"

if ($input -eq "system") {
    Write-Output "#### System Information ####"
    Get-WmiObject win32_computersystem

    Write-Output "#### OS Information ####"
    Get-WmiObject -Class win32_operatingsystem |
        foreach {
            New-Object -TypeName psobject -Property @{
                OSName = $_.Name
                Version = $_.Version
                }
        } 
        ft -AutoSize OsName,
                     Version

    Write-Output "#### Video Card Information ####"
    Get-WmiObject -Class win32_videocontroller |
        foreach {
            New-Object -TypeName psobject -Property @{
                Vendor = $_.Name
                Description = $_.Description
                CurrentScreenResolution = ($_.CurrentHorizontalResolution) * ($_.CurrentVerticalResolution)
                
                }
        } 

    Write-Output "#### RAM Information ####"
    $totalCapacity = 0
    Get-WmiObject -Class win32_physicalmemory |
        foreach {
            New-Object -TypeName psobject -Property @{
                Vendor = $_.Manufacturer
                Model = "data unavailable"
                "Size(MB)" = $_.capacity/1mb
                Bank = $_.banklabel
                Slot = $_.devicelocator
                }
            $totalCapacity += $_.capacity/1mb
        } |
            ft -auto Vendor,
                      Model,
                     "Size(MB)",
                      Bank,
                      Slot

    "Total RAM: ${totalCapacity}MB"
}

elseif ($input -eq "disks") {
    Write-Output "#### Disk Information ####"
    $diskdrives = Get-CIMInstance CIM_diskdrive
    foreach ($disk in $diskdrives) {
        $partitions = $disk|get-cimassociatedinstance -resultclassname CIM_diskpartition
        foreach ($partition in $partitions) {
            $logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
            foreach ($logicaldisk in $logicaldisks) {
                new-object -typename psobject -property @{
                    Vendor=$disk.Manufacturer
                    Model=$disk.Model
                    "SizeFree(GB)"=$logicaldisks.FreeSpace / 1gb -as [int]
                    "SpaceFree(%)"=($logicaldisk.FreeSpace/$logicaldisk.size)*100 -as [int]
                    "Size(GB)"=$logicaldisk.size / 1gb -as [int]
                } | ft
            }
        }
    }
}

elseif ($input -eq "network") {
    Write-Output "#### Network Adapters ####"
    get-ciminstance win32_networkadapterconfiguration |
        Where-Object ipenabled -eq True |
        Select-Object Discription, index, IPAddress, subnetmask, dnsdomain, dnsserver
    ft
}
