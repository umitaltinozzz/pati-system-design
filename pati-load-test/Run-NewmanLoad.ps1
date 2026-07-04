param(
  [ValidateSet(1000, 5000, 10000)]
  [int]$TotalIterations = 1000,
  [ValidateRange(1, 100)]
  [int]$Workers = 10,
  [ValidateSet('01 Read-only Load Path', '02 Authenticated Read Path', '99 Write Path — EXPLICIT OPT-IN')]
  [string]$Folder = '01 Read-only Load Path',
  [switch]$AllowWrites
)

$ErrorActionPreference = 'Stop'

if ($Folder -like '99*' -and -not $AllowWrites) {
  throw 'Write path requires -AllowWrites and an isolated staging database.'
}

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
  throw 'Node.js/npx is required.'
}

$collection = Join-Path $PSScriptRoot 'Pati-Load-Test.postman_collection.json'
$environment = Join-Path $PSScriptRoot 'Pati-Staging.postman_environment.json'
$reportRoot = Join-Path $PSScriptRoot ('reports\' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force -Path $reportRoot | Out-Null

$base = [math]::Floor($TotalIterations / $Workers)
$remainder = $TotalIterations % $Workers
$processes = @()

for ($worker = 0; $worker -lt $Workers; $worker++) {
  $iterations = $base + $(if ($worker -lt $remainder) { 1 } else { 0 })
  if ($iterations -eq 0) { continue }

  $jsonReport = Join-Path $reportRoot ("worker-{0:D3}.json" -f $worker)
  $stdout = Join-Path $reportRoot ("worker-{0:D3}.out.log" -f $worker)
  $stderr = Join-Path $reportRoot ("worker-{0:D3}.err.log" -f $worker)
  $args = @(
    '--yes', 'newman', 'run', $collection,
    '--environment', $environment,
    '--folder', $Folder,
    '--iteration-count', $iterations,
    '--env-var', "workerId=$worker",
    '--reporters', 'cli,json',
    '--reporter-json-export', $jsonReport,
    '--bail', 'failure'
  )

  $processes += Start-Process -FilePath 'npx' -ArgumentList $args -PassThru -WindowStyle Hidden -RedirectStandardOutput $stdout -RedirectStandardError $stderr
}

$processes | Wait-Process
$failed = @($processes | Where-Object { $_.ExitCode -ne 0 })
$summary = [ordered]@{
  totalIterations = $TotalIterations
  workers = $Workers
  folder = $Folder
  startedReports = $processes.Count
  failedWorkers = $failed.Count
  reportDirectory = $reportRoot
}
$summary | ConvertTo-Json | Tee-Object -FilePath (Join-Path $reportRoot 'summary.json')

if ($failed.Count -gt 0) { exit 1 }

