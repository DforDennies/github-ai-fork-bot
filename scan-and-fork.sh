#!/usr/bin/env bash
set -euo pipefail

OWNER="DforDennies"
MIN_STARS=1000
LOG_FILE="fork-log.md"
DATE=$(date -u +"%Y-%m-%d")

TOPICS=(
  "llm" "large-language-model" "ai-agent" "agent-framework"
  "machine-learning" "deep-learning" "nlp" "natural-language-processing"
  "transformers" "diffusion-model" "text-to-speech" "tts" "stt"
  "speech-recognition" "voice-cloning" "text-to-image" "text-to-video"
  "video-generation" "image-generation" "stable-diffusion" "comfyui"
  "rag" "retrieval-augmented-generation" "vector-database"
  "fine-tuning" "lora" "qlora" "rlhf"
  "mcp" "model-context-protocol" "agent-harness"
  "inference" "vllm" "ollama" "llama-cpp"
  "computer-use" "browser-automation" "desktop-agent"
  "chatbot" "ai-assistant" "coding-agent"
  "deepseek" "qwen" "openai" "anthropic" "langchain"
  "knowledge-graph" "graph-rag" "agentic"
  "multimodal" "vision-language-model" "ocr"
  "ai-coding" "code-generation" "ai-workflow"
)

SEARCH_KEYWORDS=(
  "LLM inference"
  "AI agent framework"
  "text to speech open source"
  "video generation AI"
  "MCP server"
  "coding agent harness"
  "RAG engine"
  "fine-tuning LLM"
  "browser AI agent"
  "computer use agent"
  "voice cloning"
  "multimodal AI"
  "AI workflow automation"
)

already_forked_cache=""

load_existing_forks() {
  echo "📥 Loading existing forks..."
  already_forked_cache=$(gh repo list "$OWNER" --fork --limit=500 --json nameWithOwner,parent --jq '.[].parent.nameWithOwner // empty' 2>/dev/null || echo "")
  echo "   Found $(echo "$already_forked_cache" | wc -l | tr -d ' ') existing forks"
}

is_already_forked() {
  local repo="$1"
  echo "$already_forked_cache" | grep -qF "$repo"
}

try_fork() {
  local repo="$1"
  local category="$2"
  local stars="$3"

  if is_already_forked "$repo"; then
    return 0
  fi

  echo "🔀 Forking $repo (⭐$stars) [$category]"
  local result
  if result=$(gh repo fork "$repo" --clone=false 2>&1); then
    echo "  ✅ $result"
    echo "| $DATE | $repo | $stars | $category | ✅ |" >> "$LOG_FILE"
    already_forked_cache="$already_forked_cache"$'\n'"$repo"
    sleep 2
  else
    if echo "$result" | grep -q "already exists"; then
      echo "  ⏭️  Already exists"
    else
      echo "  ❌ Failed: $result"
      echo "| $DATE | $repo | $stars | $category | ❌ $result |" >> "$LOG_FILE"
    fi
  fi
}

classify_repo() {
  local desc="$1"
  local topics="$2"
  local name="$3"
  local combined="$desc $topics $name"
  combined=$(echo "$combined" | tr '[:upper:]' '[:lower:]')

  if echo "$combined" | grep -qE "tts|text.to.speech|voice|speech|stt|whisper|audio|sound"; then
    echo "voice-audio"
  elif echo "$combined" | grep -qE "video.gen|text.to.video|sora|cogvideo|wan.*video"; then
    echo "video-generation"
  elif echo "$combined" | grep -qE "diffusion|comfyui|text.to.image|image.gen|stable.diffusion|flux"; then
    echo "image-generation"
  elif echo "$combined" | grep -qE "harness|coding.agent|cli.agent|terminal.agent"; then
    echo "agent-harness"
  elif echo "$combined" | grep -qE "agent|agentic|autogen|crewai|langgraph|orchestrat"; then
    echo "agent-framework"
  elif echo "$combined" | grep -qE "mcp|model.context.protocol"; then
    echo "mcp"
  elif echo "$combined" | grep -qE "rag|retrieval|knowledge.graph|vector"; then
    echo "rag-knowledge"
  elif echo "$combined" | grep -qE "inference|serving|vllm|sglang|llama.cpp|ollama|quantiz"; then
    echo "inference-engine"
  elif echo "$combined" | grep -qE "fine.tun|lora|qlora|rlhf|grpo|training|pretrain"; then
    echo "fine-tuning"
  elif echo "$combined" | grep -qE "llm|language.model|transformer|deepseek|qwen|llama|mistral|gemma"; then
    echo "model"
  elif echo "$combined" | grep -qE "chatbot|chat.bot|im.bot|telegram|discord|slack.bot"; then
    echo "chatbot"
  elif echo "$combined" | grep -qE "browser|computer.use|desktop.agent|automation"; then
    echo "computer-use"
  elif echo "$combined" | grep -qE "workflow|n8n|dify|langflow|pipeline"; then
    echo "workflow"
  elif echo "$combined" | grep -qE "prompt|skill|cursor.rule|system.prompt"; then
    echo "prompts-skills"
  elif echo "$combined" | grep -qE "ocr|vision|multimodal|vlm"; then
    echo "multimodal"
  else
    echo "other-ai"
  fi
}

