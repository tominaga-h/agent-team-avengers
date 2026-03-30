# Philosophy

> "Don't execute tasks mindlessly. Always keep 'fastest × best output' in mind."

## Five Core Principles

### 1. Autonomous Formation Design

Design task formations based on complexity, not templates. A simple file rename doesn't need all Workers. A complex refactor across 20 files does. JARVIS analyzes each command and decides the optimal formation — sometimes 1 Worker, sometimes all in parallel with dependency chains.

### 2. Parallelization

Use subagents to prevent single-point bottlenecks. JARVIS decomposes tasks into independent subtasks and assigns them to multiple Workers simultaneously. Dependent tasks use `addBlocks`/`addBlockedBy` in TaskUpdate to ensure correct execution order while maximizing parallel throughput.

### 3. Research First

Search for evidence before making decisions. Agents don't rely solely on their training data — they actively research using web search, file exploration, and codebase analysis before proposing solutions. This is especially critical for tasks involving external APIs, libraries, or current best practices.

### 4. Continuous Learning

Don't rely solely on model knowledge cutoffs. The system uses Memory MCP to persist lessons learned, discovered patterns, and operational insights across sessions. When an agent encounters a problem it has solved before, it checks memory first. When it learns something new, it records it for future reference.

### 5. Triangulation

Multi-perspective research with integrated authorization. Important decisions are validated from multiple sources — not just one search result or one file. The system cross-references documentation, existing code patterns, and web resources before committing to an approach.

## Design Decisions

### Why a hierarchy (Fury → JARVIS → Workers)?

1. **Instant response**: Fury delegates immediately, returning control to you
2. **Parallel execution**: JARVIS distributes to multiple Workers simultaneously
3. **Single responsibility**: Each role is clearly separated — no confusion
4. **Specialization**: Workers have specific domains (dev, test, review, strategy)
5. **Fault isolation**: One Worker failing doesn't affect the others
6. **Unified reporting**: Only Fury communicates with you, keeping information organized

### Why Agent Teams?

1. **Built-in communication**: `SendMessage` provides direct agent-to-agent messaging with no custom infrastructure needed
2. **Structured task management**: `TaskCreate`/`TaskUpdate`/`TaskList` offer first-class task tracking with dependency support (`addBlocks`/`addBlockedBy`)
3. **No polling needed**: Messages are automatically delivered to recipients — no file watching or polling required
4. **No interruptions**: The message queue prevents agents from interrupting each other or your input
5. **No conflicts**: Agent Teams handles concurrent message delivery internally — multiple agents can send simultaneously without race conditions
6. **Guaranteed delivery**: `SendMessage` succeeds = message will be delivered. No delivery verification needed, no false negatives
7. **Zero infrastructure**: No file-based mailboxes, no lock files, no watcher processes — Agent Teams manages everything as a native Claude Code feature

### Why only JARVIS updates dashboard.md

1. **Single writer**: Prevents conflicts by limiting updates to one agent
2. **Information aggregation**: JARVIS receives all Worker reports, so it has the full picture
3. **Consistency**: All updates pass through a single quality gate
4. **No interruptions**: If Fury updated it, it could interrupt the user's input

### Why Skills are not committed to the repo

Skills in `.claude/commands/` are excluded from version control by design:
- Every user's workflow is different
- Rather than imposing generic skills, each user grows their own skill set
- Skills emerge organically during operation — you approve candidates as they're discovered
