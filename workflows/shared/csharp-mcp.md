---
description: Local C# MCP server over stdio, started from a project in the checked-out repo. Import with `with:` for the server name, project path and a one-line purpose. Not imported by default.
import-schema:
  name:
    type: string
    description: "MCP server name, kebab-case. The agent sees its tools under this name."
  project:
    type: string
    description: "Path to the server project, relative to the repo root. Example: `tools/MyMcp`."
  purpose:
    type: string
    description: "One sentence: what the server is for and when to call it."
mcp-servers:
  ${{ github.aw.import-inputs.name }}:
    command: dotnet
    args: ["run", "--project", "${{ github.aw.import-inputs.project }}"]
    allowed: ["*"]
network:
  allowed: [dotnet]
---

The `${{ github.aw.import-inputs.name }}` MCP server is available: ${{ github.aw.import-inputs.purpose }} Call its tools for that instead of guessing from the code. It is built from `${{ github.aw.import-inputs.project }}` in this repo, using the private NuGet feed set up before the run.
