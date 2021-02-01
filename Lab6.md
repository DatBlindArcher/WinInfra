# Scripting Powershell

Bij systeembeheer komen altijd repetititieve taakjes kijken, en dat is bij Windows Active Directory niet anders. Daarom biedt Windows een heel krachtige scripting-taal via PowerShell. PowerShell is ontwikkeld door Microsoft, wat maakt dat het enorm goed kan samenwerken met Active Directory.

## Users aanmaken

Ontwikkel eerst en vooral een scriptje waarmee je 1 user kan aanmaken, waaraan je de opties voornaam en naam meegeeft. De gebruikersnaam wordt automatisch ingesteld op `voornaam.familienaam`.

```Ps
    #filename add_user.ps1
    $voornaam=$args[0]
    $achternaam=$args[1]
    $paswoord="p@ssw0rd"
    $SecurePassword = $paswoord | ConvertTo-SecureString -AsPlainText -Force
    New-ADUser -Name "$voornaam $achternaam" -SamAccountName "$voornaam.$achternaam" -AccountPassword $SecurePassword -Enabled $true
```

## Veel users aanmaken

In het labo vind je een Excel-bestand met een heleboel namen. De bedoeling is dat je deze namen allemaal automatisch inleest en de gebruikers eruit aanmaakt.

```Ps
    Get-Content .\names.csv |  foreach-object {
    $Split = $_ -split ' '
    $voornaam=$Split[1] 
    $achternaam=$Split[2]
    .\add_user.ps1 $voornaam $achternaam
    }
```

## Password resets

Maak een scriptje dat het wachtwoord van een disabled gebruiker instelt op een vooraf bepaald paswoord (p@ssw0rd) en de gebruiker terug enabled. De gebruiker moet zijn wachtwoord aanpassen de volgende keer dat hij aanmeldt.

```Ps
    $paswoord="p@ssw0rd"
    $SecurePassword = $paswoord | ConvertTo-SecureString -AsPlainText -Force
    Write-Host "Volgende gebruikers zijn DISABLED"
    Get-ADUser -Filter {Enabled -eq $False} | Select-Object -Property SamAccountName, Enabled |  ft
    $Gebruiker = Read-Host -Prompt 'Welke gebruiker wil je RESETTEN?'
    Set-ADAccountPassword -Identity $Gebruiker -NewPassword $SecurePassword -Reset
    Enable-ADAccount -Identity $Gebruiker
    Set-ADUser -Identity $Gebruiker -ChangePasswordAtLogon:$true
    Write-Host "Gebruiker $Gebruiker zijn/haar paswoord is reset naar **p@ssw0rd** en de gebruiker is terug actief" 
    Get-ADUser -Filter  {Enabled -eq $True} | Select-Object -Property SamAccountName, Enabled |  ft
```
