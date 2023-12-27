# Get template password for all users
$passwordStr = Read-Host -Prompt "Enter the password for users"
# Comment the line above and uncomment the line below to hard code the password instead
#$passwordStr = "Password123"    # Hard coded
# Read names and departments TXT files
$nameList = Get-Content .\names_formatted.txt
$depList = Get-Content .\departments.txt
$depNames = @()
$depInitials = @()

# Convert password string to secure string for AD user creation
$passwordSecStr = ConvertTo-SecureString $passwordStr -AsPlainText -Force

# Loop through each department
foreach ($dep in $depList) {
    $splitStr = $dep.Split(",")
    $depNames += $splitStr[0]
    $depInitials += $splitStr[1]

    # Create OUs and nested OUs (Users and Computers) for department if it doesn't exist
    try {
        if (Get-ADOrganizationalUnit -Identity "OU=_$($depNames[-1]),$(([ADSI]'').distinguishedName)") {
            Write-Host "$($depNames[-1]) does exist"
        }
    }
    catch {
        Write-Host "$($depNames[-1]) does not exist. Creating OU"
        New-ADOrganizationalUnit -Name "_$($depNames[-1])" -ProtectedFromAccidentalDeletion $false
        New-ADOrganizationalUnit -Name "Users" -ProtectedFromAccidentalDeletion $false -Path "OU=_$($depNames[-1]),$(([ADSI]'').distinguishedName)"
        New-ADOrganizationalUnit -Name "Computers" -ProtectedFromAccidentalDeletion $false -Path "OU=_$($depNames[-1]),$(([ADSI]'').distinguishedName)"
    }
    
    # Create user group for each department
    try {
        if (Get-ADGroup -Identity "$($depNames[-1]) Users") {
            Write-Host "User group for $($depNames[-1]) does exist"
        }
    }
    catch {
        Write-Host "User group for $($depNames[-1]) does not exist. Creating user group"
        New-ADGroup -Name "$($depNames[-1]) Users" -GroupCategory Security -GroupScope Global -Path "OU=Users,OU=_$($depNames[-1]),$(([ADSI]'').distinguishedName)" -SamAccountName "$($depNames[-1]) Users"
    }
    
    # Create computer group for each department
    try {
        if (Get-ADGroup -Identity "$($depNames[-1]) Computers") {
            Write-Host "Computer group for $($depNames[-1]) does exist"
        }
    }
    catch {
        Write-Host "Computer group for $($depNames[-1]) does not exist. Creating computer group"
        New-ADGroup -Name "$($depNames[-1]) Computers" -GroupCategory Security -GroupScope Global -Path "OU=Computers,OU=_$($depNames[-1]),$(([ADSI]'').distinguishedName)" -SamAccountName "$($depNames[-1]) Computers"
    }
    
    # Create computer for each department
    try {
        if (Get-ADComputer -Identity "$($depInitials[-1])-CLIENT1") {
            Write-Host "Computer for $($depNames[-1]) does exist"
        }
    }
    catch {
        Write-Host "Computer for $($depNames[-1]) does not exist. Creating computer"
        New-ADComputer -Name "$($depInitials[-1])-CLIENT1" -Path "OU=Computers,OU=_$($depNames[-1]),$(([ADSI]'').distinguishedName)"
    }
}

# 'textInfo' for converting names to title case
$textInfo = (Get-Culture).TextInfo
$cnt = 0
$n = $depList.Count

# Create each user in names TXT file
foreach ($name in $nameList) {
    # Split line into forename and surname, and change to title case
    $fName, $sName = $name.Split(" ") | ForEach-Object { $textInfo.ToTitleCase($_) }
    $uName = "$($fName.Substring(0,1))$($sName)".ToLower()
    # Print current user and current department
    Write-Host "Creating user " -ForegroundColor Cyan -NoNewline
    Write-Host "$($fName) $($sName) ($($uName)) " -ForegroundColor Yellow -NoNewline
    Write-Host "in the " -ForegroundColor Cyan -NoNewline
    Write-Host "$($depNames[$cnt]) " -ForegroundColor Red -NoNewline
    Write-Host "department" -ForegroundColor Cyan
    
    # Create new user
    New-AdUser -AccountPassword $passwordSecStr `
        -GivenName $fName `
        -Surname $sName `
        -DisplayName "$fName $sName" `
        -Name $uName `
        -EmployeeID $uName `
        -PasswordNeverExpires $true `
        -Path "OU=Users,OU=_$($depNames[$cnt]),$(([ADSI]'').distinguishedName)" `
        -Enabled $true
    
    # Add user to department users group
    Add-ADGroupMember -Identity "$($depNames[$cnt]) Users" -Members $uName
    
    # Change departments
    $cnt++
    if ($cnt -eq $n) {
        $cnt = 0
    }
}