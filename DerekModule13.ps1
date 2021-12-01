function Test-CloudFlare {

    <#
    .SYNOPSIS
    Tests a connection to CloudFlare DNS.
    .DESCRIPTION
    This command will test a single computer's or multiple computer's Internet Connection to CloudFlare's one.one.one.one DNS Server.
    .PARAMETER PathVariable
    A string that specifies a path to the user's home directory. 
    .PARAMETER ComputerName
    A string that specifies which computer will be connected to in a remote session.
    .PARAMETER Output
    A string that specifies which output will be produced depending on input.
        Host will write the output of JobResults job to the screen.
        Text will save the output of JobResults job, $Computername and $DateTime to RemTestNet.txt.
        CSV will save the output of JobResults job to a CSV file.
    .EXAMPLE
    .\Test-CloudFlare -ComputerName $ComputerName -Output 'Host'.
    Executing this command will run the Test-CloudFlare script and display the results of the script in the output.
    .EXAMPLE
    .\Test-CloudFlare -ComputerName $ComputerName -Output 'Text'
    Executing this command will run the Test-CloudFlare script and output the results of the scripts in text file named "RemTestNet.txt"
    .EXAMPLE
    .\Test-CloudFlare -ComputerName $ComputerName -Output 'CSV'.
    Executing this command will run the Test-CloudFlare script and output the results of the script in a CSV file named "JobResults.csv".
    .NOTES
    Author: Derek Kirk
    Last Modified: 11-10-2021
    Version 1.2 - Modified Release of Test-CloudFlare.
        -Added a Try/Catch construct to the ForEach construct for error handling.
        -Modified the OBJ variable to use the [PSCustomObject] accelerator.
    #>
    
    [CmdletBinding()]
    # This enables cmdlet binding
    
    Param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [Alias('CN','Name')][string[]]$ComputerName,
        [Parameter(Mandatory=$False)][string]$PathVariable = $env:userprofile,
        [ValidateSet('Host','Text','CSV')][string]$Output = "Host"
    ) #Param
    #This sets the ComputerName parameter to true, accepts input ByValue from the pipeline, specifies a user's home directory path and defines a set for output.
    
    ForEach ($EachValue in $ComputerName) {
        Try {
            $Params = @{
              'ComputerName' = $EachValue
              'ErrorAction' = 'Stop'
            } #Try Params
        #Creates a new parameter named Params that includes the objects ComputerName and ErrorAction. ^
        $RemoteSession = New-PSSession @Params
        #Variable which specifies a new remote session to the computer name provided in input.
        Enter-PSSession $RemoteSession
        #Enters the remote session.
        $DateTime = Get-Date
        #Fetches the current date and time and saves to a variable named DateTime.
        $TestCF = Test-NetConnection -ComputerName 'one.one.one.one' -InformationLevel Detailed
        #Variable that contains the command to run a detailed ping test to 1.1.1.1.
        Write-Verbose "Running a ping test from the remote computer to 1.1.1.1."
        Start-Sleep -Seconds 2
        $OBJ = [PSCustomObject]@{
            'ComputerName' = $EachValue
            'PingSuccess' = $TestCF.PingSucceeded
            'NameResolve' = $TestCF.NameResolutionSucceeded
            'ResolvedAddresses' = $TestCF.ResolvedAddresses
            } #OBJ Custom Props
        #Creates a variable that contains the ComputerName and the results of the ping, name resolve and the resolved address.
        Exit-PSSession
        Remove-PSSession $RemoteSession
        #Exits the PS session and then removes the PS session.
        } #Try
        Catch {
            Write-Host "Remote Connection to $EachValue failed" -ForeGroundColor Red
        } #Catch
    } #ForEach
    
    Switch ($Output) {
        "Text" {
            Write-Verbose "Finished running the ping test"
            Start-Sleep -Seconds 2
            $OBJ | Out-File $PathVariable\TestResults.txt
            Add-Content $PathVariable\RemTestNet.txt -value "Computer Tested: $ComputerName"
            Add-Content $PathVariable\RemTestNet.txt -value "Date/Time Tested: $DateTime"
            Add-Content $PathVariable\RemTestNet.txt -value (Get-Content $PathVariable\TestResults.txt)
            #Adds content to the RemTestNet text file including the computer's name, the date the test was ran, and the contents of TestResults.txt.
            Write-Verbose "Generating results file"
            Start-Sleep -Seconds 1
            Write-Verbose "Opening results"
            Start-Sleep -Seconds 2
            Notepad.exe $PathVariable\RemTestNet.txt
            Remove-Item $PathVariable\TestResults.txt
            #Opens the RemTestNet text file and removes the TestResults text file.
            }
        "CSV" {
            Write-Verbose "Finished running the ping test"
            Start-Sleep -Seconds 2
            Write-Verbose "Generating results file as CSV"
            Start-Sleep -Seconds 1
            $OBJ | Export-CSV -Path $PathVariable\TestResults.csv
            }
            #Retrieves the job results and exports the contents to a CSV file.
        "Host" {
            Write-Verbose "Finished running the ping test"
            Start-Sleep -Seconds 2
            Write-Verbose "Generating results file and displaying it to the screen"
            Start-Sleep -Seconds 1
            $OBJ
            }
            #Retrieves the job results and displays the contents to the screen.
        } #Switch
    } #Function