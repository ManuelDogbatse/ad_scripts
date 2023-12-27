# Get template password for all users
$passwordStr = Read-Host -Prompt "Enter the password for users"
# Comment the line above and uncomment the line below to hard code the password instead
#$passwordStr = "Password123"    # Hard coded
# Read names and departments TXT files
$nameList = Get-Content .\names_formatted.txt
$depList = Get-Content .\departments.txt

# Convert password string to secure string for AD user creation
$passwordSecStr = ConvertTo-SecureString $passwordStr -AsPlainText -Force

# Create an OU for each department, with 'Users' and 'Computers' sub-OUs, and create 'Users' and 'Computers' groups for each department
foreach ($dep in $depList) {
    try {
        if (Get-ADOrganizationalUnit -Identity "OU=$($dep),$(([ADSI]'').distinguishedName)") {
            Write-Host "$dep does exist."
        }
    }
    catch {
        Write-Host "$dep does not exist. Creating OU"
        New-ADOrganizationalUnit -Name "_$dep" -ProtectedFromAccidentalDeletion $false
        New-ADOrganizationalUnit -Name "Users" -ProtectedFromAccidentalDeletion $false -Path "OU=_$($dep),$(([ADSI]'').distinguishedName)"
        New-ADOrganizationalUnit -Name "Computers" -ProtectedFromAccidentalDeletion $false -Path "OU=_$($dep),$(([ADSI]'').distinguishedName)"
    }

    try {
        if (Get-ADGroup -Identity "$dep Users") {
            Write-Host "User group for $dep does exist"
        }
    }
    catch {
        Write-Host "User group for $dep does not exist. Creating user group"
        New-ADGroup -Name "$dep Users" -GroupCategory Security -GroupScope Global -Path "OU=Users,OU=_$($dep),$(([ADSI]'').distinguishedName)" -SamAccountName "$dep Users"
    }

    try {
        if (Get-ADGroup -Identity "$dep Computers") {
            Write-Host "Computer group for $dep does exist"
        }
    }
    catch {
        Write-Host "Computer group for $dep does not exist. Creating computer group"
        New-ADGroup -Name "$dep Computers" -GroupCategory Security -GroupScope Global -Path "OU=Computers,OU=_$($dep),$(([ADSI]'').distinguishedName)" -SamAccountName "$dep Computers"
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
    Write-Host "$($depList[$cnt]) " -ForegroundColor Red -NoNewline
    Write-Host "department" -ForegroundColor Cyan
    
    # Create new user
    New-AdUser -AccountPassword $passwordSecStr `
        -GivenName $fName `
        -Surname $sName `
        -DisplayName "$fName $sName" `
        -Name $uName `
        -EmployeeID $uName `
        -PasswordNeverExpires $true `
        -Path "OU=Users,OU=_$($depList[$cnt]),$(([ADSI]'').distinguishedName)" `
        -Enabled $true
    
    # Add user to department users group
    Add-ADGroupMember -Identity "$($depList[$cnt]) Users" -Members $uName
    
    # Change departments
    $cnt++
    if ($cnt -eq $n) {
        $cnt = 0
    }
}