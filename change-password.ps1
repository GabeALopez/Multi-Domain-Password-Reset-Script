<#
    .SYNOPSIS
        Multi-Domain Password Reset Script.
    .DESCRIPTION
        The script allows user to change the password in multiple AD domains by supplying the domain credentials.
        The script is not able to change the password of expired accounts.
    .NOTES
        Version:    1.0
        Author:     N Lopez and G Lopez
        Creation date:  7/5/2024
#>

# Reads CSV file
$UserInfo = Import-Csv -Path .\user-information.csv

Function Show-Menu($strUserInfo) {

    Write-Host "====================================== MENU ======================================" -ForegroundColor Green
    Write-Host " You will be able to display the user's password last set or to change the user's password"
    ForEach ($info in $strUserInfo) {
        Write-Host "Press" $info.Id "to display or modify user" $info.UserName "in the" $info.Domains "domain."
    }
    Write-Host "Press 'q' to quit."
}

# Function has two inputs. One to display Lass Password set, the other to reset the password.
Function Set-ThePassword([string]$strUserName, [string]$strFQDNDomain) {

    Clear-Host
    Write-Host "Setting password for user $strUserName under $FQDNDomain domain" -ForegroundColor Green
    Write-Host "==============================================================================" -ForegroundColor Green
    
    $CurrentPassword = (Read-Host -Prompt "Provide Current Password" -AsSecureString)
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $strUserName, $CurrentPassword
    Write-Host ""

    # Code ask user to display last password set.
    Write-Host "Would you like to display the last time you changed the password for the" $strUserName" user?"
    $Key = Read-Host "Type 'y' and hit 'enter' to continue"
    If ($key -eq 'y') {
        try {
            Get-ADUser -Credential $Credential -Identity $strUserName -Server $strFQDNDomain -Properties PwdLastSet | Sort-Object Name | Format-Table Name, @{Name = 'PwdLastSet'; Expression = { [DateTime]::FromFileTime($_.PwdLastSet) } }
            Write-host ""   
        }
        catch {
            Write-Host "Error, please try again!" -ForegroundColor Red
        }
    }

    # Code to initiate password change
    try {
        Write-Host "You are about to change the password for user" $strUserName
        $Key = Read-Host "Type 'y' and hit 'enter' to continue"
        If ($key -eq 'y') {
            Write-Host ""
            $NewPassword = (Read-Host -Prompt "Provide New Password" -AsSecureString)
            Set-ADAccountPassword -Credential $Credential -Server $strFQDNDomain -Identity $strUserName -OldPassword $CurrentPassword -NewPassword $NewPassword
            Write-Host ""
            Write-Host "Password successfully set" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error, please try again!" -ForegroundColor Red
    }

    Start-Sleep -Seconds 5
    Clear-Host
    $Credential = ""
    $CurrentPassword = ""
    $NewPassword = ""
}

# Function collects user info from CSV file then passes to next fuction
Function Set-UserPassword($strUserInfo, $strMenuInput) {

    $UserName = $strUserInfo.UserName[$strMenuInput - 1]
    $FQDNDomain = $strUserInfo.FQDNDomain[$strMenuInput - 1]

    Set-ThePassword $UserName $FQDNDomain
}

# Start of script
$MenuInput = ""
$Continue = $true

While ( $Continue) {
    Show-Menu($UserInfo)
    $MenuInput = Read-Host "Please make a selection"
    If ($MenuInput -eq 'q') {
        $UserInfo = ""
        $Continue = $FALSE
        Clear-Host
    }
    elseif ($MenuInput -ge 1 -and $MenuInput -le $UserInfo.count) {
        Set-UserPassword $UserInfo $MenuInput
    }
    else { Write-Host "You have entered an incorrect choice" }
}