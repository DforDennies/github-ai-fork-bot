# GitHub AI Fork Bot

每日自動掃描 GitHub 上的 AI/ML/LLM 相關 repo，符合條件自動 fork 到 DforDennies。

## 掃描策略

- **Topics**: 50+ AI 相關 topic（llm, agent, mcp, tts, diffusion...）
- **Keywords**: 13 組搜尋關鍵字
- **Trending**: 最近 7 天新建的高星 repo
- **門檻**: 1,000+ stars
- **排程**: 每天台灣時間 10:00 AM

## 自動分類

| 類別 | 關鍵字 |
|------|--------|
| model | LLM, transformer, deepseek, qwen |
| inference-engine | vllm, sglang, ollama, quantization |
| agent-harness | coding agent, CLI agent, harness |
| agent-framework | autogen, crewai, langgraph |
| fine-tuning | LoRA, QLoRA, RLHF, GRPO |
| voice-audio | TTS, STT, whisper, voice cloning |
| video-generation | text-to-video, sora, cogvideo |
| image-generation | diffusion, comfyui, flux |
| rag-knowledge | RAG, vector DB, knowledge graph |
| mcp | Model Context Protocol |
| chatbot | telegram bot, discord bot |
| computer-use | browser agent, desktop automation |
| workflow | n8n, dify, langflow |
| prompts-skills | cursor rules, system prompts |
| multimodal | VLM, OCR, vision |

## Setup

1. 建立 Personal Access Token（需要 `repo` scope）
2. 在此 repo Settings > Secrets 加入 `FORK_BOT_TOKEN`
3. 啟用 GitHub Actions

## Log

所有 fork 記錄在 [fork-log.md](fork-log.md)。
