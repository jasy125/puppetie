# windows AD Installer
# Requirements 
#
#
# Requires running on a machine with Active Directory Computers and Users OR Domain Controller
#
# TODO - DONT RUN THIS TASK YET NOT TESTED


# Step 1
#
# Get Name of computer to run on
# Get User credentials that have access to AD 
# Object Path or not Pass ou and dc objects as comma separated
# Filters on Object Path
# 
#

param (
  [String]$username = "", #required User who is able to look at ad and also install on machines ie administrator
  [String]$password = "", #required admin password
  [String]$dc = $false, # puppet,com comma separate this string
  [String]$ou = $false, # computers,belfast,uk comma separate this string
  [String]$filter = $false, # use the filter logic ie (name -like "window-*") 
  [String]$throttle = 2,
  [String]$logging = "c:/puppet-agent-uninstaller.log",
  [String]$dryRun = $false,
  [String]$uninstall = "Puppet Agent"
)

#Switches for different if statements
$computers = $false
$searchPath = $false
$setFilter = $false

#Build credentials

Function setCreds ($username,$password) {
    $pass = ConvertTo-SecureString -AsPlainText $password -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username,$pass
return $cred    
}

$cred = setCreds $username $password

# Step 2
#
# Check to see if we have a specified ou path it not just do all
#
#
function buildOU($dc,$ou) {

    $dcpath = ",DC=" + $dc.replace(',',',DC=');
    $oupath = "OU=" + $ou.replace(',',',OU=');
    $searchPath = "$oupath$dcpath"; 

return $searchPath 
}

if ( $dc -ne $false -and $ou -ne $false ) {
   $searchPath = buildOU $dc $ou
} elseif ($dc -eq $false -and $ou -ne $false) {
    $domain = (Get-WmiObject Win32_ComputerSystem).Domain #grab the local domain of this machine
    $dc = $domain.replace(".",",")
    $searchPath = buildOU $dc $ou
}

# Step 3
#
# Check if filter is set 
# This will be tricket to get set correctly maybe create a validator on this but not required just yet
#
#

if ($filter -ne $false) {
   $setFilter = $true
}

# Step 4
#
# Get all the computer objects based on the collected info
# 
#

if ( $searchPath -ne $false -and $setFilter -eq $true ) {
    $computers = Get-ADComputer -Filter $filter -SearchBase $searchPath | Select DNSHostName | Sort Name 
} elseif ( $searchPath -ne $false -and $setFilter -eq $false ) {
    $computers = Get-ADComputer -filter * -SearchBase $searchPath | Select DNSHostName | Sort Name 
} elseif ( $searchPath -eq $false -and $setFilter -ne $false ){
    $computers = Get-ADComputer -filter $filter | Select DNSHostName | Sort Name 
} else {
    $computers = Get-ADComputer -filter * | Select DNSHostName | Sort Name 
}


# Step 5 
# 
# Start some magic 
# 
# Get our list of objects and start reaching out to them using powershell jobs
# 

# create a powershell job loop of the computers array or loop instances and connect via Invoke-Command ( Jobs be better as batch processing )

# connect to the computer and check for existance of puppet agent service

if ($computers.DNSHostName -ne "" ) {
  echo $computers.DNSHostName
    # this will us http and winrm i think alternative is to use start-job
        $jobpeagent = Invoke-Command -ComputerName $computers.DNSHostName -ScriptBlock {
            echo "hi"
        } -credential $cred -JobName "uninstallApp" -ThrottleLimit $throttle -AsJob 

      
        # once complete return the content of the job to file ( | Tee-Object )
        
       # Receive-job -id $jobId | Tee-Object -file $logging -append
        
} else {
    write-output "No Computers found"
} 