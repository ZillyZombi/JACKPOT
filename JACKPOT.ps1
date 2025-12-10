# PowerShell Casino v2.0 - ASCII GUI
# Enhanced visual experience with animated slot machine

$global:balance = 100
$host.UI.RawUI.WindowTitle = "PowerHell Casino"

function Show-Title {
    Clear-Host
    Write-Host @"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║  ____   ____   ____  ______ ______ _   __ ___________      ║
║ |    \ |    | |    ||      |      | | /  |        |      ║
║ |  o  ) |  |  |  | |      |      | |/   |  _____|      ║
║ |     | |  |  |  |_| |_|  |_|  ___|   _  |_|  |         ║
║ |  O  | |  |  |  | | |  |_| |   | |  | |   |_|         ║
║ |_____| |____| |__| |______|_|   | |__| |  |_______|     ║
║                                                            ║
║                  SLOT MACHINE                              ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Yellow
}

function Show-MainMenu {
    Show-Title
    Write-Host @"

╔════════════════════════════════════════════════════════════╗
║                     MAIN MENU                              ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  Balance:  [ $("$" + $global:balance) ]                           ║
║                                                            ║
║  [1] Play Slot Machine                                 ║
║  [2] View Balance                                      ║
║  [3] Add Credits                                       ║
║  [4] Exit Casino                                       ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
"@
    Write-Host ""
    $choice = Read-Host "  Select an option [1-4] "
    return $choice
}

function Animate-Reel {
    param($x, $y)
    $symbols = @("🍒", "🍋", "⭐", "💎", "7️⃣", "🎲", "🔔")
    $cursor = $Host.UI.RawUI.CursorPosition
    
    for ($i = 0; $i -lt 10; $i++) {
        $cursor.X = $x
        $cursor.Y = $y
        $Host.UI.RawUI.CursorPosition = $cursor
        Write-Host ($symbols | Get-Random) -NoNewline -ForegroundColor Green
        Start-Sleep -Milliseconds 80
    }
}

