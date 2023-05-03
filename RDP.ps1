$IDOff =""
$TimeCreatedOff =""
$Events = Get-WinEvent -logname "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational" | where {($_.Id -eq "21" -OR $_.Id -eq "24" -OR $_.Id -eq "25")}
$Results = Foreach ($Event in $Events) 
{
  $Result = "" | Select UserOn,AddressOn,TimeCreatedOn,TimeCreatedOff,IDOn,IDOff
  if($Event.Id -eq "24")
  {
        $IDOff = $Event.Id
      $TimeCreatedOff = $Event.TimeCreated
  }
  else
  {
        $Result.IDOn = $Event.Id
        $Result.TimeCreatedOn = $Event.TimeCreated
      Foreach ($MsgElement in ($Event.Message -split "`n")) 
      {
        $Element = $MsgElement -split ":"
        If ($Element[0] -like "User") 
        {
            $Result.UserOn = $Element[1].Trim(" ")
        }
        If ($Element[0] -like "*Source Network Address") 
        {
            $Result.AddressOn = $Element[1].Trim(" ")
        }
        $Result.IDOff = $IDOff
        $Result.TimeCreatedOff = $TimeCreatedOff
         }
      $Result
  }
} 
$Results | Select UserOn,AddressOn,TimeCreatedOn,TimeCreatedOff,IDOn,IDOff | Out-GridView
