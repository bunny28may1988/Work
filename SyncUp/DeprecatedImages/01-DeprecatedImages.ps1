#!/usr/bin/env pwsh

param (
    [Parameter(Mandatory = $true)]
    [string] $accountUrl,

    [Parameter(Mandatory = $true)]
    [string] $pat,

    [Parameter(Mandatory = $false)]
    [string] $continuationToken
)

# Create the VSTS auth header
$base64authinfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))
$vstsAuthHeader = @{"Authorization"="Basic $base64authinfo"}
$allHeaders = $vstsAuthHeader + @{"Content-Type"="application/json"; "Accept"="application/json"}

# List of deprecated images
[string[]] $deprecatedImages = 'macOS-10.15', 'macOS 10.15', 'MacOS 1015', 'MacOS-1015', 'Ubuntu18', 'ubuntu-18.04', 'Ubuntu20', 'ubuntu-20.04', 'ubuntu 20.04', 'VS2017', 'vs2017 win2016', 'vs2017-win2016', 'windows-2016-vs2017'

try
{
    $result = Invoke-WebRequest -Headers $allHeaders -Method GET "$accountUrl/_apis/DistributedTask/pools?api-version=6.1-preview"
    if ($result.StatusCode -ne 200)
    {
        Write-Output $result.Content
        throw "Failed to query pools"
    }
    $resultJson = ConvertFrom-Json $result.Content
    $azurePipelinesPoolId = 0
    foreach($pool in $resultJson.value)
    {
        if ($pool.name -eq "Azure Pipelines")
        {
            $azurePipelinesPoolId = $pool.id
            break
        }
    }

    if ($azurePipelinesPoolId -eq 0)
    {
        throw "Failed to find Azure Pipelines pool"
    }
    
    Write-Host ("Azure Pipelines Pool Id: " + $azurePipelinesPoolId + "`n")
    $msg = 'Query next 200 jobs? (y/n)'
    $response = 'y'
    $hashJobsToDef = @{}
    do
    {
        Write-Output ("Querying next 200 jobs with continuation token:`n" + $continuationToken + "`n")

        if (!$continuationToken)
        {
            $result = Invoke-WebRequest -Headers $allHeaders -Method GET "$accountUrl/_apis/DistributedTask/pools/$($azurePipelinesPoolId)/jobrequests?api-version=5.0-preview&`$top=200"
        }
        else
        {
            $result = Invoke-WebRequest -Headers $allHeaders -Method GET "$accountUrl/_apis/DistributedTask/pools/$($azurePipelinesPoolId)/jobrequests?api-version=5.0-preview&`$top=200&continuationToken=$($continuationToken)"
        }

        if ($result.StatusCode -ne 200)
        {
            Write-Output $result.Content
            throw "Failed to query jobs"
        }
        $continuationToken = $result.Headers.'X-MS-ContinuationToken'
        $resultJson = ConvertFrom-Json $result.Content

        if ($resultJson.value.count -eq 0)
        {
            Write-Output "Done`n"
            Write-Output "List of definitions targeting deprecated images:`n"
            Write-Output $hashJobsToDef
            break
        }
        else
        {
            foreach($job in $resultJson.value)
            {
                if ($job.agentSpecification -and
                    $job.agentSpecification.VMImage -and
                    ($job.agentSpecification.VMImage -imatch ($deprecatedImages -join '|')))
                {
                    Write-Output ("Found deprecated image: " + $job.agentSpecification.VMImage + "being used in  below pipeline" + "`n")
                    #$hashJobsToDef[$job.definition.name] = $job.definition._links.web.href
                    $hashJobsToDef[$job.definition.name] = @{
                        "Image" = $job.agentSpecification.VMImage
                        "Url" = $job.definition._links.web.href
                            }
                        } 
            }

            Write-Output "Current list of definitions targeting deprecated images:`n"
            Write-Output $hashJobsToDef
            Write-Output "`n"
        }
    } while ($continuationToken)
}
catch {
    throw "Failed to query jobs: $_"
}