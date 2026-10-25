---
description: agentPacks review stack (squad skill + squad plugin agents). Pinned SHA, no copies.
skills:
  - svennijhuis/agentPacks/plugins/squad/skills/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684
plugins:
  - svennijhuis/agentPacks/plugins/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684
---

`skills:` installs `squad` in the activation job (`disable-model-invocation`). `plugins:` brings the agents (`squad-reviewer`, `squad-simplifier`, `squad-security-reviewer`, `squad-orchestrator`).

Do not paste these skills or agents into `prompts/`.
