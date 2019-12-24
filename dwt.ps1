Import-Module ActiveDirectory

# DWT Application
# Created to optimise DWT workflows.
# Made by Jordan Flessenkemper in 2019.
class DWT
{
    # Application properties.
    [string] $blockLine = "████████████████████████████████████████████████████████████"
    [string] $windowTitle = "" 
    [string] $invalidUsernameMsg = "Invalid USERNAME"
    [string] $invalidUsernameBlock = "███████████████████████"
    [string] $invalidOperationMsg = "That is not a valid operation"
    [string] $invalidOperationBlock = "████████████████████████████████████"
    [string] $invalidComputerMsg = "Invalid COMPUTER"
    [string] $invalidComputerBlock = "███████████████████████"
    [string] $newline = [Environment]::NewLine
    [string] $jiraCode = "{code}"

    # Invalid username prompt.
    warning ([string] $warningMsg = "", [string] $block)
    {
        Write-Host $block -ForegroundColor DarkRed
        Write-Host ""
        Write-Host " -!"$warningMsg" !-" -ForegroundColor Red
        Write-Host ""
        Write-Host $block -ForegroundColor DarkRed
    }

    # Display the operations menu.
    displayMenu ()
    {
        # Clear the screen before returning to the main screen.
        Clear-Host

        # Change the window title for the operations menu.
        $this.windowTitle = "DWT | Select an operation"

        # Displaying the operations menu.
        Write-Host $this.windowTitle -ForegroundColor Blue 
        Write-Host $this.blockLine -ForegroundColor DarkBlue
        Write-Host ""
        Write-Host "1 - Get the SECURITY GROUPS applied to a USER" -ForegroundColor DarkGreen
        Write-Host "2 - Get the USERS that are logged into a COMPUTER" -ForegroundColor DarkGreen
        Write-Host ""
        Write-Host $this.blockLine -ForegroundColor DarkBlue

        # Retrieve input to select an operation.
        $number = Read-Host "Please enter an operation number"

        # Send user to the operation screen.
        switch ($number)
        {
            1 {
                # Get the AD user account.
                $userName = Read-Host "Please enter a NT Username"

                # A user name has not been specified.
                if (!$userName)
                {
                    # Clear the screen so the error message can be displayed.
                    Clear-Host

                    # Display the invalid username message.
                    $this.warning($this.invalidUsernameMsg, $this.invalidUsernameBlock)

                    # Return to the menu.
                    pause

                    # Clear the screen before returning to the main screen.
                    Clear-Host

                    # Return to the menu selection.
                    $this.displayMenu()
                } else {
                    # Run the operation.
                    $this.userSecurityGroups($userName)
                }
            }

            2 {
                # Run operation 2.
                $this.usersLoggedIn()
            }

            # This is not a valid operation.
            default {
                # Clear the screen.
                Clear-Host

                #Write-Host "-! $number is not a valid operation !-" -ForegroundColor Red
                $this.warning($this.invalidOperationMsg, $this.invalidOperationBlock)

                # Wait for input.
                Pause

                # Return to the menu selection.
                $this.displayMenu()
            }
        }
    }

    # Operation 1 - Get SECURITY GROUPS under USER.
    userSecurityGroups ([string] $user = "")
    {
        # Clear the screen before display the groups.
        Clear-Host

        # Retrieve the user groups.
        Write-Host $this.blockLine -ForegroundColor DarkBlue
        Write-Host ""
        Write-Host (Get-ADPrincipalGroupMembership $user | select name | Format-Table | Out-String)

        # Add the groups to a clipboard.
        $groups = Get-ADPrincipalGroupMembership $user | select name | Format-Table | Out-String

        # Format the groups for Jira.
        $groupsReformed = $this.jiraCode + $groups + $this.newline + $this.jiraCode

        # Copy the groups to your clipboard and have them formated for jira.
        Set-Clipboard -value $groupsReformed

        Write-Host $this.blockLine -ForegroundColor DarkBlue
        Write-Host ">> Result formated and copied to your clipboard" -ForegroundColor Green

        # Pause before returning
        pause

        # Clear the screen before displaying the menu.
        Clear-Host

        # Go back to the menu.
        $this.displayMenu()
    }

    # Operation 2 - Get the USERS that are logged into a COMPUTER
    usersLoggedIn ()
    {
        $computerName = Read-Host "Please enter a computer name"

        # A computer name has not been specified.
        if (!$computerName)
        {
            # Clear the screen.
            Clear-Host

            # Display the invalid computername message.
            $this.warning($this.invalidComputerMsg, $this.invalidComputerBlock)

            # Wait for user input.
            Pause

            # Return to the menu selection.
            $this.displayMenu()

        } else {
            # Clear the screen.
            Clear-Host

            # Get the session data.
            Write-Host $this.blockLine -ForegroundColor DarkBlue
            Write-Host ""
            Write-Host (Invoke-Command -ComputerName $computerName -ScriptBlock {quser} | Format-Table | Out-String )
            Write-Host $this.blockLine -ForegroundColor DarkBlue

            # Wait for user input.
            Pause

            # Clear the screen.
            Clear-Host

            # Return to the menu selection.
            $this.displayMenu()
        }
    }

    # Main program loop.
    main ()
    {
        # Clear the screen before the start of the program.
        Clear-Host

        # Display the operations menu.
        $this.displayMenu()
    }
}

# Run the DWT application.
$console = New-Object DWT
$console.main()