function Start-SlotMachine {
    Show-Title
    Write-Host @"

╔════════════════════════════════════════════════════════════╗
║                    SLOT MACHINE                            ║
╠════════════════════════════════════════════════════════════╣
║  Payouts:                                                  ║
║    3x Seven (7️⃣)  = 50x  |  2x Seven  = 10x              ║
║    3x Diamond (💎) = 20x  |  2x Diamond = 5x              ║
║    3x Star (⭐)    = 15x  |  2x Star    = 3x              ║
║    3x Bell (🔔)    = 10x  |  2x Bell    = 2x              ║
║    3x Lemon (🍋)   = 8x   |  2x Lemon   = 1x              ║
║    3x Cherry (🍒)  = 5x   |  2x Cherry  = 1x              ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    if ($global:balance -le 0) {
        Write-Host "`nInsufficient balance! Add credits first." -ForegroundColor Red
        Start-Sleep -Seconds 2
        return
    }

    # Get bet
    while ($true) {
        $bet = Read-Host "`nEnter bet amount (1-$global:balance) or 0 to exit"
        if ($bet -eq "0") { return }
        if ($bet -match '^\d+$' -and [int]$bet -le $global:balance -and [int]$bet -gt 0) {
            $bet = [int]$bet
            break
        }
        Write-Host "Invalid bet!" -ForegroundColor Red
    }

    $global:balance -= $bet

    # Draw machine frame
    Show-Title
    Write-Host @"

╔════════════════════════════════════════════════════════════╗
║                    SLOT MACHINE                            ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║      ╔───────╗   ╔───────╗   ╔───────╗                    ║
║      ║       ║   ║       ║   ║       ║                    ║
║      ║   R1  ║   ║   R2  ║   ║   R3  ║                    ║
║      ║       ║   ║       ║   ║       ║                    ║
║      ╚───────╝   ╚───────╝   ╚───────╝                    ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Yellow

    # Hide cursor for animation
    $cursorVisible = $Host.UI.RawUI.CursorSize
    $Host.UI.RawUI.CursorSize = 0

    # Animate reels
    Animate-Reel 26 11  # Reel 1
    Animate-Reel 34 11  # Reel 2
    Animate-Reel 42 11  # Reel 3

    # Final symbols
    $symbols = @("🍒", "🍋", "⭐", "💎", "7️⃣", "🎲", "🔔")
    $reel1 = $symbols | Get-Random
    $reel2 = $symbols | Get-Random
    $reel3 = $symbols | Get-Random

    # Display final result
    $cursor = $Host.UI.RawUI.CursorPosition
    $cursor.X = 26; $cursor.Y = 11; $Host.UI.RawUI.CursorPosition = $cursor; Write-Host $reel1 -ForegroundColor White
    $cursor.X = 34; $cursor.Y = 11; $Host.UI.RawUI.CursorPosition = $cursor; Write-Host $reel2 -ForegroundColor White
    $cursor.X = 42; $cursor.Y = 11; $Host.UI.RawUI.CursorPosition = $cursor; Write-Host $reel3 -ForegroundColor White

    $Host.UI.RawUI.CursorSize = $cursorVisible

    # Calculate winnings
    $winnings = 0
    $multipliers = @{
        "🍒" = 5; "🍋" = 8; "⭐" = 15; "💎" = 20; "7️⃣" = 50; "🎲" = 12; "🔔" = 10
    }

    Start-Sleep -Milliseconds 500

    if ($reel1 -eq $reel2 -and $reel2 -eq $reel3) {
        $winnings = $bet * $multipliers[$reel1]
        Write-Host "`nJACKPOT! 3x $reel1!" -ForegroundColor Yellow
        Write-Host "You won `$$winnings!" -ForegroundColor Green
    } elseif ($reel1 -eq $reel2 -or $reel2 -eq $reel3 -or $reel1 -eq $reel3) {
        $symbol = if ($reel1 -eq $reel2 -or $reel1 -eq $reel3) { $reel1 } else { $reel2 }
        $winnings = [math]::Floor($bet * $multipliers[$symbol] / 2)
        Write-Host "`nWIN! 2x matching symbols!" -ForegroundColor Cyan
        Write-Host "You won `$$winnings!" -ForegroundColor Green
    } else {
        Write-Host "`nNo match. Better luck next time!" -ForegroundColor Red
    }

    $global:balance += $winnings
    
    Write-Host "`nBalance: `$$global:balance" -ForegroundColor White
    Write-Host "════════════════════════════════════════════════════════════"
    Read-Host "`nPress Enter to play again..."
}

function Add-Credits {
    Show-Title
    Write-Host @"

╔════════════════════════════════════════════════════════════╗
║                    ADD CREDITS                             ║
╠════════════════════════════════════════════════════════════╣
║  Current Balance: $("$" + $global:balance)                                         ║
╚════════════════════════════════════════════════════════════╝
"@
    $amount = Read-Host "`nEnter amount to add (0 to cancel)"
    
    if ($amount -match '^\d+$' -and [int]$amount -gt 0) {
        $global:balance += [int]$amount
        Write-Host "`nAdded `$$amount. New balance: `$$global:balance" -ForegroundColor Green
    }
    Start-Sleep -Seconds 1.5
}

# Main loop
while ($true) {
    $choice = Show-MainMenu
    
    switch ($choice) {
        "1" { Start-SlotMachine }
        "2" { 
            Show-Title
            Write-Host "`nCurrent Balance: `$$global:balance" -ForegroundColor Yellow
            Read-Host "`nPress Enter to continue..."
        }
        "3" { Add-Credits }
        "4" { 
            Show-Title
            Write-Host "`nThanks for playing at PowerHell Casino!" -ForegroundColor Green
            Write-Host "Come back soon!" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            exit 
        }
        default { 
            Write-Host "`nInvalid choice!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}