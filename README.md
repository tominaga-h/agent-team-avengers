# Avengers Multi-Agent System

<div align="center">

**Multi-Agent Orchestration System for Claude Code**

*One command. Multiple AI agents working in parallel via Agent Teams.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude-Code-blueviolet)](https://claude.ai)
[![tmux](https://img.shields.io/badge/tmux-required-green)](https://github.com/tmux/tmux)

[English](README.md) | [Japanese / 日本語](README_ja.md)

</div>

> **Fork notice:** This repository is a fork of [yohey-w/multi-agent-shogun](https://github.com/yohey-w/multi-agent-shogun).
> See [CHANGELOG.md](CHANGELOG.md) for changes since the fork.

---

## What is this?

**agent-team-avengers** is a system that runs multiple Claude Code instances simultaneously using **Agent Teams**, organized like an MCU Avengers team.

**Why use this?**
- Give one command, get multiple AI workers executing in parallel
- Built on Claude Code's **Agent Teams** — agents communicate via SendMessage/TaskCreate
- No waiting — you can keep giving commands while tasks run in background
- AI remembers your preferences across sessions (Memory MCP)
- Real-time progress tracking via dashboard

```
        You (Hayato)
             │
             ▼ Give orders
      ┌─────────────┐
      │    FURY     │  ← Receives your command, delegates immediately
      └──────┬──────┘
             │ Agent Teams API
      ┌──────▼──────┐
      │   JARVIS    │  ← Distributes tasks to workers
      └──────┬──────┘
             │
    ┌────────┼────────┐
    ▼        ▼        ▼
┌────────┐ ┌──────────────┐
│ BRUCE  │ │Tony│Peter│...│  ← Workers execute in parallel
│(Review)│ └──────────────┘
└────────┘    WORKERS
```

---

## 🚀 Quick Start

### 🪟 Windows Users (Most Common)

<table>
<tr>
<td width="60">

**Step 1**

</td>
<td>

📥 **Download this repository**

[Download ZIP](https://github.com/marucc/agent-team-avengers/archive/refs/heads/main.zip) and extract to `C:\tools\agent-team-avengers`

*Or use git:* `git clone https://github.com/marucc/agent-team-avengers.git C:\tools\agent-team-avengers`

</td>
</tr>
<tr>
<td>

**Step 2**

</td>
<td>

🖱️ **Run `install.bat`**

Right-click and select **"Run as administrator"** (required if WSL2 is not yet installed). The installer will guide you through each step — you may need to restart your PC or set up Ubuntu before re-running.

</td>
</tr>
<tr>
<td>

**Step 3**

</td>
<td>

✅ **Done!** AI agents are now running.

</td>
</tr>
</table>

#### 📅 Daily Startup (After First Install)

Open **Ubuntu terminal** (WSL) and run from your **project directory**:

```bash
cd /mnt/c/your-project
/mnt/c/tools/agent-team-avengers/assemble.sh
```

#### 🔐 First-Time Authentication (One Time Only)

1. After running `./assemble.sh`, a login screen appears in each pane
2. **In just ONE pane**, copy the URL and open it in your browser to log in
3. After authentication, press `Ctrl+C` in other panes and re-run `claude --dangerously-skip-permissions`
4. Credentials are saved to `~/.claude/` and won't be needed again

> **Note:** You don't need to log in separately on every pane.

---

<details>
<summary>🐧 <b>Linux / Mac Users</b> (Click to expand)</summary>

### First-Time Setup

```bash
# 1. Clone the repository
git clone https://github.com/marucc/agent-team-avengers.git ~/agent-team-avengers
cd ~/agent-team-avengers

# 2. Make scripts executable
chmod +x *.sh

# 3. Run first-time setup
./first_setup.sh
```

### Daily Startup

```bash
cd ~/your-project
~/agent-team-avengers/assemble.sh
```

</details>

---

<details>
<summary>❓ <b>What is WSL2? Why do I need it?</b> (Click to expand)</summary>

### About WSL2

**WSL2 (Windows Subsystem for Linux)** lets you run Linux inside Windows. This system uses `tmux` (a Linux tool) to manage multiple AI agents, so WSL2 is required on Windows.

### Don't have WSL2 yet?

No problem! When you run `install.bat`, it will:
1. Check if WSL2 is installed
2. If not, show you exactly how to install it
3. Guide you through the entire process

**Quick install command** (run in PowerShell as Administrator):
```powershell
wsl --install
```

Then restart your computer and run `install.bat` again.

</details>

---

<details>
<summary>📋 <b>Script Reference</b> (Click to expand)</summary>

| Script | Purpose | When to Run |
|--------|---------|-------------|
| `install.bat` | Windows: First-time setup (runs first_setup.sh via WSL) | First time only |
| `first_setup.sh` | Installs tmux, Node.js, Claude Code CLI + configures Memory MCP | First time only |
| `assemble.sh` | Creates `.avengers/` + tmux sessions + starts Claude Code | Every day (run from project dir) |

### What `install.bat` does automatically:
- ✅ Checks if WSL2 is installed
- ✅ Opens Ubuntu and runs `first_setup.sh`
- ✅ Installs tmux, Node.js, and Claude Code CLI
- ✅ Creates necessary directories
- ✅ Configures Memory MCP server (for cross-session memory)

### What `assemble.sh` does:
- ✅ Creates `.avengers/` directory in your project (dashboard, logs, wrapper scripts)
- ✅ Creates tmux sessions (`fury-<project>` + `avengers-<project>`)
- ✅ Launches Claude Code with Agent Teams enabled
- ✅ Automatically loads instruction files for each agent
- ✅ Sets up the team hierarchy (Fury → JARVIS → Workers)

**After running, all agents are ready to receive commands immediately!**

</details>

---

<details>
<summary>🔧 <b>Prerequisites (for manual setup)</b> (Click to expand)</summary>

If you prefer to install dependencies manually:

| Requirement | How to install | Notes |
|-------------|----------------|-------|
| WSL2 + Ubuntu | `wsl --install` in PowerShell | Windows only |
| Set Ubuntu as default | `wsl --set-default Ubuntu` | Required for scripts to work |
| tmux | `sudo apt install tmux` | Terminal multiplexer |
| Node.js v20+ | `nvm install 20` | Required for Claude Code CLI |
| Claude Code CLI | `npm install -g @anthropic-ai/claude-code` | Anthropic's official CLI |

</details>

---

### ✅ What Happens After Setup

After running either option, AI agents will start automatically:

| Agent | Role | Quantity |
|-------|------|----------|
| 🛡️ Nick Fury | Director — receives your orders | 1 |
| 🤖 JARVIS | AI Assistant — distributes tasks | 1 |
| 🧪 Bruce Banner | Strategist — quality assurance & analysis | 1 |
| ⚡ Workers | Specialists — execute tasks in parallel | Configurable (default: 6) |

You'll see tmux sessions created (names include your project name):
- `fury-<project>` — Connect here to give commands
- `avengers-<project>` — Workers running in background

Wrapper scripts are generated in `.avengers/bin/` for easy access.

---

## 📖 Basic Usage

### Step 1: Connect to Fury

After running `assemble.sh`, all agents automatically load their instructions and are ready to work.

Open a new terminal and connect to Fury:

```bash
.avengers/bin/fury.sh
```

### Step 2: Give Your First Order

Fury is already initialized! Just give your command:

```
Investigate the top 5 JavaScript frameworks and create a comparison table.
```

Fury will:
1. Create tasks via Agent Teams API
2. Send instructions to JARVIS via SendMessage
3. Return control to you immediately (you don't have to wait!)

Meanwhile, JARVIS distributes the work to Workers who execute in parallel.

### Step 3: Check Progress

Open `.avengers/dashboard.md` in your editor to see real-time status:

```markdown
## In Progress
| Worker | Task | Status |
|--------|------|--------|
| Worker 1 | React research | Running |
| Worker 2 | Vue research | Running |
| Worker 3 | Angular research | Done |
```

---

## ✨ Key Features

### ⚡ 1. Parallel Execution

One command can spawn multiple parallel tasks:

```
You: "Research 5 MCP servers"
→ Workers start researching simultaneously
→ Results ready in minutes, not hours
```

### 🔄 2. Non-Blocking Workflow

Fury delegates immediately and returns control to you:

```
You: Give order → Fury: Delegates → You: Can give next order immediately
                                           ↓
                         Workers: Execute in background
                                           ↓
                         Dashboard: Shows results
```

You never have to wait for long tasks to complete.

### 🧠 3. Memory Across Sessions (Memory MCP)

The AI remembers your preferences:

```
Session 1: You say "I prefer simple solutions"
           → Saved to Memory MCP

Session 2: AI reads memory at startup
           → Won't suggest over-engineered solutions
```

### 📡 4. Agent Teams Communication

Agents communicate via Claude Code's **Agent Teams** API:
- **SendMessage** — Direct messages between agents
- **TaskCreate / TaskUpdate** — Task management and assignment
- **Automatic delivery** — No polling, no wasted API calls

### 📸 5. Screenshot Support

VSCode's Claude Code extension lets you paste screenshots to explain issues. This CLI system brings the same capability:

```
# Configure your screenshot folder in config/settings.yaml
screenshot:
  path: "/mnt/c/Users/YourName/Pictures/Screenshots"

# Then just tell Fury:
You: "Check the latest screenshot"
You: "Look at the last 2 screenshots"
→ AI reads and analyzes your screenshots instantly
```

**💡 Windows Tip:** Press `Win + Shift + S` to take a screenshot. Configure the save location to match your `settings.yaml` path for seamless integration.

### 📁 6. Context Management

The system uses a three-layer context structure for efficient knowledge sharing:

| Layer | Location | Purpose |
|-------|----------|---------|
| Memory MCP | `memory/avengers_memory.jsonl` | Persistent memory across sessions (preferences, decisions) |
| Global | `memory/global_context.md` | System-wide settings, user preferences |
| Project | `context/{project}.md` | Project-specific knowledge and state |

### Universal Context Template

All projects use the same 7-section template:

| Section | Purpose |
|---------|---------|
| What | Brief description of the project |
| Why | Goals and success criteria |
| Who | Stakeholders and responsibilities |
| Constraints | Deadlines, budget, limitations |
| Current State | Progress, next actions, blockers |
| Decisions | Decision log with rationale |
| Notes | Free-form notes and insights |

### 🛠️ Skills

Skills are not included in this repository by default.
As you use the system, skill candidates will appear in `dashboard.md`.
Review and approve them to grow your personal skill library.

---

## 🏛️ Design Philosophy

### Why Hierarchical Structure?

The Fury → JARVIS → Workers hierarchy exists for:

1. **Immediate Response**: Fury delegates instantly and returns control to you
2. **Parallel Execution**: JARVIS distributes to multiple Workers simultaneously
3. **Separation of Concerns**: Fury decides "what", JARVIS decides "who"
4. **Quality Gate**: Bruce reviews outputs independently

### Why Agent Teams?

- **Native integration**: Built on Claude Code's Agent Teams API
- **Automatic message delivery**: No polling, no file-based workarounds
- **Task management**: Built-in TaskCreate/TaskUpdate/TaskList
- **Reliable communication**: SendMessage with guaranteed delivery

### Why Only JARVIS Updates Dashboard?

- **Single responsibility**: One writer = no conflicts
- **Information hub**: JARVIS receives all reports, knows the full picture
- **Consistency**: All updates go through one quality gate

### How Skills Work

Skills (`.claude/commands/`) are **not committed to this repository** by design.

**Why?**
- Each user's workflow is different
- Skills should grow organically based on your needs
- No one-size-fits-all solution

**How to create new skills:**
1. Workers report "skill candidates" when they notice repeatable patterns
2. Candidates appear in `dashboard.md` under "Skill Candidates"
3. You review and approve (or reject)
4. Approved skills are created by JARVIS

---

## 🔌 MCP Setup Guide

MCP (Model Context Protocol) servers extend Claude's capabilities. Here's how to set them up:

### What is MCP?

MCP servers give Claude access to external tools:
- **Notion MCP** → Read/write Notion pages
- **GitHub MCP** → Create PRs, manage issues
- **Memory MCP** → Remember things across sessions

### Installing MCP Servers

Run these commands to add MCP servers:

```bash
# 1. Notion - Connect to your Notion workspace
claude mcp add notion -e NOTION_TOKEN=your_token_here -- npx -y @notionhq/notion-mcp-server

# 2. Playwright - Browser automation
claude mcp add playwright -- npx @playwright/mcp@latest
# Note: Run `npx playwright install chromium` first

# 3. GitHub - Repository operations
claude mcp add github -e GITHUB_PERSONAL_ACCESS_TOKEN=your_pat_here -- npx -y @modelcontextprotocol/server-github

# 4. Sequential Thinking - Step-by-step reasoning for complex problems
claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking

# 5. Memory - Long-term memory across sessions (Recommended!)
# ✅ Automatically configured by first_setup.sh
# To reconfigure manually:
claude mcp add memory -e MEMORY_FILE_PATH="$PWD/memory/avengers_memory.jsonl" -- npx -y @modelcontextprotocol/server-memory
```

### Verify Installation

```bash
claude mcp list
```

You should see all servers with "Connected" status.

---

## ⚙️ Configuration

### Team Composition

Fixed 8-member team (Fury + 8 subordinates):

| Member | Role |
|--------|------|
| JARVIS | Task management (delegate) |
| Bruce Banner | Quality assurance / Strategy |
| Doctor Strange | Review |
| Tony Stark | Development |
| Peter Parker | Development |
| Captain America | Testing |
| Captain Marvel | Testing |
| Shuri | Ideation (reports to Fury directly) |

### Language Setting

```yaml
language: ja   # Japanese only
language: en   # Japanese + English translation
```

---

## 🛠️ Advanced Usage

<details>
<summary><b>Script Architecture</b> (Click to expand)</summary>

```
┌─────────────────────────────────────────────────────────────────────┐
│                      FIRST-TIME SETUP (Run Once)                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  install.bat (Windows)                                              │
│      │                                                              │
│      └──▶ first_setup.sh (via WSL)                                  │
│                │                                                    │
│                ├── Check/Install tmux                               │
│                ├── Check/Install Node.js v20+ (via nvm)             │
│                ├── Check/Install Claude Code CLI                    │
│                └── Configure Memory MCP server                      │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                      DAILY STARTUP (Run Every Day)                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  assemble.sh                                                        │
│      │                                                              │
│      ├──▶ Create .avengers/ directory in project                    │
│      │                                                              │
│      ├──▶ Create tmux sessions                                      │
│      │         • "fury-<project>" session (Fury agent)              │
│      │         • "avengers-<project>" session (JARVIS+Bruce+Workers)│
│      │                                                              │
│      └──▶ Launch Claude Code with Agent Teams                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

</details>

<details>
<summary><b>assemble.sh Options</b> (Click to expand)</summary>

```bash
# Run from your project directory
cd /path/to/your/project

# Default: Full startup (.avengers/ creation + tmux sessions + Claude Code launch)
/path/to/agent-team-avengers/assemble.sh

# Show help
/path/to/agent-team-avengers/assemble.sh -h
```

</details>

<details>
<summary><b>Common Workflows</b> (Click to expand)</summary>

**Normal Daily Usage:**
```bash
cd /path/to/your/project
/path/to/agent-team-avengers/assemble.sh   # Start everything
.avengers/bin/fury.sh                       # Connect to give commands
```

**Re-launch (after retreat):**
```bash
.avengers/bin/assemble.sh          # Re-deploy from project directory
```

**Retreat (shutdown):**
```bash
.avengers/bin/disassemble.sh       # Graceful shutdown with backup
```

</details>

---

## 📁 File Structure

<details>
<summary><b>Click to expand file structure</b></summary>

```
agent-team-avengers/                     # AVENGERS_ROOT (system files)
│
│  ┌─────────────────── SCRIPTS ─────────────────────────┐
├── install.bat               # Windows: First-time setup
├── first_setup.sh            # Ubuntu/Mac: First-time setup
├── assemble.sh               # Deploy (run from project dir)
├── disassemble.sh            # Shutdown / retreat
├── watchdog.sh               # Monitoring daemon
├── switch_account.sh         # Account switching
│  └────────────────────────────────────────────────────┘
│
├── instructions/             # Agent instruction files
│   ├── nick_fury_core.md    # Director instructions
│   ├── jarvis.md            # AI Assistant instructions
│   ├── bruce_banner.md      # Strategist instructions
│   └── tony_stark.md (etc.) # Worker instructions
│
├── scripts/
│   ├── claude-avengers       # Claude Code launcher wrapper
│   ├── notify.sh             # tmux send-keys wrapper
│   └── project-env.sh        # Shared variable definitions
│
├── config/
│   └── settings.yaml         # Language, agent count settings
│
├── context/                  # Project context files
├── memory/                   # Memory MCP storage
└── CLAUDE.md                 # Project context for Claude

your-project/.avengers/                  # Generated per project
├── project.env               # Project metadata
├── dashboard.md              # Real-time status overview
├── bin/
│   ├── assemble.sh           # Re-deploy wrapper
│   ├── disassemble.sh        # Retreat wrapper
│   ├── fury.sh               # Attach to fury session
│   └── avengers.sh           # Attach to avengers session
├── status/
│   └── pending_tasks.yaml    # Saved on retreat
└── logs/
    └── backup_*/             # Backups
```

</details>

---

## 🔧 Troubleshooting

<details>
<summary><b>MCP tools not working?</b></summary>

MCP tools are "deferred" and need to be loaded first:

```
# Wrong - tool not loaded
mcp__memory__read_graph()  ← Error!

# Correct - load first
ToolSearch("select:mcp__memory__read_graph")
mcp__memory__read_graph()  ← Works!
```

</details>

<details>
<summary><b>Agents asking for permissions?</b></summary>

Make sure to start with `--dangerously-skip-permissions`:

```bash
claude --dangerously-skip-permissions --system-prompt "..."
```

</details>

<details>
<summary><b>Workers stuck?</b></summary>

Check the worker's pane:
```bash
.avengers/bin/avengers.sh
# Use Ctrl+B then arrow keys to switch panes
```

</details>

---

## 📚 tmux Quick Reference

| Command | Description |
|---------|-------------|
| `.avengers/bin/fury.sh` | Connect to Fury |
| `.avengers/bin/avengers.sh` | Connect to workers |
| `.avengers/bin/disassemble.sh` | Graceful shutdown |
| `Ctrl+B` then `0-8` | Switch between panes |
| `Ctrl+B` then `d` | Detach (leave running) |
| `tmux ls` | List all sessions |

---

## 🙏 Credits

Based on [Claude-Code-Communication](https://github.com/Akira-Papa/Claude-Code-Communication) by Akira-Papa.

Forked from [yohey-w/multi-agent-shogun](https://github.com/yohey-w/multi-agent-shogun).

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

<div align="center">

**Assemble your AI team. Build faster.**

</div>
