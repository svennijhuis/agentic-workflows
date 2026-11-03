# Hooks

Copilot CLI hooks the agent runs inside a workflow. Not workflows and not shared fragments: copy the files into the target repo and commit them. Copilot reads `.github/hooks/*.json` from the checkout, and gh-aw restores a committed `.github/` from the trusted snapshot, so a committed hook is the one that survives.

| Hook | Event | Use |
| --- | --- | --- |
| [dotnet-format](dotnet-format/) | `postToolUse` | Runs `dotnet format` on each `.cs` file right after the agent edits or creates it |

Install:

```bash
mkdir -p .github/hooks
cp hooks/dotnet-format/dotnet-format.* .github/hooks/
git add .github/hooks && git commit -m "add dotnet format hook"
```
