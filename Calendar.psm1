$ScriptPath = (Split-Path $MyInvocation.MyCommand.Definition)

. "$ScriptPath\Show-Calendar.ps1"

Set-Alias cal Show-Calendar

Export-ModuleMember -Alias cal
Export-ModuleMember -Function Show-Calendar