---
description: Private NuGet feed. Pre-agent step adds the feed with a secret token and restores, so build and test resolve private packages. Skips when the repo has no C# project.
network:
  allowed: [dotnet]
steps:
  - name: Authenticate private NuGet feed and restore
    env:
      NUGET_FEED_URL: ${{ vars.NUGET_FEED_URL }}
      NUGET_FEED_USER: ${{ vars.NUGET_FEED_USER }}
      NUGET_FEED_TOKEN: ${{ secrets.NUGET_FEED_TOKEN }}
    shell: pwsh
    run: |
      $ErrorActionPreference = 'Stop'
      if (-not (git ls-files '*.sln' '*.slnx' '*.csproj')) {
        Write-Host 'No C# project, skipping NuGet setup'
        exit 0
      }
      if ($env:NUGET_FEED_URL -and $env:NUGET_FEED_TOKEN) {
        $user = if ($env:NUGET_FEED_USER) { $env:NUGET_FEED_USER } else { 'token' }
        dotnet nuget add source $env:NUGET_FEED_URL --name private-feed --username $user --password $env:NUGET_FEED_TOKEN --store-password-in-clear-text
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
      } else {
        Write-Host 'NUGET_FEED_URL or NUGET_FEED_TOKEN not set, restoring from public sources only'
      }
      $targets = @(git ls-files '*.sln' '*.slnx')
      if (-not $targets) { $targets = @(git ls-files '*.csproj') }
      try {
        foreach ($t in $targets) {
          dotnet restore $t
          if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        }
      } finally {
        # Packages are cached now. Drop the source so the token is not on disk while the agent runs.
        if ($env:NUGET_FEED_URL -and $env:NUGET_FEED_TOKEN) { dotnet nuget remove source private-feed }
      }
---

A pre-agent step authenticated the private NuGet feed and ran `dotnet restore`, so `dotnet build` and `dotnet test` resolve private packages. The feed source and its token were removed afterwards, so the agent cannot restore new private packages: build and test with the cached ones, and for a missing package post a `Builder question:` instead. Do not write feed credentials anywhere or read them from the environment.
