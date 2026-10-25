# Vision: poteto and Matt Pocock flow mapped onto the loops

Source: [gist-review.md](gist-review.md) (Matt Pocock x poteto transcript, rows 1 to 32, additions A1 to A7). Loops: [LP00](loops/LP00-improvement-loop.md), [LP01](loops/LP01-delivery-loop.md), [LP02](loops/LP02-event-map.md).

## Poteto flow on LP00, LP01, LP02

```mermaid
flowchart TB
  subgraph LP01[LP01 delivery]
    V1[Verify is the key skill X06 C01]
    V2[Self verify score hill climb C01 X07]
    V3[Own verification skill kept current X06]
    V1 --> V2 --> V3
    CTX[Context not control imports C05 G00a C12]
    TW[Two way vs one way door field on PBIs]
    V3 --> PR[PR path F01 verify.sh Tester]
    CTX --> PR
    TW --> PR
  end
  subgraph LP02[LP02 events and guards]
    DOOR[One way gates Sven yes on spend writes]
    SAMPLE[Sample review after merge AO10]
    DOOR --> SAMPLE
  end
  subgraph LP00[LP00 improvement]
    LINT[Repeated mistake becomes POL check A5 POL23]
    TAUT[Kill tautological checks POL23 X03]
    MEAS[Measure skill impact B03a B03]
    LINT --> TAUT --> MEAS
  end
  PR --> SAMPLE
  SAMPLE -->|revert or repeat FAIL| LINT
  MEAS -->|low value| LP01
```

| Step | Loop | Gist | PBI file(s) |
|---|---|---|---|
| Verification is the key skill | LP01 | [row 1](gist-review.md), A1 `proof:` and A2 X06 first | [done/X06-verification-skill.md](done/X06-verification-skill.md), [done/C01-verify-script.md](done/C01-verify-script.md) |
| Self verify, score, hill climbing | LP01 | [row 2](gist-review.md), A3 one line verify output | [done/C01-verify-script.md](done/C01-verify-script.md), [testing/X07-workflow-benchmark.md](testing/X07-workflow-benchmark.md) |
| Own verification skill per app | LP01 | [row 3](gist-review.md), A2 | [done/X06-verification-skill.md](done/X06-verification-skill.md) |
| Repeated mistake becomes a lint | LP00 | [row 8](gist-review.md), A5 findings rule | [done/POL23-no-tautological-checks.md](done/POL23-no-tautological-checks.md), [README.md](README.md) (findings rule) |
| Context not control | LP01 | [row 13](gist-review.md), A7 Bar H | [done/C05-imports-import-schema.md](done/C05-imports-import-schema.md), [done/G00a-consumer-strategy.md](done/G00a-consumer-strategy.md), [done/C12-agentpacks-import-contract.md](done/C12-agentpacks-import-contract.md) |
| Two way vs one way doors | LP02 | [row 23](gist-review.md), A1 `door:` | [_template.md](_template.md), [README.md](README.md) |
| Kill tautological tests | LP00 | [row 26](gist-review.md), A4 | [done/POL23-no-tautological-checks.md](done/POL23-no-tautological-checks.md), [done/X03-gate-fixtures.md](done/X03-gate-fixtures.md) |
| Sample review, fix env on repeats | LP02 | [row 20](gist-review.md), A5 | [agent-ops/AO10-sampled-human-review.md](agent-ops/AO10-sampled-human-review.md) |
| Measure skill impact | LP00 | [row 31](gist-review.md), A6 | [observability/B03a-value-vs-cost.md](observability/B03a-value-vs-cost.md), [observability/B03-outcomes-impact.md](observability/B03-outcomes-impact.md) |

Later batch (paused until Sven's go): the Software Factory layer map and the harness items from the 2026-10-25 links.
