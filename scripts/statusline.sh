#!/bin/bash
# Simple HUD - Claude Code 轻量级状态栏
# 通过 stdin 接收 JSON 会话数据，显示上下文进度和 Git 分支

input=$(cat)

# ---- 提取基础字段 ----
MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
CWD=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
USED_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_api_duration_ms // 0')

# ---- 上下文进度条（10字符宽度）----
BAR_WIDTH=10
if [ "$USED_PCT" = "null" ] || [ -z "$USED_PCT" ]; then
    USED_PCT=0
fi
FILLED=$(( USED_PCT * BAR_WIDTH / 100 ))
EMPTY=$(( BAR_WIDTH - FILLED ))
BAR=$(printf '%*s' "$FILLED" '' | tr ' ' '#')$(printf '%*s' "$EMPTY" '' | tr ' ' '-')

# 根据使用率选择颜色
if [ "$USED_PCT" -ge 90 ]; then
    COLOR="\033[31m"
elif [ "$USED_PCT" -ge 70 ]; then
    COLOR="\033[33m"
else
    COLOR="\033[32m"
fi
RESET="\033[0m"

# ---- 目录名 ----
DIR_NAME="${CWD##*/}"

# ---- Git 分支（带缓存，5秒刷新）----
CACHE_FILE="/tmp/statusline-git-cache"
CACHE_AGE=0
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
fi

if [ "$CACHE_AGE" -gt 5 ] || [ ! -f "$CACHE_FILE" ]; then
    GIT_BRANCH=""
    if git -C "$CWD" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        GIT_BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null || echo "detached")
    fi
    echo "$GIT_BRANCH" > "$CACHE_FILE"
else
    GIT_BRANCH=$(cat "$CACHE_FILE")
fi

# ---- 格式化 API 时间 ----
API_SECS=$(( DURATION_MS / 1000 ))
API_MINS=$(( API_SECS / 60 ))
API_REMAIN_SECS=$(( API_SECS % 60 ))
if [ "$API_MINS" -gt 0 ]; then
    TIME_STR="${API_MINS}m${API_REMAIN_SECS}s"
else
    TIME_STR="${API_SECS}s"
fi

# ---- 单行输出: 目录 + Git分支 + 模型 + 进度条 + API时间 ----
if [ -n "$GIT_BRANCH" ]; then
    printf '%b' "${DIR_NAME} \033[36m${GIT_BRANCH}${RESET} [${MODEL}] ${COLOR}${BAR}${RESET} ${USED_PCT}% ${TIME_STR}\n"
else
    printf '%b' "${DIR_NAME} [${MODEL}] ${COLOR}${BAR}${RESET} ${USED_PCT}% ${TIME_STR}\n"
fi
