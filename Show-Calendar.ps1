
$firstDayOffsets = @( 6, 0, 1, 2, 3, 4, 5 )
$dayNames = [Globalization.CultureInfo]::CurrentCulture.DateTimeFormat.ShortestDayNames

function Write-DayNames($NoNewLine = $false) {
    Write-Host ('{1,2} {2,2} {3,2} {4,2} {5,2} {6,2} {0,2}' -f $dayNames) -NoNewLine:$NoNewLine
}

function Write-Day($dayDate, $month, $currentDate) {
    $color = [ConsoleColor]::White

    if ($dayDate.Month -ne $month) {
        $color = [ConsoleColor]::DarkGray
    }
    elseif ($dayDate.DayOfWeek -eq [DayOfWeek]::Saturday) {
        $color = [ConsoleColor]::Blue
    }
    elseif ($dayDate.DayOfWeek -eq [DayOfWeek]::Sunday) {
        $color = [ConsoleColor]::Red
    }

    if ($dayDate -eq $currentDate) {
        $foregroundColor = [ConsoleColor]::Black
        $backgroundColor = $color
    }
    else {
        $foregroundColor = $color
        $backgroundColor = [ConsoleColor]::Black
    }

    Write-Host ('{0,2}' -f $dayDate.Day) -NoNewLine -ForegroundColor:$foregroundColor -BackgroundColor:$backgroundColor
}

function Write-Week($weekStartDate, $month, $currentDate) {
    $dayDate = $weekStartDate

    for ($i = 0; $i -lt 7; $i++) {
        Write-Day $dayDate $month $currentDate
        Write-Host ' ' -NoNewLine
        $dayDate = $dayDate.AddDays(1)
    }

    Write-Host
}

function Show-Month($month, $year, $currentDate) {
    $startDate = New-Object DateTime($year, $month, 1)
    $firstDayOffset = $firstDayOffsets[$startDate.DayOfWeek]
    $startDate = $startDate.AddDays(-$firstDayOffset)

    Write-DayNames
    do {
        Write-Week $startDate $month $currentDate
        $startDate = $startDate.AddDays(7)
    }
    while ($startDate.Month -eq $month)
}

function Show-Calendar {
    $now = [DateTime]::Today

    Show-Month $now.Month $now.Year $now
}