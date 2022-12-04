get-ciminstance  win32_networkadapterconfiguration |
?{ $_.ipenabled -eq "True"} |
Format-table -AutoSize Description, index, IPAddress, IPSubnet, DnsDomain, DNSSErverSearchOrder