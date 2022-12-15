#System information#
$systemInfo = Get-WmiObject win32_computersystem

#OS information#
$osInfo = Get-WmiObject -Class win32_operatingsystem |
    Select-Object Name, Version

#Video card information#
$videoCardInfo = Get-WmiObject -Class win32_videocontroller |
    Select-Object Name, Description, CurrentHorizontalResolution, CurrentVerticalResolution

#RAM information#
$ramInfo = Get-WmiObject -Class win32_physicalmemory |
    Select-Object Manufacturer, Capacity, BankLabel, DeviceLocator

#Calculate total RAM#
$totalCapacity = ($ramInfo | Measure-Object -Property Capacity -Sum).Sum

#Disk information#
$diskdrives = Get-CIMInstance CIM_diskdrive

foreach ($disk in $diskdrives) {
    $partitions = $disk|get-cimassociatedinstance -resultclassname CIM_diskpartition
    foreach ($partition in $partitions) {
          $logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
          foreach ($logicaldisk in $logicaldisks) {
                   $diskInfo = new-object -typename psobject -property @{Vendor=$disk.Manufacturer
                                                                         Model=$disk.Model
                                                                         "SizeFree(GB)"=$logicaldisks.FreeSpace / 1gb -as [int]
                                                                         "SpaceFree(%)"=($logicaldisk.FreeSpace/$logicaldisk.size)*100 -as [int]
                                                                         "Size(GB)"=$logicaldisk.size / 1gb -as [int]
                                                                         }
          }
    }
}

#Network adapters#
$networkAdapterInfo = get-ciminstance win32_networkadapterconfiguration |
   Where-Object ipenabled -eq True |
   Select-Object Discription, index, IPAddress, subnetmask, dnsdomain, dnsserver

#Processor information#
$processorInfo = Get-WmiObject -Class win32_processor |
    Select-Object MaxClockSpeed, NumberOfCores, L3CacheSize

#Output all information#
$systemInfo | Format-Table
$osInfo | Format-Table
$videoCardInfo | Format-Table
$ramInfo | Format-Table
"Total RAM: $totalCapacity MB"
$diskInfo | Format-Table
$networkAdapterInfo | Format-Table
$processorInfo | Format-Table