[cmdletBinding()]
param(
    [parameter(ValueFromPipeline=$true)]
    [object[]]$Servidor,

    [switch]$all
)

BEGIN {
    
   
}
PROCESS{

    $props = @{}
    $jobs = @()
    if ($all){
        $servidores = Get-SESUMServerInfo -All
    }

    foreach ($computador in $servidores){
        $jobs += Invoke-Command -ScriptBlock {Get-Date} -ComputerName $computador.IP -Credential $computador.Credencial -AsJob
    }

   
    While($jobs) {
        foreach ($job in $jobs){
            if ($job.State -eq 'Completed'){
                $result = $job | Receive-Job
                $props = @{'Servidor' = $job.Location
                            'Data' = $result}
                $obj = New-Object -TypeName psobject -Property $props
                $obj | Format-Table -Property Servidor,'Data'
                $job | Remove-Job
            }
            elseif($job.State -eq 'Failed'){
                $props = @{
                    'Servidor' = $job.Location
                    'Data/Hora'  = "Falha"
                }
                $obj = New-Object -TypeName psobject -Property $props
                $obj | Format-Table -Property Servidor,'Data'
                $job | Remove-Job
            }
        }
        $jobs = Get-Job
    }
 
   
}

END{
  
}