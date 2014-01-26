param(
    [Int32] $Year,
    [Int32] $Month
)

$ScriptPath = (Split-Path $MyInvocation.MyCommand.Definition)

. "$ScriptPath\Show-Calendar.ps1"

Show-Calendar @PSBoundParameters