# K8s-Prac Helm Deployment Script
# Usage: .\deploy.ps1 -Environment dev|staging|prod [-Release release-name] [-Action install|upgrade|uninstall]

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment,
    
    [string]$Release = "k8s-prac-$Environment",
    
    [ValidateSet("install", "upgrade", "uninstall", "status", "test")]
    [string]$Action = "install",
    
    [string]$Namespace = "default",
    
    [switch]$DryRun,
    
    [switch]$Debug
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"

function Write-ColorOutput {
    param($Color, $Message)
    Write-Host $Message -ForegroundColor $Color
}

function Show-Header {
    Write-ColorOutput $Blue "=================================="
    Write-ColorOutput $Blue "  K8s-Prac Helm Deployment"
    Write-ColorOutput $Blue "=================================="
    Write-ColorOutput $Yellow "Environment: $Environment"
    Write-ColorOutput $Yellow "Release: $Release"
    Write-ColorOutput $Yellow "Action: $Action"
    Write-ColorOutput $Yellow "Namespace: $Namespace"
    Write-ColorOutput $Blue "=================================="
}

function Test-Prerequisites {
    Write-ColorOutput $Yellow "Checking prerequisites..."
    
    # Check if kubectl is available
    try {
        kubectl version --client | Out-Null
        Write-ColorOutput $Green "✓ kubectl is available"
    }
    catch {
        Write-ColorOutput $Red "✗ kubectl not found. Please install kubectl."
        exit 1
    }
    
    # Check if helm is available
    try {
        helm version | Out-Null
        Write-ColorOutput $Green "✓ Helm is available"
    }
    catch {
        Write-ColorOutput $Red "✗ Helm not found. Please install Helm."
        exit 1
    }
    
    # Check cluster connectivity
    try {
        kubectl cluster-info | Out-Null
        Write-ColorOutput $Green "✓ Kubernetes cluster is accessible"
    }
    catch {
        Write-ColorOutput $Red "✗ Cannot connect to Kubernetes cluster"
        exit 1
    }
    
    # Check if values file exists
    $valuesFile = "values-$Environment.yaml"
    if (Test-Path $valuesFile) {
        Write-ColorOutput $Green "✓ Values file found: $valuesFile"
    }
    else {
        Write-ColorOutput $Red "✗ Values file not found: $valuesFile"
        exit 1
    }
}

function Invoke-HelmLint {
    Write-ColorOutput $Yellow "Linting Helm chart..."
    try {
        helm lint . --values "values-$Environment.yaml"
        Write-ColorOutput $Green "✓ Helm chart validation passed"
    }
    catch {
        Write-ColorOutput $Red "✗ Helm chart validation failed"
        exit 1
    }
}

function Invoke-HelmInstall {
    $valuesFile = "values-$Environment.yaml"
    $command = "helm install $Release . -f $valuesFile --namespace $Namespace"
    
    if ($DryRun) {
        $command += " --dry-run"
        Write-ColorOutput $Yellow "DRY RUN MODE - No changes will be made"
    }
    
    if ($Debug) {
        $command += " --debug"
    }
    
    Write-ColorOutput $Yellow "Installing release: $Release"
    Write-ColorOutput $Blue "Command: $command"
    
    try {
        Invoke-Expression $command
        if (-not $DryRun) {
            Write-ColorOutput $Green "✓ Release $Release installed successfully"
        }
    }
    catch {
        Write-ColorOutput $Red "✗ Failed to install release $Release"
        exit 1
    }
}

function Invoke-HelmUpgrade {
    $valuesFile = "values-$Environment.yaml"
    $command = "helm upgrade $Release . -f $valuesFile --namespace $Namespace"
    
    if ($DryRun) {
        $command += " --dry-run"
        Write-ColorOutput $Yellow "DRY RUN MODE - No changes will be made"
    }
    
    if ($Debug) {
        $command += " --debug"
    }
    
    Write-ColorOutput $Yellow "Upgrading release: $Release"
    Write-ColorOutput $Blue "Command: $command"
    
    try {
        Invoke-Expression $command
        if (-not $DryRun) {
            Write-ColorOutput $Green "✓ Release $Release upgraded successfully"
        }
    }
    catch {
        Write-ColorOutput $Red "✗ Failed to upgrade release $Release"
        exit 1
    }
}

