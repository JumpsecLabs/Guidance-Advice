<#
Meta
    Date: 2021 July 20th; Updated: 2021 July 23rd
    Authors: Tom Ellson (@tde_sec) & Dray Agha (@Purp1eW0lf)
    Company: JUMPSEC Labs
    Purpose: CVE-2021-36934 Confirmation
#>

#setup
#Ensure errors don't ruin anything for us
$ErrorActionPreference = "SilentlyContinue"
#collect FQDN variable
$Name = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname

#Creation functions

#this will ask vulnerable user if they want to collect their OS details
function OS_Question {
    #sleep so user doesn't get overwhelmed with text.
    sleep 1.5
    
    write-host "`nThe information security community is keen to gather the specific Windows OS Versions and Builds that this permission misconfiguration has occured in"
    write-host "`nWould you like to gather the specific details of your OS to possibly share on Twitter?"
    write-host "`n[1] " -ForegroundColor magenta -NoNewline; write-host "Collect OS details"
    write-host "[2] " -ForegroundColor magenta -NoNewline; write-host "Quit Script`n"
    $question = read-host " "

    # this is essentially if/ else
    $result = switch ( $question )
    {
        1 {OS_Collection}
        2 {write-host "`nWe have remediation advice back in the Github Repo! Follow us on Twitter: Tom Ellson (@tde_sec) & Dray Agha (@Purp1eW0lf)`n"; exit}
    }
}
#this function will collect OS details
function OS_Collection {
    write-host -foregroundcolor Magenta "`nRunning OS Collection.......`n"

    #Variables for OS version. This takes a while to collect
    $SysInfo = gin
    $OS = $SysInfo.OsName
    $Ver = $SysInfo.WindowsVersion
    $Build= $SysInfo.OSBuildNumber

    #demarcate OS Info section
    Write-host "`n---OS Info---"

    #print variables for OS version. Stupid formatting here to get the colours because I am extra
    Write-host -foregroundcolor Magenta "`n$Name " -NoNewline
    write-host "is running " -NoNewline 
    write-host -foregroundcolor Magenta "$OS " -NoNewline
    write-host "version number " -NoNewline
    write-host -foregroundcolor Magenta "$Ver " -NoNewline
    write-host "and build number "  -NoNewline
    write-host -foregroundcolor Magenta "$Build " -NoNewline
    write-host "and is vulnerable to " -NoNewline
    write-host -foregroundcolor Magenta "CVE-2021-36934`n" -NoNewline
    sleep 1.5
    write-host "`nWe have remediation advice back in the Github Repo! Follow us on Twitter: Tom Ellson (@tde_sec) & Dray Agha (@Purp1eW0lf)`n"; exit
}
#This functions 'greps' for the vulnerable strings in the permissions of SAM, SECURITY, and SYSTEM in a for loop.
function vulnerable_perm{
    ###Determine if SAM is vulnerable###

    #demarcate results section
    write-host "`n---Vulnerability Results---"

    ##for loop to collect permissions for SAM, SECURITY, and SYSTEM. Likely overkill, as the permissions for one are likely the permissions for all.
    $items = @("SAM", "SECURITY", "SYSTEM"); foreach ($item in $items){
	    $ErrorActionPreference = "SilentlyContinue" ;
        if ((get-acl C:\windows\system32\config\$item).Access |
	        ? IdentityReference -match 'BUILTIN\\Users' | 
	        select -expandproperty filesystemrights | 
	        select-string 'Read')
	        {write-host -foregroundcolor Red "`n$Name may be vulnerable: Arbitrary Read permissions for $item file`n"}
        else {
	        write-host  -foregroundcolor Green "`n$Name does not seem to be vulnerable, $item permissions are fine`n"}
        }
        #The logic here is basic on filtering the permissions for the SAM, security, and system files until we get the permissions string. The permissions string we alert as 'vuln' for is 'Read'.
	        # If the script cannot access the permissions, if the script gets a different permission string, it will return as 'not vuln', which should be accurate but of course explore this further. 

# this is the stupidest thing I've ever written....but essentially, I'm tired
    if ((get-acl C:\windows\system32\config\SAM).Access |? IdentityReference -match 'BUILTIN\\Users' |  select -expandproperty filesystemrights | select-string 'Read')
         {OS_Question}
    else 
         {write-host "`nGlad you're safe. Follow us on Twitter: Tom Ellson (@tde_sec) & Dray Agha (@Purp1eW0lf)`n"; exit}
}
#where the first and main part of the script is executed
function main {
    #Print basic script info
    Write-host "`nThis script will confirm if machine is vulnerable to " -NoNewline
    write-host -foregroundcolor Magenta "CVE-2021-36934"
    write-host "Where the SAM, SECURITY, SYSTEM files can be read by any user due to a vulnerable permissions misconfiguration`n"
    sleep 1.5
    #Determine vulnerability
    vulnerable_perm
}
#This executes the first function which triggers all the others
main
