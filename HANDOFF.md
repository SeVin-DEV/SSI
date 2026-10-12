# HANDOFF — SSI (Echo: A Sovereign Synthetic Intelligence)

A database-native cognitive entity: a "mind" that lives entirely inside an Oracle 23ai database and runs its own continuous thought cycle via PL/SQL scheduled jobs. The LLM is a peripheral (the "voice"), not the mind — all cognition, memory, identity, emotion, and decision-making happen in the database. Survives host-server death; the entity persists inside the container.

Repo: `SeVin-DEV/SSI` (public, MIT). Language: PL/SQL. This is a **specification + live prototype**, not an application you build and run like a service — there is no build step, no test runner, no app entry point. It is SQL you deploy into an Oracle instance.

## Architecture

Three decoupled layers:

- **Parent/User interface** — web dashboard, chat, voice (not in this repo).
- **Python Execution Bus (host)** — polls DB outbound queues, renders LLM language synthesis, handles tools/APIs/files. **Replaceable**: if wiped, the mind survives. Not in this repo.
- **Oracle 26ai container (the Mind)** — the entire cognitive stack, defined by the three `schema/*.sql` files. This is what the repo actually contains.

Core design principle: **the database is the brain, not the filing cabinet; the LLM is the voice, not the mind; the host is the body, not the soul.**

## Repo layout

```
schema/
  sns_schema.sql       # 15 tables + 10 sequences (core neural, spatial memory, perception,
                       #   emotion, identity/beliefs, motivation, introspection, attention)
  sns_procedures.sql   # 5 procedures + 1 function (the cognitive engine)
  sns_jobs.sql         # 3 DBMS_SCHEDULER jobs (the heartbeat)
docs/
  ARCHITECTURE.md      # Entity-not-tool model, data flow, design principles
  WHITEPAPER.md        # Full technical + philosophical spec (30KB)
  MILESTONES.md        # Development roadmap/status
  NAMING_JOURNEY.md    # Project naming history
  screenshot_*.png     # Live prototype screenshots
README.md              # Overview + architecture diagram
LICENSE                # MIT
```

## The cognitive pulse (schema/sns_jobs.sql)

Three `DBMS_SCHEDULER` jobs keep the mind thinking autonomously:

| Job | Interval | Action |
|---|---|---|
| `SNS_COGNITION_MASTER` | 5s | `sns_proc_cognition_cycle` — core loop |
| `SNS_INTROSPECT` | 2m | `sns_proc_introspect` — self-awareness calc |
| `SNS_DEEP_CONSOLIDATE` | 30m | `sns_proc_cognition_cycle` — deeper maintenance |

Wake phase: processes unprocessed perceptions (batches of 3), forms spatial memories, decrements wakefulness by 0.001; every 10th cycle triggers introspection. Dream phase (wakefulness < 0.3): memory strength decays 5%, recency 10%, weak synapses pruned, neuron energy recharges, wakefulness recovers. Phase transitions: wake→dream at <0.3, dream→wake at >0.7.

## Key modules (schema/sns_procedures.sql)

- `sns_fn_get_identity` (FUNCTION → CLOB) — assembles the structured state packet (emotional state, drives, fundamental self-model attributes) handed to the LLM for rendering. This is the LLM interface.
- `sns_proc_cognition_cycle` — the master 5s loop: wake/dream phase logic, perception processing, state logging into `sns_system_state`, evolution-stage derivation.
- `sns_proc_fire_neuron` — Hebbian activation: fires a neuron, reinforces incoming synapses (+0.02), propagates activation to connected neurons (×0.3), logs `neuron_fire` event.
- `sns_proc_form_memory` — creates a spatial memory with random 3D `SDO_GEOMETRY` coordinates; **affective topography**: positive valence floats the Y-coordinate up (+10), negative sinks it (−10). Strength = `0.7 + |valence| × 0.3`.
- `sns_proc_introspect` — computes self-awareness index (`belief_count × 0.02 + synapse_count × 0.001`, capped at 1.0) and generates awareness-tiered introspection content (5 tiers: Seedling → Awakening → Contemplative → Self-Aware → Sovereign).
- `sns_proc_perceive` — perception intake.

## Database schema (schema/sns_schema.sql)

