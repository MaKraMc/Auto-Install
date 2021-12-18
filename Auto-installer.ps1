#AutoInstaller by Marco (c)2021
##Settings
$Programms = @("Discord.Discord", "Microsoft.PowerToys", "Microsoft.WindowsTerminal", "ModernFlyouts.ModernFlyouts", "7zip.7zip", "Mozilla.Firefox", "Notepad++.Notepad++", "AdoptOpenJDK.OpenJDK.16", "Valve.Steam", "VideoLAN.VLC", "Mojang.MinecraftLauncher", "Nvidia.GeForceExperience")
$Presets = @("Gaming", "Server", "Content Creator")
$Debug = $false


$Options = @("Install") * $Programms.count
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$Count = $Programms.Count
$version = "1.1"

function Test-AdminRecht
{
$user = [Security.Principal.WindowsIdentity]::GetCurrent();
(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

$admin = Test-AdminRecht

$FormObjekt = New-Object System.Windows.Forms.Form
$FormObjekt.Text = "Marcos Setup-Assistant $version"
$FormObjekt.Size = New-Object System.Drawing.Size (400, 600)

$FormsRemoveBloat = New-Object System.Windows.Forms.CheckBox
$FormsRemoveBloat.Checked = $false
$FormsRemoveBloat.Text = "Remove Bloatware"
$FormsRemoveBloat.Size = New-Object System.Drawing.Size (200, 20)
$FormsRemoveBloat.Location = New-Object System.Drawing.Size (50, 75)
$FormObjekt.Controls.Add($FormsRemoveBloat)

$FormLabelHeading = New-Object System.Windows.Forms.Label
$FormLabelHeading.Size = New-Object System.Drawing.Size (100, 20)
$FormLabelHeading.Location = New-Object System.Drawing.Size (0, 0)
$FormLabelHeading.Text = "Welcome!"
$FormLabelHeading.ForeColor = "Magenta"
$FormObjekt.Controls.Add($FormLabelHeading)

$FormsListBox = New-Object System.Windows.Forms.ListBox
$FormsListBox.Size = New-Object System.Drawing.Size (300, 350)
$FormsListBox.Location = New-Object System.Drawing.Size (50, 100)
$FormObjekt.Controls.Add($FormsListBox)

$FormInstallProgress = New-Object System.Windows.Forms.ProgressBar
$FormInstallProgress.Size = New-Object System.Drawing.Size (300, 30)
$FormInstallProgress.Location = New-Object System.Drawing.Size (50, 450)
$FormInstallProgress.Value = 50
$FormInstallProgress.Visible = $false
$FormObjekt.Controls.Add($FormInstallProgress)

$FormButtonToggle = New-Object System.Windows.Forms.Button
$FormButtonToggle.Size = New-Object System.Drawing.Size (100, 40)
$FormButtonToggle.Location = New-Object System.Drawing.Size (250, 500)
$FormButtonToggle.Text = "On/Off"
$FormButtonToggle.Visible = $false
$FormButtonToggle.ADD_Click{
    if ($Options[$FormsListBox.SelectedIndex] -eq "Install")
    {
        $Options[$FormsListBox.SelectedIndex] = "Skip"
    }
    elseif ($Options[$FormsListBox.SelectedIndex] -eq "Skip")
    {
        $Options[$FormsListBox.SelectedIndex] = "Install"
    }
    ListSoftware
}
$FormObjekt.Controls.Add($FormButtonToggle)

$FormButtonTest = New-Object System.Windows.Forms.Button
$FormButtonTest.Size = New-Object System.Drawing.Size (100, 40)
$FormButtonTest.Location = New-Object System.Drawing.Size (125, 500)
$FormButtonTest.Text = "Choose Programms"
$FormButtonTest.ADD_Click{
    if ($FormButtonTest.Text -eq "Install Winget")
    {
        $FormsListBox.Items.Add("Downloading winget")
        wget https://github.com/microsoft/winget-cli/releases/download/v1.0.11692/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile winget.msixbundle -UseBasicParsing
        $FormsListBox.Items.Add("Installing winget...")
        $FormsListBox.Items.Add("This may take a short time")
        Add-AppxPackage winget.msixbundle
        if ($? -eq $false)
        {
            $FormsListBox.Items.Add("Error installing winget. Maybe try again as an admin?")
        }
        else
        {
        $FormsListBox.Items.Add("Installation successfull!")   
        $FormsListBox.Items.Add("Continue by Choosing your Programms!")   
        $FormButtonTest.Text = "Choose Programms"         
        }
    }
    elseif ($FormButtonTest.Text -eq "Close")
    {
        $FormObjekt.Close()
    }
    elseif ($FormButtonTest.Text -eq "Install")
    {
        InstallProgramms
    }

    else
    {
        if ($admin -eq $false)
        {
            $Result = [System.Windows.Forms.MessageBox]::Show("No admin previleges detected. Do you want to restart with admin previleges?","Not an admin",4,[System.Windows.Forms.MessageBoxIcon]::Exclamation)
            If ($Result -eq "Yes")
            {
                $FormsListBox.Items.Add("Restarting...")
                $FormObjekt.Close()
                #if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
                #{ 
                    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
                #}
                return
            }
            else
            {
                $FormButtonToggle.Visible = $true
                ListSoftware
            }
        }
        else
        {
            $FormButtonToggle.Visible = $false
            ListSoftware
        }
    }
}
$FormObjekt.Controls.Add($FormButtonTest)

$FormLabelDescription = New-Object System.Windows.Forms.Label
$FormLabelDescription.Size = New-Object System.Drawing.Size (300, 40)
$FormLabelDescription.Location = New-Object System.Drawing.Size (0, 20)
$FormLabelDescription.Text = "This application installs the Applications every gamer needs all at once."
$FormObjekt.Controls.Add($FormLabelDescription)

winget --version
if ($? -eq $true)
{
    $WingetInstalled = $true
    $FormsListBox.Items.Add("✔️ Winget installed!")
}
else
{
    $WingetInstalled = $false
    $FormsListBox.Items.Add("❌ Winget not installed!")
    $FormsListBox.Items.Add("↪ Don't worry, We'll do it for you")
    $FormButtonTest.Text = "Install Winget"
}

if (Test-AdminRecht -eq $true)
{
    $FormsListBox.Items.Add("✔️ Administrator previleges granted!")
}
else
{
    $FormsListBox.Items.Add("❌ Not running in administrator mode")
}

function ListSoftware
{
    $FormsListBox.Items.Clear()
    $i = 0
    while ($i -lt $Programms.Count)
    {
        $FormLabelDescription.Text = "Choose your Programms"
        $FormsListBox.Items.Add($Options[$i] + " | " + $Programms[$i])
        $i++
    }
    $FormButtonTest.Text = "Install"
}

function InstallProgramms
{
    $FormsListBox.Items.Clear()
    $FormLabelDescription.Text = "Installing... I'm not frozen, I'm just busy"
    $FormButtonToggle.Visible = $false
    $FormInstallProgress.Visible = $true
    $FormInstallProgress.Maximum = $Count
    $i = 0

    if ($Debug -eq $true)
    {
        $FormsListBox.Items.Add("Not actually installing Programs (Debug)")
        while ($i -lt 10)
        {
            $FormsListBox.Items.Add("Installing Programm $i")
            Write-Host "i = $i"
            $FormInstallProgress.Value = $i
            $i++
        }    
        if ($FormsRemoveBloat.Checked -eq $true)
        {
            $FormsListBox.Items.Add("Not actually removing Bloatware...")
            $FormsListBox.Items.Add("Bloatware1")
            $FormsListBox.Items.Add("Bloatware2")
        }
    }
    else
    {
        while ($i -lt $Programms.Count)
        {
            if ($Options[$i] -eq "Install")
            {
                $FormsListBox.Items.Add("Installing " +  $Programms[$i])
                winget install $Programms[$i] -s winget -h
            }
            elseif ($Options[$i] -eq "Skip")
            {
                $FormsListBox.Items.Add("Skipping " +  $Programms[$i])
            }
            Write-Host [$i/$Count]
            $i++
        }
        $FormsListBox.Items.Add("Installation finished!")
        if ($FormsRemoveBloat.Checked -eq $true)
        {
            $FormsListBox.Items.Add("Removing Bloatware...")
            winget uninstall Microsoft.BingNews_8wekyb3d8bbwe
            winget uninstall Microsoft.BingWeather_8wekyb3d8bbwe
            winget uninstall Microsoft.GamingApp_8wekyb3d8bbwe
            winget uninstall Microsoft.MixedReality.Portal_8wekyb3d8bbwe
            winget uninstall Microsoft.People_8wekyb3d8bbwe
            winget uninstall Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe
            winget uninstall Microsoft.SkypeApp_kzf8qxf38zg5c
            winget uninstall Microsoft.Xbox.TCUI_8wekyb3d8bbwe
            winget uninstall Microsoft.XboxApp_8wekyb3d8bbwe
            winget uninstall Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe
            winget uninstall Microsoft.YourPhone_8wekyb3d8bbwe
            winget uninstall XINGAG.XING_xpfg3f7e9an52
            $FormsListBox.Items.Add("Bloat Removed! All done.")
        
        }
    }
    $FormButtonTest.Text = "Close"
}

$FormObjekt.ShowDialog()