$IDOff =""
$TimeCreatedOff =""
$org=""
$asname=""
$address=""
$ipAddress=""
$Events = Get-WinEvent -logname "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational" -MaxEvents 100 | where {($_.Id -eq "21" -OR $_.Id -eq "24" -OR $_.Id -eq "25")}
$Results = Foreach ($Event in $Events) 
{
  $Result = "" | Select UserOn,AddressOn,TimeCreatedOn,TimeCreatedOff,IDOn,IDOff,org,asname,address
  if($Event.Id -eq "24")
  {
      $IDOff = $Event.Id
      $TimeCreatedOff = $Event.TimeCreated
  }
  else
  {
      Foreach ($MsgElement in ($Event.Message -split "`n")) 
      {
        $Element = $MsgElement -split ":"
        If ($Element[0] -like "User") 
        {
            $Result.UserOn = $Element[1].Trim(" ")
        }
        If ($Element[0] -like "*Source Network Address") 
        {
            $ipAddress = $Element[1].Trim(" ") 
            $Result.AddressOn = $ipAddress 
            $urlString='http://ip-api.com/json/'+$ipAddress+'?fields=country,regionName,city,org,asname'
            $IpAddresLocation = Invoke-RestMethod -Uri $urlString
            $org = $IpAddresLocation.org
            $asname = $IpAddresLocation.asname
            $address = $IpAddresLocation.city +" - "+$IpAddresLocation.regionName+" - "+$IpAddresLocation.country
        }
        $Result.org = $org
        $Result.asname = $asname
        $Result.address = $address
        $Result.IDOn = $Event.Id
        $Result.TimeCreatedOn = $Event.TimeCreated
        $Result.IDOff = $IDOff
        $Result.TimeCreatedOff = $TimeCreatedOff
      }
      $Result
  }
} 
$Results | Select UserOn,AddressOn,TimeCreatedOn,TimeCreatedOff,IDOn,IDOff,org,asname,address | Out-GridView

