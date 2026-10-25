---
description: agentPacks squad skill, pinned to a 40-hex SHA (C12 v1.1; tags replace the SHA when agentPacks tags exist).
skills:
  - svennijhuis/agentPacks/plugins/squad/skills/squad@34e1dec3535baa1d77cb441ea8c98498dc9b3684
---

`skills:` installs the agentPacks `squad` skill in the activation job. `plugins:` is not used: a plugins pin at a main SHA loads zero agents (C12 correction), and POL01 accepts plugins only at a vX.Y.Z tag. Do not paste skills or agents into `prompts/`.
