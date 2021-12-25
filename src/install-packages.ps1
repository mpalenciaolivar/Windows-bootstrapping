# Installing scoop
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
iwr -useb get.scoop.sh | iex

# Importing software list
$CSV = Import-CSV -Path "..\resources\software-list.csv" -Delimiter ","

# Adding repositories
scoop bucket add extras
scoop bucket add java

$LIST = [System.Collections.ArrayList]@()
Foreach($ROW in $CSV)
{
    If(
	($ROW.Username -ne "ScoopInstaller") -and
	(-not ($ROW.Username -in $LIST))
    )
    {
	Try
	{
	    scoop bucket add $ROW.Username $ROW.URL
	}
	Catch
	{
	    Write-Output "Could not add the following repository:" $ROW.Username
	}
	Finally
	{
	    $LIST += $ROW.Username
	}
    }
}

scoop update

# Installing software
$MISSING = [System.Collections.ArrayList]@()
Foreach($ROW in $CSV)
{
    Try
    {
	$SOFTWARE = [string]::Format("{0}@{1}", $ROW.Name, $ROW.Version)
	Invoke-Expression -Command "scoop install $args[0]" -ArgumentList $SOFTWARE
    }
    Catch
    {
	$MISSING += $SOFTWARE
    }
}

If($MISSING.count -gt 0)
{
    Write-Output "The following software is missing:"
    Foreach($NAME in $MISSING)
    {
	Write-Output $NAME
    }
}
