$directory = "C:\Users\gunsa\Desktop\cle.pem"
$acl = Get-Acl $directory
$acl.SetAccessRuleProtection($true,$false)
#Droit Lecture Uniquement sur Administrateurs
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("gunsa","Read","Allow")
$acl.SetAccessRule($AccessRule)
$acl |Set-Acl