$list = $logfilepath = $computername = $Path = $Item = $tasks = $AbsolutePath = $connection = $dayuptime = $lastboottimeday = $lastboottimeHour = $null

# [REQUIRED] Le chemin utilisé pour généré le fichier CSV contenant le résultat du script
$logfilepath = "$home\Desktop\TasksList.csv"

$ModAD = Import-Module ActiveDirectory
$VerbosePreference = "continue"


# [REQUIRED] La variable utilisée pour lister les serveurs contenus dans l'AD. Cette variable ne contient que le nom.
$list = (Get-ADComputer -LDAPFilter "(&(objectcategory=computer)(OperatingSystem=*server*))").Name

# [OPTIONAL] Un message pour dire combien de serveurs vont être utilisés par le script
Write-Verbose  -Message "Trying to query $($list.count) servers found in AD"


# [OPTIONAL] En cas d'erreur (serveur injoignable), on continue 
$ErrorActionPreference = "SilentlyContinue"

# ------------------- Fonction Get-ScheduledTask


function Get-AllTaskSubFolders {
    [cmdletbinding()]
    param (
        # Set to use $Schedule as default parameter so it automatically list all files
        # For current schedule object if it exists.
        $FolderRef = $Schedule.getfolder("\")
    )
    if ($FolderRef.Path -eq '\') {
        $FolderRef
    }
    if (-not $RootFolder) {
        $ArrFolders = @()
        if(($Folders = $folderRef.getfolders(1))) {
            $Folders | ForEach-Object {
                $ArrFolders += $_
                if($_.getfolders(1)) {
                    Get-AllTaskSubFolders -FolderRef $_
                }
            }
        }
        $ArrFolders
    }
}

function Get-TaskTrigger {
    [cmdletbinding()]
    param (
        $Task
    )
    $Triggers = ([xml]$Task.xml).task.Triggers
    if ($Triggers) {
        $Triggers | Get-Member -MemberType Property | ForEach-Object {
            $Triggers.($_.Name)
        }
    }
}

function Get-TaskActions {
    [cmdletbinding()]
    param (
        $Task
    )
      $Actions = ([xml]$Task.xml).task.Actions.Exec
    if ($Actions) {
        $TaskXMLObject = [xml]$task.Xml
        $ActionsCommands = $TaskXMLObject.task.Actions.Exec
        
        ForEach ($ActionsCommand in $ActionsCommands) {
            $ActionTask = ($ActionsCommand.Command)
            return $ActionTask
        }
    }

}

function Get-TaskActionsArgument {
    [cmdletbinding()]
    param (
        $Task
    )
      $Actions = ([xml]$Task.xml).task.Actions.Exec
    if ($Actions) {
        $TaskXMLObject = [xml]$task.Xml
        $ActionsArgs = $TaskXMLObject.task.Actions.Exec
        
        ForEach ($ActionsArg in $ActionsArgs) {
            $ActionsArg = ($ActionsArg.Arguments)
            return $ActionsArg
        }
    }

}

function Get-TaskTriggerRepetition {
    [cmdletbinding()]
    param (
        $Task
    )

    $TriggersRepetitionDay = ([xml]$Task.xml).task.Triggers.CalendarTrigger.ScheduleByDay.DaysInterval
    $TriggersRepetitionWeeks = ([xml]$Task.xml).task.Triggers.CalendarTrigger.ScheduleByWeek.WeeksInterval

    if ($TriggersRepetitionDay) {

        $TaskXMLObject = [xml]$task.Xml
        $CalendarTriggers = $TaskXMLObject.Task.Triggers.CalendarTrigger
        
        ForEach ($CalendarTrigger in $CalendarTriggers) {
            $Repetition = "Tous les " 
            $Repetition += ( $CalendarTrigger.ScheduleByDay.DaysInterval)
            $Repetition += " Jours"
            return $Repetition
        }
    }
    elseif ($TriggersRepetitionWeeks) {

    $TaskXMLObject = [xml]$task.Xml
    $CalendarTriggers = $TaskXMLObject.Task.Triggers.CalendarTrigger
        
    ForEach ($CalendarTrigger in $CalendarTriggers) {
        $Repetition = "Toutes les " 
        $Repetition += ( $CalendarTrigger.ScheduleByWeek.WeeksInterval)
        $Repetition += " semaines"
        return $Repetition
    }
    }
    else { $Repetition = "" }
}

function Get-TaskTriggerDayOfWeek {
    [cmdletbinding()]
    param (
        $Task
    )

    $TriggersDayOfWeek = ([xml]$Task.xml).task.Triggers.CalendarTrigger.ScheduleByWeek.DaysOfWeek
    if ($TriggersDayOfWeek) {

        $TaskXMLObject = [xml]$task.Xml
        $CalendarTriggers = $TaskXMLObject.Task.Triggers.CalendarTrigger
        $TaskTriggerArray = @()
        ForEach ($CalendarTrigger in $CalendarTriggers) {
            $DaysOfWeek = ( $CalendarTrigger.ScheduleByWeek.DaysOfWeek | Get-Member -MemberType Property | Select -ExpandProperty Name) | ForEach-Object -Process { [enum]::parse([System.DayOfWeek],$_ ) } | Sort-Object #parsing the values into an enum will allow the objects to be sorted by day instead of alphabetical order           
            return $DaysOfWeek
        }
    }

}


function Get-TaskTriggerDaysOfMonth {
    [cmdletbinding()]
    param (
        $Task
    )

    $TriggersMonth = ([xml]$Task.xml).task.Triggers.CalendarTrigger.ScheduleByMonth.Months
    if ($TriggersMonth) {

        $TaskXMLObjectMonth = [xml]$task.Xml
        $CalendarTriggersMonth = $TaskXMLObjectMonth.Task.Triggers.CalendarTrigger

        ForEach ($CalendarTriggerMonth in $CalendarTriggersMonth) {
            $Months = "le "
            $Months += ($CalendarTriggerMonth.ScheduleByMonth.DaysOfMonth.Day)
            $Months += " de "
            $Months += ( $CalendarTriggerMonth.ScheduleByMonth.Months | Get-Member -MemberType Property | Select -ExpandProperty Name) 
            return $Months
        }
    }

}

function Get-TaskTriggerTypeOfSchedule {
    [cmdletbinding()]
    param (
        $Task
    )
    $TriggersTypeOfSchedule = ([xml]$Task.xml).task.Triggers.CalendarTrigger
    if ($TriggersTypeOfSchedule) {
        $TriggersTypeOfSchedule | Get-Member -MemberType Property | ForEach-Object {
            $TriggersTypeOfSchedule.($_.Name)
        }
  }
}

function Get-ScheduledTask { 
    param(
	    [string]$ComputerName = $env:COMPUTERNAME,
        [switch]$RootFolder
    )



    try {
	    $Schedule = New-Object -ComObject 'Schedule.Service'
        $Schedule.connect($ComputerName)
        $connection = "Ok"
    } catch {
	    Write-Verbose "Schedule.Service COM Object not found, this script requires this object"
        $connection = "Impossible"

            write-host "TEST"
            # On renvoi un objet pour que le fichier contienne l'ensemble des serveurs
             New-Object -TypeName PSCustomObject -Property @{
            'ComputerName' = $ComputerName
            'Connection' = $connection
	        'Name' = ""
            'Path' = ""
            'State' = ""
            'Enabled' = ""
            'LastRunTime' = ""
            'LastTaskResult' = ""
            'NumberOfMissedRuns' = ""
            'NextRunTime' = ""
            'Author' =  ""
            'UserId' = ""
            'Description' = ""
            'Trigger' =  ""
            'TriggerTypeOfSchedule' = ""
            'TriggerDayOfWeek' = ""
            'TriggerDayOfMonth' = ""
            'DaysFromUptime' = ""
            'DateFromLastBootTime' = ""
            'HourFromLastBootTime' = ""
            'Repetition' = ""
            'Action' = "" 
            'Action_Arguments' = ""

        }
	    return
    }

    $lastboottime = (Get-WMIObject -Class Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction SilentlyContinue).LastBootUpTime
    If($lastboottime){
        $sysuptime = (Get-Date) - [System.Management.ManagementDateTimeconverter]::ToDateTime($lastboottime)
        $dayuptime = "$($sysuptime.Days)"
        $lastboottimecomputer = [System.Management.ManagementDateTimeconverter]::ToDateTime($lastboottime)
        $lastboottimeday = $lastboottimecomputer.ToString("dd/MM/yyyy")
        $lastboottimeHour = $lastboottimecomputer.ToString("HH:mm:ss")

    } 
    Else {
        $dayuptime = "Unable to determine Uptime"
        $lastboottimeday = "Unable to determine Uptime"
        $lastboottimeHour = "Unable to determine Uptime"
    }




    $AllFolders = Get-AllTaskSubFolders

    foreach ($Folder in $AllFolders) {

        if (($Tasks = $Folder.GetTasks(1))) {
            $Tasks | Foreach-Object {

            $TaskTrigger2 = Get-TaskTrigger -Task $_
            $TriggersDaysOfWeek2 = Get-TaskTriggerDayOfWeek -Task $_
            $TriggersDaysOfMonth2 = Get-TaskTriggerDaysOfMonth -Task $_
            $TriggersTypeOfSchedule2 = Get-TaskTriggerTypeOfSchedule -Task $_
            $Repetition2 = Get-TaskTriggerRepetition -Task $_
            $TaskAction2 = Get-TaskActions -Task $_
            $ActionsArg2 = Get-TaskActionsArgument -Task $_
            
              New-Object -TypeName PSCustomObject -Property @{
                    'ComputerName' = $Schedule.TargetServer
                    'Connection' = $connection
	                'Name' = $_.name
                    'Path' = $_.path
                    'State' = switch ($_.State) {
                        0 {'Unknown'}
                        1 {'Disabled'}
                        2 {'Queued'}
                        3 {'Ready'}
                        4 {'Running'}
                        Default {'Unknown'}
                    }
                    'Enabled' = $_.enabled
                    'LastRunTime' = $_.lastruntime
                    'LastTaskResult' = $_.lasttaskresult
                    'NumberOfMissedRuns' = $_.numberofmissedruns
                    'NextRunTime' = $_.nextruntime
                    'Author' =  ([xml]$_.xml).Task.RegistrationInfo.Author
                    'UserId' = ([xml]$_.xml).Task.Principals.Principal.UserID
                    'Description' = ([xml]$_.xml).Task.RegistrationInfo.Description
                    'Trigger' =  [string]$TaskTrigger2.Name
                    'TriggerTypeOfSchedule' = [string]$TriggersTypeOfSchedule2.Name
                    'TriggerDayOfWeek' = [string]$TriggersDaysOfWeek2
                    'TriggerDayOfMonth' = [string]$TriggersDaysOfMonth2
                    'DaysFromUptime' = $dayuptime
                    'DateFromLastBootTime' = $lastboottimeday
                    'HourFromLastBootTime' = $lastboottimeHour
                    'Repetition' = $Repetition2
                    'Action' = $TaskAction2
                    'Action_Arguments' = $ActionsArg2

                }
            }
        }
    }
    
}

# --------------------


$ListTachesPlanifiees = @()
$connection = $Null

foreach ($computername in $list)
{
        write-host "Serveur en cours : $computername"

        try {
	        $Schedule = New-Object -ComObject 'Schedule.Service'
            $Schedule.connect($ComputerName)
            $connection = "Ok"
        } catch {
	        Write-Verbose "Schedule.Service COM Object not found, this script requires this object"
            $connection = $Null
        }



        if ($connection) {
            $ListTachesPlanifiees += Get-ScheduledTask -ComputerName $computername -RootFolder
        }
        else {
            $d = New-Object -TypeName PSCustomObject -Property @{
            'ComputerName' = $ComputerName
            'Connection' = "Impossible"
	        'Name' = ""
            'Path' = ""
            'State' = ""
            'Enabled' = ""
            'LastRunTime' = ""
            'LastTaskResult' = ""
            'NumberOfMissedRuns' = ""
            'NextRunTime' = ""
            'Author' =  ""
            'UserId' = ""
            'Description' = ""
            'Trigger' =  ""
            'TriggerTypeOfSchedule' = ""
            'TriggerDayOfWeek' = ""
            'TriggerDayOfMonth' = ""
            'DaysFromUptime' = ""
            'DateFromLastBootTime' = ""
            'HourFromLastBootTime' = ""
            'Repetition' = ""
            'Action' = "" 
            'Action_Arguments' = ""
            }
        $ListTachesPlanifiees += $d
        }
}

$ListTachesPlanifiees  | select ComputerName,Connection,DaysFromUptime,DateFromLastBootTime,HourFromLastBootTime,Name,Enabled,State,Action,Action_Arguments,Trigger,TriggerTypeOfSchedule,Repetition,TriggerDayOfWeek,TriggerDayOfMonth,LastRunTime,NextRunTime,LastTaskResult,NumberOfMissedRuns,UserId,Author,Path,Description | Export-Csv $logfilepath -NoTypeInformation -Encoding UTF8 -Delimiter ";"
