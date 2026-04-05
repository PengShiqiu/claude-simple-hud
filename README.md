# Simple HUD

轻量级 Claude Code 状态栏插件，显示上下文进度、Git 分支、模型名称和 API 耗时。

## 效果

```
my-project main [Sonnet] [######----] 60% 1m23s
```

- 绿色进度条：使用率 < 70%
- 黄色进度条：使用率 70% ~ 90%
- 红色进度条：使用率 >= 90%
- Git 分支以青色显示（非 Git 仓库则隐藏）

## 安装

### 前置依赖

- [jq](https://stedolan.github.io/jq/)（用于解析 JSON 输入）

### 安装插件

```bash
claude plugin add /path/to/claude-simple-hud
```

### 配置状态栏

在 Claude Code 中执行：

```
/simple-hud:setup
```

或手动将以下配置写入 `~/.claude/settings.json`：

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash -c 'exec \"${CLAUDE_PLUGIN_ROOT}/scripts/statusline.sh\"'",
    "padding": 2
  }
}
```

重启 Claude Code 后生效。

## License

MIT