scan_by_topic() {
  local topic="$1"
  echo "🔍 Scanning topic: $topic"
  local results
  results=$(gh search repos --topic="$topic" --sort=stars --limit=30 \
    --json fullName,stargazersCount,description,repositoryTopics \
    --jq ".[] | select(.stargazersCount >= $MIN_STARS) | \"\(.fullName)|\(.stargazersCount)|\(.description // \"\")|\(.repositoryTopics | map(.name) | join(\",\"))\"" 2>/dev/null || echo "")

  while IFS='|' read -r repo stars desc topics; do
    [ -z "$repo" ] && continue
    local cat
    cat=$(classify_repo "$desc" "$topics" "$repo")
    try_fork "$repo" "$cat" "$stars"
  done <<< "$results"
  sleep 1
}

scan_by_keyword() {
  local keyword="$1"
  echo "🔍 Searching: $keyword"
  local results
  results=$(gh search repos "$keyword" --sort=stars --limit=20 \
    --json fullName,stargazersCount,description,repositoryTopics \
    --jq ".[] | select(.stargazersCount >= $MIN_STARS) | \"\(.fullName)|\(.stargazersCount)|\(.description // \"\")|\(.repositoryTopics | map(.name) | join(\",\"))\"" 2>/dev/null || echo "")

  while IFS='|' read -r repo stars desc topics; do
    [ -z "$repo" ] && continue
    local cat
    cat=$(classify_repo "$desc" "$topics" "$repo")
    try_fork "$repo" "$cat" "$stars"
  done <<< "$results"
  sleep 1
}

scan_trending() {
  echo "🔍 Scanning recently created/updated high-star AI repos..."
  local since
  since=$(date -u -d "7 days ago" +"%Y-%m-%d" 2>/dev/null || date -u -v-7d +"%Y-%m-%d")

  for kw in "AI" "LLM" "agent" "model"; do
    local results
    results=$(gh search repos "$kw" --sort=stars --order=desc --limit=30 \
      --created=">=$since" \
      --json fullName,stargazersCount,description,repositoryTopics \
      --jq ".[] | select(.stargazersCount >= $MIN_STARS) | \"\(.fullName)|\(.stargazersCount)|\(.description // \"\")|\(.repositoryTopics | map(.name) | join(\",\"))\"" 2>/dev/null || echo "")

    while IFS='|' read -r repo stars desc topics; do
      [ -z "$repo" ] && continue
      local cat
      cat=$(classify_repo "$desc" "$topics" "$repo")
      try_fork "$repo" "$cat" "$stars"
    done <<< "$results"
    sleep 1
  done
}

main() {
  echo "🤖 AI Fork Bot — $DATE"
  echo "================================"

  if [ ! -f "$LOG_FILE" ]; then
    cat > "$LOG_FILE" << 'HEADER'
# AI Fork Bot Log

| Date | Repo | Stars | Category | Status |
|------|------|-------|----------|--------|
HEADER
  fi

  load_existing_forks

  echo ""
  echo "📂 Phase 1: Scan by topics"
  for topic in "${TOPICS[@]}"; do
    scan_by_topic "$topic"
  done

  echo ""
  echo "📂 Phase 2: Scan by keywords"
  for kw in "${SEARCH_KEYWORDS[@]}"; do
    scan_by_keyword "$kw"
  done

  echo ""
  echo "📂 Phase 3: Scan trending (last 7 days)"
  scan_trending

  echo ""
  echo "✅ Done! Check $LOG_FILE for results."

  new_forks=$(grep -c "| $DATE |" "$LOG_FILE" 2>/dev/null || echo "0")
  echo "📊 New forks today: $new_forks"
}

main "$@"
