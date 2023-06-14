$perm =  Get-ItemProperty -path HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell\
$perm
if($perm.ExecutionPolicy -notmatch "Bypass"){
write-host("pas bon")
}else{
write-host("bon")
}
