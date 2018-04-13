$path = "c:\public\systemFiles\scripts\import.csv"
if(![System.IO.File]::Exists($path))
{
    Write-Host ("File does not exist: " + $path)
}
else
{
   $Import = Import-CSV $path -Header Name
   $password = ConvertTo-SecureString "ILuvM4th!" -AsPlainText -Force
 
   Foreach ($myUser in $Import)
   {
      $TestingUser = $myUser.Name
      $TestUser = Get-ADUser -Filter {SamAccountName -eq $TestingUser} -SearchBase "OU=TheBorg,DC=pahsrm503,DC=local"
      if ($TestUser -eq $Null)
      {
         #Let's add the users
         Write-Host ("Adding User: " + $TestingUser)
         
         $FirstName = $myUser.Name.split("_",2)[0]
         $LastName = $myUser.Name.split("_",2)[1]
         $upn = $myUser.Name + "@pahsrm503.local"
         $DisName = $FirstName + " " + $LastName
         $LocalPath = "\\PAHSRM503-01\userdata\" + $myUser.Name
   
         New-ADUser -Name $TestingUser `
                    -UserPrincipalName $upn `
                    -GivenName $FirstName `
                    -Surname $LastName `
                    -DisplayName $DisName `
                    -Description $DisName `
                    -homeDrive "S:" `
                    -homeDirectory $LocalPath `
                    -profilePath $LocalPath `
                    -Path "OU=TheBorg,DC=pahsrm503,DC=local" `
                    -AccountPassword $password `
                    -PasswordNeverExpires $True `
                    -ChangePasswordAtLogon $False `
                    -Enabled $True
      }
      else
      {
         Write-Host ("")
         Write-Host ("******* User Exists: " + $TestingUser)
         Write-Host ("")
      }
  }
}

