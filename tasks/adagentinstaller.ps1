# windows AD Installer
# Requirements 
#
#
# Requires running on a machine with Active Directory Computers and Users OR Domain Controller
#
# TODO - Convert top variables to passed parameters - error logging


# Step 1
#
# Get Name of computer to run on
# Get User credentials that have access to AD 
# Object Path or not Pass ou and dc objects as comma separated
# Filters on Object Path
# 
#

param (
  [String]$pemaster = $(puppet config print server), #required
  [String]$adhost = "", #required Computer with ad on it or domain controller Probably can Remove this value
  [String]$username = "", #required User who is able to look at ad and also install on machines ie administrator
  [String]$password = "", #required admin password
  [String]$dc = $false, # puppet,com comma separate this string
  [String]$ou = $false, # computers,belfast,uk comma separate this string
  [String]$filter = $false, # use the filter logic ie (name -like "window-*") 
  [String]$throttle = 2,
  [String]$logging = "c:/puppet-agent-installer.log"
)

$computers = $false
$searchPath = $false
$setFilter = $false

$pass = ConvertTo-SecureString -AsPlainText $password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username,$pass



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
# Function to get all the computer objects based on the collected info
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
# May need to pass credentials 

if ($computers.DNSHostName -ne "") {

    # this will us http and winrm i think alternative is to use start-job
    $jobpeagent = Invoke-Command -ComputerName $computers.DNSHostName -ScriptBlock {
        #check for puppet agent
        $compname =  $env:COMPUTERNAME
        $time = Get-Date -Format "MMddyyyy" 
       
        if (Get-service puppet -ErrorAction SilentlyContinue) {
            $puppetinstalled = Get-WmiObject Win32_Product | Where-Object { $_.Name -Like "Puppet Agent*"}   | Select-Object Name,Version
            return "Puppet Already Installed on $compname - ( Puppet: $($puppetinstalled.Name) Version: $($puppetinstalled.version) )"
        } else {
            [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; 
            [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; 
            $webClient = New-Object System.Net.WebClient; 
            $webClient.DownloadFile('https://' + $using:pemaster + ':8140/packages/current/install.ps1', 'install.ps1') 
            & C:\Windows\System32\install.ps1;
        }

        if (Get-service puppet -ErrorAction SilentlyContinue) {
            return "Puppet Agent is now Installed on - $compname at $time"
            } else {
               return "Agent Failed- $compname"
               }
            
    
    } -credential $Cred -JobName "Puppet-Agent-Install" -ThrottleLimit $throttle -AsJob 

        # loop to check status of running job and get job id
        $jobId = $jobpeagent.id
        while($jobpeagent.state -eq "Running") {

            Start-Sleep -s 15
        }

        # once complete return the content of the job to file?
        #Receive-Job -Id 
        write-output "----------------------------------------------------" | out-file $logging -append
        Receive-job -id $jobId -Keep | out-file $logging -append
        write-output $computers | out-file $logging -append
        
        
        $joboutput = Receive-job -id $jobId
        write-output "Master Node : $pemaster"
        if ($searchPath -eq $false) {
           write-output "The OU path which was used $searchPath"
        }
        write-output $joboutput
        write-output "see results of job $logging on the AD target host"

} else {
    write-output "No Computers found"
} 