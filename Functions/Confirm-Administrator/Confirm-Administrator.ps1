Function Confirm-Administrator {
    #Function Version 1.1
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )
    if($currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator ))
    {
        return $true 
    }
    else 
    {
        return $false 
    }
}