function Invoke-HelmUninstall {
    Write-ColorOutput $Yellow "Uninstalling release: $Release"
    
    if ($DryRun) {
        Write-ColorOutput $Yellow "DRY RUN MODE - Would uninstall: $Release"
        return
    }
    
    try {
        helm uninstall $Release --namespace $Namespace
        Write-ColorOutput $Green "✓ Release $Release uninstalled successfully"
    }
    catch {
        Write-ColorOutput $Red "✗ Failed to uninstall release $Release"
        exit 1
    }
}

function Get-HelmStatus {
    Write-ColorOutput $Yellow "Getting status for release: $Release"
    
    try {
        helm status $Release --namespace $Namespace
        Write-ColorOutput $Green "✓ Status retrieved successfully"
    }
    catch {
        Write-ColorOutput $Red "✗ Failed to get status for release $Release"
        exit 1
    }
}

function Invoke-HelmTest {
    Write-ColorOutput $Yellow "Running tests for release: $Release"
    
    try {
        helm test $Release --namespace $Namespace
        Write-ColorOutput $Green "✓ Tests completed successfully"
    }
    catch {
        Write-ColorOutput $Red "✗ Tests failed for release $Release"
        exit 1
    }
}

function Show-PostDeploymentInfo {
    Write-ColorOutput $Blue "`n=================================="
    Write-ColorOutput $Green "  Deployment Summary"
    Write-ColorOutput $Blue "=================================="
    
    Write-ColorOutput $Yellow "`nUseful commands:"
    Write-ColorOutput $White "# Check pods:"
    Write-ColorOutput $White "kubectl get pods -l app.kubernetes.io/instance=$Release"
    
    Write-ColorOutput $White "`n# Check services:"
    Write-ColorOutput $White "kubectl get svc -l app.kubernetes.io/instance=$Release"
    
    Write-ColorOutput $White "`n# View logs:"
    Write-ColorOutput $White "kubectl logs -l app.kubernetes.io/instance=$Release -f"
    
    Write-ColorOutput $White "`n# Get application URL (NodePort):"
    Write-ColorOutput $White "`$NODE_PORT = kubectl get --namespace $Namespace -o jsonpath=`"{.spec.ports[0].nodePort}`" services $Release"
    Write-ColorOutput $White "`$NODE_IP = kubectl get nodes --namespace $Namespace -o jsonpath=`"{.items[0].status.addresses[0].address}`""
    Write-ColorOutput $White "Write-Host `"Application URL: http://`$NODE_IP`:$NODE_PORT`""
    
    Write-ColorOutput $White "`n# Helm operations:"
    Write-ColorOutput $White "helm status $Release"
    Write-ColorOutput $White "helm history $Release"
    Write-ColorOutput $White "helm rollback $Release"
    
    Write-ColorOutput $Blue "`n=================================="
}

# Main execution
try {
    Show-Header
    
    # Change to chart directory
    $chartPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    Set-Location $chartPath
    
    Test-Prerequisites
    
    switch ($Action) {
        "install" {
            Invoke-HelmLint
            Invoke-HelmInstall
            if (-not $DryRun) {
                Start-Sleep -Seconds 5
                Show-PostDeploymentInfo
            }
        }
        "upgrade" {
            Invoke-HelmLint
            Invoke-HelmUpgrade
            if (-not $DryRun) {
                Start-Sleep -Seconds 5
                Show-PostDeploymentInfo
            }
        }
        "uninstall" {
            Invoke-HelmUninstall
        }
        "status" {
            Get-HelmStatus
        }
        "test" {
            Invoke-HelmTest
        }
    }
    
    Write-ColorOutput $Green "`n✓ Action '$Action' completed successfully!"
}
catch {
    Write-ColorOutput $Red "`n✗ Error occurred: $_"
    exit 1
}
