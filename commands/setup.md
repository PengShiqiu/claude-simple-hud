---
description: 配置 simple-hud 状态栏（写入 settings.json）
allowed-tools: Bash, Read, Edit, AskUserQuestion
---

# 配置 Simple HUD 状态栏

将 simple-hud 的 statusline 脚本注册到 Claude Code 的 settings.json 中。

## 步骤

### Step 1: 定位插件目录

获取插件根目录（即 setup.md 所在的上级上级目录）：

```bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
if [ -z "$PLUGIN_ROOT" ]; then
  # 兜底：从当前文件路径推导
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi
echo "插件目录: $PLUGIN_ROOT"
```

验证脚本存在：

```bash
ls -la "${PLUGIN_ROOT}/scripts/statusline.sh"
```

如果不存在，报错并停止。

### Step 2: 生成命令

生成的 statusLine command 格式：

```
bash -c 'exec "${CLAUDE_PLUGIN_ROOT}/scripts/statusline.sh"'
```

**注意**: 使用 `${CLAUDE_PLUGIN_ROOT}` 环境变量，确保插件更新后路径仍然有效。

### Step 3: 测试脚本

先用空输入测试脚本是否能正常运行：

```bash
echo '{}' | bash "${PLUGIN_ROOT}/scripts/statusline.sh" 2>&1
```

如果报错（如缺少 `jq`），提示用户安装依赖后停止。

### Step 4: 写入 settings.json

读取 Claude Code 的 settings 文件：

- 路径：`${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json`

合并写入 `statusLine` 配置，**保留所有现有设置**：

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash -c 'exec \"${CLAUDE_PLUGIN_ROOT}/scripts/statusline.sh\"'",
    "padding": 2
  }
}
```

**重要**：
- 如果 settings.json 不存在，创建它
- 如果包含无效 JSON，报告错误，不要覆盖
- 保留所有其他现有设置不变
- 如果写入失败（`File has been unexpectedly modified`），重新读取后重试一次

### Step 5: 完成

告诉用户：

> 配置完成！请**重启 Claude Code** 使状态栏生效。

如果用户重启后状态栏未显示，排查：
1. 检查 `jq` 是否安装：`which jq`
2. 检查 settings.json 中 statusLine 配置是否正确
3. 手动测试脚本：`echo '{"context_window":{"used_percentage":50},"model":{"display_name":"test"}}' | bash -c 'exec "${CLAUDE_PLUGIN_ROOT}/scripts/statusline.sh"'`
