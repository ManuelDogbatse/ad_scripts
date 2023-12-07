# Get template password for all users
$passwordStr = Read-Host -Prompt "Enter the password for users"
#$passwordStr   = "Password123!"    # Hard coded
# Read names and departments TXT files
$nameList = Get-Content .\names.txt
$depList = Get-Content .\departments.txt

# Convert password string to secure string for AD user creation
$passwordSecStr = ConvertTo-SecureString $passwordStr -AsPlainText -Force

Create an OU for each department, with 'Users' and 'Computers' sub-OUs
foreach  ($dep in $depList){
    New-ADOrganizationalUnit -Name $dep -ProtectedFromAccidentalDeletion $false
    New-ADOrganizationalUnit -Name "Users" -ProtectedFromAccidentalDeletion $false -Path "OU=$($dep),$(([ADSI]'').distinguishedName)"
    New-ADOrganizationalUnit -Name "Computers" -ProtectedFromAccidentalDeletion $false -Path "OU=$($dep),$(([ADSI]'').distinguishedName)"
}

# 'textInfo' for converting names to title case
$textInfo = (Get-Culture).TextInfo
$cnt = 0
$n = $depList.Count

# Create each user in names TXT file
foreach ($name in $nameList) {
    # Split line into forename and surname, and change to title case
    $fName, $sName = $name.Split(" ") | ForEach-Object {$textInfo.ToTitleCase($_)}
    $uName = "$($fName.Substring(0,1))$($sName)".ToLower()
    # Print current user and current department
    Write-Host "Creating user " -ForegroundColor Cyan -NoNewline
    Write-Host "$($fName) $($sName) ($($uName)) " -ForegroundColor Yellow -NoNewline
    Write-Host "in the " -ForegroundColor Cyan -NoNewline
    Write-Host "$($depList[$cnt]) " -ForegroundColor Red -NoNewline
    Write-Host "department" -ForegroundColor Cyan
    
    # Create new user
    New-AdUser -AccountPassword $passwordSecStr `
               -GivenName $fname `
               -Surname $lname `
               -DisplayName "$fname $sname" `
               -Name $username `
               -EmployeeID $username `
               -PasswordNeverExpires $true `
               # Add users to one of the departments
               # 'ADSI' accesses the domain name of the domain for user creation
               -Path "OU=Users,OU=$($depList[$cnt]),$(([ADSI]'').distinguishedName)"
               -Enabled $true
    
    # Change departments
    $cnt++
    if ($cnt -eq $n)
    {
        $cnt = 0
    }
}