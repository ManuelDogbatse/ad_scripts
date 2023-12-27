$depList = Get-Content .\departments.txt

foreach ($dep in $depList) {
    $splitStr = $dep.Split(",")
    $depNames += $splitStr[0]
    $depInitials += $splitStr[1]

    Remove-ADOrganizationalUnit -Identity "OU=_$($depNames[-1]),$(([ADSI]'').distinguishedName)" -Recursive
}