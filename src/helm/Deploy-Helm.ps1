param (
    [Parameter(Mandatory=$false)]
    [switch] $TestRun
)

if($TestRun){
    Helm-Local install --debug --dry-run --set image.tag=1.0.13 .\kubernetespoc\
} else {
    Helm-Local install --debug --set image.tag=1.0.13 .\kubernetespoc\
}