# Contributing

Run the following before opening a pull request:

```bash
bash -n ai-usage.60s.sh install.sh uninstall.sh claude-usage.sh claude-statusline-capture.sh configure-claude-statusline.sh tests/run.sh
./tests/run.sh
```

Never include authentication tokens, Keychain contents, `~/.codex/auth.json`, `~/.claude/.credentials.json`, private session logs, or real status-line payloads in issues and test fixtures.
