$ScriptPath = (Split-Path $MyInvocation.MyCommand.Definition)

. "$ScriptPath\Show-Calendar.ps1"

Show-Calendar