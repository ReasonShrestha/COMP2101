function SysInfo { Write-Output "*Hardware Overview*"

get-ciminstance win32_computersystem | format-list;

Write-Output "*Operating System*"

get-ciminstance win32_operatingsystem | format-list Name,Version;

Write-Output "*Processor*"

get-ciminstance win32_processor | format-list Description,Speed,NumberofCores,L1CacheSize,L2CacheSize,L3CacheSize; 

"*RAM information*"


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

      "Total RAM: ${totalCapacity}MB
      
      "


Write-Output "*Disk Information*"

$HDDrives = Get-CIMInstance CIM_diskdrive

  foreach ($HDD in $HDDrives) {
      $partitions = $HDD|get-cimassociatedinstance -resultclassname CIM_diskpartition
      foreach ($partition in $partitions) {
            $logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
            foreach ($logicaldisk in $logicaldisks) {
                     new-object -typename psobject -property @{Manufacturer=$HDD.Manufacturer
							       Model=$HDD.Model
                                                               Location=$partition.deviceid
                                                               Drive=$logicaldisk.deviceid
                                                               "Size(GB)"=$logicaldisk.size / 1gb -as [int]
                                                               } | format-table -autosize *
           }
      }
  }

Write-Output "*Network Adapter*"

get-ciminstance win32_networkadapterconfiguration | where-object ipenabled |
	format-table -autosize Description,Index,IpAddress,IPSubnet,DNSHostName,DNSDomain

Write-Output "*Video Card*"

$GPUS = get-ciminstance win32_videocontroller
$CurrentResolution = [string]$GPUS.CurrentHorizontalResolution + "x" + $GPUS.CurrentVerticalResolution + "px"

$GPUS | format-list Name,Description
Write-Output "Current Working Resolution: $CurrentResolution"

}

SysInfo