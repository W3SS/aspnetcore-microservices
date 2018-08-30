param(
    [Parameter(Mandatory=$false)]
    [switch] $SkipBuild,
    [Parameter(Mandatory=$false)]
    [string] $DockerRegistry = "localhost:5000",
    [Parameter(Mandatory=$false)]
    [string] $Version = "1.0.2"
)

if( -not($SkipBuild)){
    docker build -t $DockerRegistry/kubernetespocs-api:$Version ../ -f ../Kubernetes.POCS.Api/Dockerfile
    docker push $DockerRegistry/kubernetespocs-api:$Version
}

"Creating namespace" | Write-Host -ForegroundColor Yellow
Kubectl-Local apply -f "$PSScriptRoot/namespaces"
"Successfull created namespace" | Write-Host -ForegroundColor Green


"Copy deployments to backup location" | Write-Verbose
$invocation = (Get-Variable MyInvocation).Value
$currentPath = Split-Path $invocation.MyCommand.Path

if(Test-Path (Join-Path $currentPath "expanded-deployments")) {
    "Removing expanded-deployments"  | Write-Host -ForegroundColor Yellow
    Remove-Item -Path (Join-Path $currentPath "expanded-deployments") -Force -Recurse -ErrorAction SilentlyContinue
    "Cleaned up old deployments" | Write-Host
}
Copy-Item -Recurse -Path (Join-Path $currentPath "deployments") -Destination (Join-Path $currentPath "expanded-deployments")

Get-ChildItem -Recurse -Path (Join-Path $currentPath "expanded-deployments") -Filter "*.deployment.yml" | ForEach-Object {
    $expandedContent = $ExecutionContext.InvokeCommand.ExpandString((Get-Content $_.FullName | Out-String))
    Set-Content -Path $_.FullName -Value $expandedContent
}

"Configuring configmaps" | Write-Host -ForegroundColor Yellow
Kubectl-Local apply -f "$PSScriptRoot/configmaps"
"Use the command 'KubeCtl-Local describe configmap kubernetespoc-api-config -n samplepocs' to list the configmap values"
"Successfully configured configmaps" | Write-Host -ForegroundColor Green

"Configuring secrets" | Write-Host -ForegroundColor Yellow
Kubectl-Local apply -f "$PSScriptRoot/secrets"
"Use the command 'KubeCtl-Local describe secret kubernetespoc-api-secret -n samplepocs' to list the secret values"
"Successfully configured secrets" | Write-Host -ForegroundColor Green

"Creating deployments" | Write-Host -ForegroundColor Yellow
Kubectl-Local apply -f "$PSScriptRoot/expanded-deployments"
"Successfully configured deployments" | Write-Host -ForegroundColor Green

"Creating services" | Write-Host -ForegroundColor Yellow
Kubectl-Local apply -f "$PSScriptRoot/services"
"Service can be accessed by using the url http://localhost:8001/api/v1/namespaces/samplepocs/services/kubernetespocs-api/proxy/api/values by running kubectl proxy" | Write-Host
"Successfully configured services" | Write-Host -ForegroundColor Green

"Configuring ingress" | Write-Host -ForegroundColor Yellow
Kubectl-Local apply -f "$PSScriptRoot/ingress"
"Service can be accessed by using the url http://localhost/kubernetespoc/api/values" | Write-Host
"Successfully configured ingress" | Write-Host -ForegroundColor Green

if(Test-Path (Join-Path $currentPath "expanded-deployments")) {
    "Removing expanded-deployments"  | Write-Host -ForegroundColor Blue
    Remove-Item -Path (Join-Path $currentPath "expanded-deployments") -Force -Recurse
}