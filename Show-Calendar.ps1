
$firstDayOffsets = @( 6, 0, 1, 2, 3, 4, 5 )
$dayNames = [Globalization.CultureInfo]::CurrentCulture.DateTimeFormat.ShortestDayNames
$monthNames = [Globalization.CultureInfo]::CurrentCulture.DateTimeFormat.MonthNames
$calendar = [Globalization.CultureInfo]::CurrentCulture.Calendar
$monthWidth = 23
$monthSpacingLength = 5
$monthSpacing = ' ' * $monthSpacingLength

function Get-StartOfFirstWeek($month, $year) {
    $startDate = New-Object DateTime($year, $month, 1)
    $firstDayOffset = $firstDayOffsets[$startDate.DayOfWeek]
    $startDate = $startDate.AddDays(-$firstDayOffset)
    return $startDate
}

function New-MonthState($month, $year) {
    $startDate = Get-StartOfFirstWeek $month $year

    $state = New-Object PSObject
    $state | Add-Member NoteProperty MonthNumber $month
    $state | Add-Member NoteProperty YearNumber $year
    $state | Add-Member NoteProperty NextWeekStartDate $startDate
    $state | Add-Member NoteProperty IsFinished $false
    return $state
}

function Center-String($str, $totalWidth) {
    if ($str.Length -lt $totalWidth) {
        $leftPadding = ($totalWidth - $str.Length) / 2
        $str = $str.PadRight($totalWidth - $leftPadding)
        $str = $str.PadLeft($totalWidth)
    }

    return $str
}

function Get-CursorPosition {
    return $Host.UI.RawUI.CursorPosition
}

function Set-CursorPosition($x, $y) {
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 2, 5
}

function Get-MonthName($monthNumber) {
    return $monthNames[$monthNumber - 1]
}

function Get-CenteredMonthName($month, $year) {
    return Center-String (Get-MonthName $month $year) $monthWidth
}

function Get-WeekOfYear($date) {
    return $calendar.GetWeekOfYear($date, [Globalization.CalendarWeekRule]::FirstFourDayWeek, [DayOfWeek]::Monday)
}

function Write-MonthName($month, $year) {
    $title = '{0} {1}' -f (Get-MonthName $month), $year
    $text = Center-String $title $monthWidth
    Write-Host $text -ForegroundColor Yellow -NoNewLine
}

function Write-DayNames {
    Write-Host ('{1,2} {2,2} {3,2} {4,2} {5,2} {6,2} {0,2}' -f $dayNames) -NoNewLine -ForegroundColor DarkYellow
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

function Write-WeekNumber($weekStartDate) {
    $weekNumber = Get-WeekOfYear $weekStartDate
    Write-Host ('{0,2} ' -f $weekNumber) -NoNewLine -ForegroundColor DarkYellow
}

function Write-Week($weekStartDate, $month, $currentDate) {
    $dayDate = $weekStartDate

    Write-WeekNumber $weekStartDate.AddDays(6)

    for ($i = 0; $i -lt 7; $i++) {
        Write-Day $dayDate $month $currentDate

        if ($i -lt 6) {
            Write-Host ' ' -NoNewLine
        }

        $dayDate = $dayDate.AddDays(1)
    }
}

function Show-Month($month, $year, $currentDate) {
    $startDate = New-Object DateTime($year, $month, 1)
    $firstDayOffset = $firstDayOffsets[$startDate.DayOfWeek]
    $startDate = $startDate.AddDays(-$firstDayOffset)

    Write-MonthName $month $year
    Write-DayNames
    do {
        Write-Week $startDate $month $currentDate
        $startDate = $startDate.AddDays(7)
    }
    while ($startDate.Month -eq $month)
}

function Write-Spacing {
    Write-Host $monthSpacing -NoNewLine
}

function Write-MonthNames($months) {
    foreach ($month in $months) {
        Write-MonthName $month.MonthNumber $month.YearNumber
        Write-Spacing
    }
}

function Write-WeekNumberPadding {
    Write-Host '   ' -NoNewLine
}

function Write-DayHeaders($monthCount) {
    for ($i = 0; $i -lt $monthCount; $i++) {
        Write-WeekNumberPadding
        Write-DayNames
        Write-Spacing
    }
}

function Write-NextMonthLine($month, $currentDate) {
    if ($month.IsFinished) {
        Write-Host (' ' * $monthWidth) -NoNewLine
        return
    }

    $startDate = $month.NextWeekStartDate
    Write-Week $startDate $month.MonthNumber $currentDate

    $month.NextWeekStartDate = $month.NextWeekStartDate.AddDays(7)
    if ($month.NextWeekStartDate.Month -ne $month.MonthNumber) {
        $month.IsFinished = $true
    }
}

function Create-RowState($startMonth, $startYear, $monthCount) {
    $months = @()
    $firstDayOfMonth = New-Object DateTime($startYear, $startMonth, 1)

    for ($i = 0; $i -lt $monthCount; $i++) {
        $months += @( New-MonthState $firstDayOfMonth.Month $firstDayOfMonth.Year )  
        $firstDayOfMonth = $firstDayOfMonth.AddMonths(1)
    }

    return $months
}

function Show-Months($startMonth, $startYear, $monthCount, $monthsPerRow, $currentDate) {
    $monthsLeft = $monthCount
    $rowStartDate = New-Object DateTime($startYear, $startMonth, 1)

    while ($monthsLeft -gt 0) {
        $monthsInRow = [Math]::Min($monthsLeft, $monthsPerRow)
        $months = @( Create-RowState $rowStartDate.Month $rowStartDate.Year $monthsInRow )

        Write-MonthNames $months
        Write-Host
        Write-DayHeaders $months.Count
        Write-Host

        $allMonthsFinished = $false

        while (-not $allMonthsFinished) {
            $allMonthsFinished = $true

            foreach ($month in $months) {
                Write-NextMonthLine $month $now
                Write-Spacing

                $allMonthsFinished = $allMonthsFinished -and $month.IsFinished
            }

            Write-Host
        }

        $rowStartDate = $rowStartDate.AddMonths($monthsInRow)
        $monthsLeft -= $monthsInRow

        if ($monthsLeft -gt 0) {
            Write-Host
        }
    }
}

function Show-Calendar {
    param(
        [Parameter(ParameterSetName = "YearMonth", Position = 0)]
        [ValidateRange(1, 9999)]
        [Int32] $Year = $null,

        [Parameter(ParameterSetName = "YearMonth", Position = 1)]
        [ValidateRange(1, 12)]
        [Int32] $Month = $null,

        [Parameter(ParameterSetName = "Date", Position = 0, ValueFromPipeline = $true)]
        [DateTime] $Date = $null,

        [switch] $Three
    )

    $now = [DateTime]::Today
    $monthCount = 1

    if ($PsCmdlet.ParameterSetName -eq "Date") {
        $Year = $Date.Year
        $Month = $Date.Month
    }
    elseif ($Year -and !$Month) {
        $Month = 1
        $monthCount = 12
    }
    else {
        if (!$Year) {
            $Year = $now.Year
        }
        if (!$Month) {
            $Month = $now.Month
        }
    }

    $startDate = New-Object DateTime($Year, $Month, 1)

    if ($Three -and ($monthCount -eq 1)) {
        $startDate = $startDate.AddMonths(-1)
        $monthCount = 3
    }

    Show-Months $startDate.Month $startDate.Year $monthCount 3 $now
}