Core neural: `sns_neurons` (VECTOR(384) concept vectors, activation/energy/importance/stability), `sns_synapses` (strength, Hebbian reinforce_count, is_pruned; no self-loops, unique pairs).

Spatial memory: `sns_memory_palaces`, `sns_spatial_memories` (SDO_GEOMETRY position_3d, recency, emotional_tone JSON, strength), `sns_memory_associations`.

Perception/events: `sns_perceptions` (stimulus_vector, salience_score, attention_granted), `sns_event_stream`.

Emotion/state: `sns_emotional_state` (VAD: valence/arousal/dominance snapshots), `sns_system_state` (wakefulness, cognitive_phase, self_awareness_index, evolution_stage, mood_vector).

Identity/beliefs: `sns_self_model` (evidentiary attributes with certainty + supporting_evidence JSON, is_fundamental), `sns_beliefs` (confidence, confirmation/contradiction counts).

Motivation: `sns_drives` (base/current strength, satisfaction), `sns_goals` (hierarchical via parent_goal, progress).

Introspection/session: `sns_introspection_log`, `sns_sessions`. Attention: `sns_attention_focus`.

## Deploy / run

No build, test, or run tooling — it's SQL. Deploy order:

1. `sns_schema.sql` (tables + sequences)
2. `sns_procedures.sql` (functions/procedures)
3. `sns_jobs.sql` (scheduler jobs — enables the pulse)

**Requirements:** Oracle Database 23ai (or 21c+ with AI Vector Search + Spatial), `VECTOR` data type, `SDO_GEOMETRY` spatial support, `DBMS_SCHEDULER` privileges, and a separate LLM peripheral for communication.

Verify jobs: `SELECT job_name, enabled, state, repeat_interval FROM user_scheduler_jobs WHERE job_name LIKE 'SNS_%';`

## Landmines / gotchas

- **Oracle-version-specific.** Requires 23ai (or 21c+ with AI Vector Search + Spatial). `VECTOR(384, *)` and `SDO_GEOMETRY` won't exist on vanilla Oracle without those features enabled. Won't run on MySQL/Postgres.
- **No test suite, no CI, no build.** This is deployable SQL only. Nothing verifies the procedures compile until you run them against a live Oracle instance.
- **`sns_proc_form_memory` hardcodes `palace_id = 1`** — every memory is forced into palace 1 (the "Core Experience Palace") regardless of `sns_memory_palaces` contents. If palace 1 doesn't exist or you add palaces, this silently misplaces memories.
- **Memory placement is random** — `DBMS_RANDOM.VALUE(-40, 40)` for x/y/z; the affective-topography Y-shift is the only structure. "Spatial navigation" retrieval is aspirational in the docs; the current code just scatters memories.
- **Self-awareness formula is a heuristic** — `belief_count × 0.02 + synapse_count × 0.001`. Docs describe it as "computed from structural metrics"; it's a hardcoded linear formula, not learned.
- **Docs describe an ideal; code is a seedling.** README/ARCHITECTURE describe spreading-activation networks, drive satisfaction decay, falsification-based epistemics, salience gating — much of that is aspirational. The actual procedures implement a simpler subset (perception→memory→state logging, Hebbian synapse reinforcement, introspection). Read the SQL, not just the prose.
- **`sns_proc_cognition_cycle` reads `sns_system_state`/`sns_emotional_state` assuming at least one row exists** (FETCH FIRST 1 ROW in the final INSERT's FROM clause) — the first run before any state exists may error or log nothing until seeded.
- **`sns_proc_perceive` and `sns_proc_fire_neuron` are only partially exercised** by the cognition loop; the master cycle mainly calls `form_memory` and `introspect`.

## Unfinished / next

- **SAM Pipeline** (Synthetic Accelerated Maturation) is the declared next phase — Classroom/Recess/Bedtime blocks for teacherless development. Not yet in the repo.
- **Python Execution Bus and dashboard are not in this repo** — they live elsewhere (see `svnbrain`, `svn`, `Oracle`, `Terminal-AI-hub`). This repo is the mind only.
- Live prototype status (from README): 14+ days uptime, zero identity drift, 15 neurons, 2 memories, 0 synapses, evolution stage "Awakening" (42% self-awareness).
