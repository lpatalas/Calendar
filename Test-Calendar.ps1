
$commands = @(
    'Show-Calendar'
    'Show-Calendar 2014 12'
    'Show-Calendar 2014'
    'Show-Calendar -Month 12'
    'Show-Calendar -Context 3'
    'Show-Calendar (Get-Date).AddMonths(3)'
    'Get-Date | Show-Calendar'
)

foreach ($command in $commands) {
    Write-Host "PS>$command"
    Invoke-Expression $command
}