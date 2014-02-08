
$commands = @(
    'Show-Calendar'
    'Show-Calendar 2014 12'
    'Show-Calendar 2014'
    'Show-Calendar -Month 12'
    'Show-Calendar -Context 3'
    'Show-Calendar (Get-Date).AddMonths(3)'
    'Get-Date | Show-Calendar'
    '1..5 | %{ Get-Date -Year 2014 -Month ($_ * 2) } | Show-Calendar'
    '7..22 | %{ Get-Date -Year 2014 -Month 2 -Day $_ } | Show-Calendar'
)

foreach ($command in $commands) {
    Write-Host "PS>$command"
    Invoke-Expression $command
}