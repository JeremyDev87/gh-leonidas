# gh-leonidas

A [GitHub CLI](https://cli.github.com/) extension that simplifies [Leonidas](https://github.com/JeremyDev87/leonidas) installation on any repository.

Instead of manually copying workflow files, setting secrets, and creating labels, run a single command:

```bash
gh leonidas setup
```

## Installation

```bash
gh extension install JeremyDev87/gh-leonidas
```

### Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`) v2.0+
- Authenticated via `gh auth login`

## Quick Start

```bash
# Navigate to your repository
cd your-repo

# Install Leonidas
gh leonidas setup

# Follow the prompts to complete setup
```

## Commands

### `gh leonidas setup`

Install Leonidas workflow files into the current repository.

What it does:
- Copies workflow files to `.github/workflows/`
- Copies system prompt template to `.github/leonidas.md`
- Creates the `leonidas` label
- Checks for `ANTHROPIC_API_KEY` secret

```bash
gh leonidas setup           # Interactive setup
gh leonidas setup --force   # Overwrite existing files
```

### `gh leonidas check`

Verify that Leonidas is properly installed and configured.

```bash
gh leonidas check
```

Checks:
- Workflow files exist
- System prompt file exists
- `leonidas` label exists
- `ANTHROPIC_API_KEY` secret is set
- Authorization check is present in execute workflow

### `gh leonidas update`

Update workflow files to the latest version. Your `.github/leonidas.md` (system prompt) is preserved.

```bash
gh leonidas update           # Interactive update
gh leonidas update --force   # Update without prompting
```

### `gh leonidas uninstall`

Remove Leonidas from the current repository.

```bash
gh leonidas uninstall              # Interactive removal
gh leonidas uninstall --force      # Remove without prompting
gh leonidas uninstall --keep-label # Keep the 'leonidas' label
```

## What Gets Installed

```
.github/
├── workflows/
│   ├── leonidas-plan.yml      # Triggers on issue with 'leonidas' label
│   ├── leonidas-execute.yml   # Triggers on '/approve' comment
│   └── leonidas-track.yml     # Tracks sub-issue completion
└── leonidas.md                # System prompt (customize for your project)
```

## Security

The execute workflow includes an authorization check by default. Only repository owners, organization members, and collaborators can trigger the `/approve` command.

See the [security patch documentation](https://github.com/JeremyDev87/leonidas/blob/main/.github/SECURITY_PATCH.md) for details.

## License

MIT
