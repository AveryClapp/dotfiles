# Taskwarrior Guide

A comprehensive guide for using Taskwarrior with our custom Kanagawa-themed, neovim-like configuration.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Basic Commands](#basic-commands)
- [Taskwarrior-TUI Keybindings](#taskwarrior-tui-keybindings)
- [Task Management](#task-management)
- [Advanced Features](#advanced-features)
- [Tips & Tricks](#tips--tricks)

---

## Quick Start

### Launch Taskwarrior
```bash
task                    # Show next tasks (default view)
task next               # Same as above
taskwarrior-tui         # Launch TUI (recommended)
```

### Add Your First Task
```bash
task add "Write documentation"
task a "Fix bug in authentication"     # Using our vim-style alias
```

### Complete a Task
```bash
task 1 done
task d 1                                # Using our vim-style alias
```

---

## Basic Commands

### Adding Tasks

```bash
# Simple task
task add "Buy groceries"

# Task with project
task add project:work "Review pull requests"

# Task with priority
task add priority:H "Fix production bug"

# Task with due date
task add due:tomorrow "Submit report"
task add due:friday "Team meeting prep"
task add due:2025-12-01 "Year-end review"

# Task with tags
task add +urgent +bug "Fix login issue"

# Combined
task add project:personal priority:M due:friday +home "Clean garage"
```

### Viewing Tasks

```bash
task                    # Next tasks (default)
task list               # All pending tasks
task ls                 # Alias for list
task completed          # Show completed tasks
task all                # Show all tasks (pending + completed)

# Filter by project
task project:work list
task project:personal list

# Filter by tag
task +urgent list
task +bug list

# Filter by priority
task priority:H list
```

### Modifying Tasks

```bash
# Modify description
task 1 modify "New description"
task m 1 "New description"              # Using alias

# Add project
task 1 modify project:work

# Add priority
task 1 modify priority:H

# Add due date
task 1 modify due:tomorrow

# Add tags
task 1 modify +urgent +review

# Remove tags
task 1 modify -review
```

### Task Operations

```bash
# Complete a task
task 1 done
task d 1                                # Using alias

# Start a task (track active work)
task 1 start
task s 1                                # Using alias

# Stop a task
task 1 stop

# Delete a task
task 1 delete
task rm 1                               # Using alias
task del 1                              # Alternative alias

# Edit task in $EDITOR
task 1 edit
task e 1                                # Using alias

# Undo last operation
task undo
```

---

## Taskwarrior-TUI Keybindings

Our configuration uses vim-style keybindings to match your neovim workflow.

### Navigation
```
j                   Move down (next task)
k                   Move up (previous task)
J                   Page down (scroll down ~10 tasks)
K                   Page up (scroll up ~10 tasks)
gg                  Jump to top (first task)
G                   Jump to bottom (last task)
H                   Previous tab/view
L                   Next tab/view
```

### Task Operations
```
a                   Add new task
d                   Mark task as done
s                   Start/stop task (toggle timer)
m                   Modify task
e                   Edit task in $EDITOR
x                   Delete task
u                   Undo last operation
```

### Search & Commands
```
/                   Search tasks (vim-style)
:                   Enter command mode (vim-style)
?                   Show help
```

### Utility
```
q                   Quit taskwarrior-tui
l                   View log/history
<C-r>               Refresh task list
```

---

## Task Management

### Using Projects

Projects help organize related tasks:

```bash
# Add tasks to projects
task add project:dotfiles "Update nvim config"
task add project:work "Code review"
task add project:personal "Plan vacation"

# View tasks by project
task project:dotfiles list

# Our pre-configured contexts
task context work               # Switch to work context
task context personal           # Switch to personal context
task context none               # Clear context
task c work                     # Using alias
```

**Pre-configured Contexts:**
- `work`: Shows tasks from work, research, or interviews projects
- `personal`: Shows tasks from personal or home projects

### Using Tags

Tags provide flexible categorization:

```bash
# Common tag patterns
task add +bug "Fix navbar alignment"
task add +feature "Add dark mode toggle"
task add +urgent "Deploy hotfix"
task add +review "Review design docs"
task add +waiting "Waiting for feedback"

# Filter by tags
task +bug list
task +urgent +bug list          # Multiple tags (AND)

# Special tag: 'next'
task add +next "Most important task"
# The +next tag has high urgency coefficient (15.0) in our config
```

### Priority Levels

```bash
H                   High priority
M                   Medium priority
L                   Low priority

# Usage
task add priority:H "Critical bug"
task add priority:M "Regular feature"
task add priority:L "Nice to have"

# Our config uses Kanagawa colors:
# H = color167 (red)
# M = color180 (yellow)
# L = color95 (gray)
```

### Due Dates

```bash
# Relative dates
task add due:today "Daily standup"
task add due:tomorrow "Submit timesheet"
task add due:friday "End of week review"
task add due:eow "End of week task"
task add due:eom "End of month task"

# Specific dates
task add due:2025-12-15 "Project deadline"

# Recurring tasks
task add due:monday recur:weekly "Weekly team meeting"
task add due:1st recur:monthly "Monthly report"
```

### Task Estimates (Custom UDA)

Our config includes a custom User Defined Attribute for estimates:

```bash
task add estimate:30m "Quick bug fix"
task add estimate:2h "Implement feature"
task add estimate:1d "Major refactor"

# Available estimates:
# 5m, 15m, 30m, 1h, 2h, 4h, 1d
```

---

## Advanced Features

### Reports

```bash
# Default report (next)
task

# Custom report columns (from our config):
# ID, Active, Age, Deps, P, Project, Tag, Recur, S, Due, Until, Description, Urg

# Other useful reports
task summary                    # Summary by project
task calendar                   # Calendar view
task burndown.daily             # Burndown chart
task ghistory.monthly           # History graph
```

### Filtering

```bash
# Complex filters
task project:work priority:H list
task +urgent -waiting list
task due.before:tomorrow list
task status:completed end.after:today-7days list

# Filter by status
task status:pending list
task status:completed list
task status:deleted list
```

### Dependencies

```bash
# Task 2 depends on task 1
task 2 modify depends:1

# View tasks with dependencies
task next                       # Shows 'Deps' column
```

### Contexts

```bash
# List available contexts
task context list

# Set context
task context work
task c work                     # Using alias

# View current context
task context show

# Clear context
task context none
```

---

## Tips & Tricks

### Daily Workflow

**Morning:**
```bash
taskwarrior-tui                 # Launch TUI
# Press 'a' to add today's tasks
# Press 's' to start your first task
```

**Throughout the day:**
```bash
# In TUI: Press 'd' to complete tasks
# In TUI: Press 's' to start/stop task timer
```

**Evening:**
```bash
task completed end.after:today  # Review what you accomplished
```

### Productivity Tips

1. **Use the +next tag** for your single most important task
   - Our config gives it the highest urgency (15.0)

2. **Start tasks to track active work**
   - `task s <id>` or press 's' in TUI
   - Shows task is active (highlighted in Kanagawa yellow)

3. **Keep your task list clean**
   - Archive or delete completed tasks regularly
   - Use contexts to focus on relevant tasks

4. **Leverage keyboard shortcuts in TUI**
   - Learn `gg`, `G`, `J`, `K` for fast navigation
   - Use `/` to quickly find tasks

### Color Theme

Our Kanagawa Wave theme uses:
- **Active tasks**: `color109` (teal/cyan)
- **Due today**: `color214` (yellow)
- **Overdue**: `color203`/`color196` (red)
- **Completed**: `color95` (muted gray)
- **High priority**: `color167` (red)
- **Medium priority**: `color180` (yellow)

These colors match your neovim Kanagawa theme for a consistent experience.

### Urgency Coefficients

Our config prioritizes tasks based on:
- `+next` tag: **15.0** (highest)
- Due date: **12.0**
- Blocking other tasks: **8.0**
- Active/started: **4.0**

Tasks are automatically sorted by urgency in the `next` report.

### Quick Reference Card

```bash
# Vim-style aliases (configured)
task a              # add
task d <id>         # done
task m <id>         # modify
task e <id>         # edit
task s <id>         # start
task n              # next
task w              # waiting
task c              # context
task h              # help
task ls             # list
task rm <id>        # delete
task del <id>       # delete
```

---

## Common Workflows

### Bug Tracking
```bash
task add project:myapp +bug priority:H "Fix login redirect"
task add project:myapp +bug priority:M "Update error messages"
```

### Feature Development
```bash
task add project:feature-x +feature "Design UI mockup"
task add project:feature-x +feature "Implement backend API" depends:1
task add project:feature-x +feature "Write tests" depends:2
```

### Weekly Planning
```bash
# Sunday evening - plan the week
task add +next priority:H "Most important task this week"
task add project:work due:friday "End of week deliverable"
task add recur:weekly due:monday "Weekly team sync"
```

### Context Switching
```bash
# Start work
task c work
task

# End work, switch to personal
task c personal
task
```

---

## Configuration Files

- **Main config**: `~/.taskrc`
- **TUI config**: `~/.config/taskwarrior-tui/config.toml`
- **Data location**: `~/.task/`
- **Dotfiles source**: `~/Documents/Coding/GitProjects/dotfiles/`

### Customization

Edit `.taskrc` to customize:
- Colors (Kanagawa theme)
- Urgency coefficients
- Report columns
- Aliases
- Contexts
- UDAs (User Defined Attributes)

Edit `taskwarrior-tui/config.toml` to customize:
- Keybindings
- TUI theme
- Default report

After editing dotfiles, run:
```bash
cd ~/Documents/Coding/GitProjects/dotfiles
./setup_config.sh
```
Or manually copy:
```bash
cp .taskrc ~/.taskrc
cp -r taskwarrior-tui ~/.config/
```

---

## Resources

- [Taskwarrior Documentation](https://taskwarrior.org/docs/)
- [Taskwarrior-TUI GitHub](https://github.com/kdheepak/taskwarrior-tui)
- Man pages: `man task`, `man taskrc`, `man task-color`

---

**Happy tasking!** 🚀
