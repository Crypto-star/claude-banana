---
name: gemini-image-generation
description: >
  This skill should be used when the user asks to "generate an image", "create a picture",
  "make an illustration", "draw something", "create a visual", "generate artwork",
  "make me an image of", "create a photo of", or any request involving AI image generation,
  picture creation, or visual content generation using Google's Gemini API.
  It should also trigger when the user says "I need images for my website", "add a hero image",
  "this page needs visuals", or any general request for images or visuals.
  Additionally, activate this skill when working on frontend code that contains placeholder
  images (e.g., `src="placeholder"`, empty `src=""`, or `TODO: image` comments), missing
  image assets, or any image request where the user hasn't provided a detailed prompt.
version: 1.0.0
---

# Gemini Image Generation

## Overview

Generate images directly within Claude Code using Google's Gemini REST API. Zero dependencies beyond `curl` and `base64` (available on all OS). Only a Gemini API key is required.

## Prerequisites

An API key configured via one of:
- Environment variable: `export GEMINI_API_KEY=your-key`
- Settings file: `.claude/gemini-image-gen.local.md`

To obtain an API key, visit [Google AI Studio](https://aistudio.google.com/apikey).

## Available Models

| Model | ID | Best For |
|-------|-----|----------|
| Gemini 2.5 Flash Image | `gemini-2.5-flash-image` | Default. Fast, efficient generation |
| Gemini 3.1 Flash Image | `gemini-3.1-flash-image-preview` | Speed and high-volume use |
| Gemini 3 Pro Image | `gemini-3-pro-image-preview` | Professional quality, advanced reasoning |

## Smart Prompt Crafting

Before generating an image, determine whether the user's request includes a detailed, ready-to-use prompt:

1. **Check the request specificity:**
   - Does the user provide concrete details (subject, style, colors, composition, mood)?
   - Or is the request vague (e.g., "I need a hero banner", "add images to my site", "this page needs visuals")?
   - Was this triggered by detecting placeholder images or `TODO: image` comments in code?

2. **If the prompt is detailed and ready to use** (e.g., "generate a watercolor painting of a sunset over mountains with warm orange tones"):
   - Proceed directly to the **How to Generate Images** section below.

3. **If the prompt is vague or missing** (e.g., "I need images for my landing page", or placeholder `src=""` detected in code):
   - Invoke the Agent tool with `subagent_type: "prompt-crafter"` to craft a detailed, high-quality image prompt.
   - Provide the agent with all available context: the user's request, any surrounding code, page purpose, and design intent.
   - Use the agent's returned prompt to proceed with image generation in the **How to Generate Images** section below.

> **Rule of thumb:** When in doubt, delegate to `prompt-crafter`. A well-crafted prompt produces dramatically better images.

## How to Generate Images

Run the generation script at `${CLAUDE_PLUGIN_ROOT}/scripts/generate-image.sh`:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/generate-image.sh -p "<prompt>" -o "<output.png>" [-m <model>]
```

**Arguments:**
- `-p`: the image prompt (required)
- `-o`: output file path (required, e.g. `my-image.png`)
- `-m`: model override (optional, uses settings default)
- `-k`: API key override (optional, uses env/settings default)

The script outputs JSON:
- Success: `{"success": true, "output_path": "...", "model": "...", "file_size": 12345}`
- Error: `{"error": "description of what went wrong"}`

## Output Handling

- Create descriptive filenames in kebab-case based on the prompt (e.g., `sunset-mountains.png`)
- Save to the current working directory unless user specifies otherwise
- After generation, read the image file to display it to the user
- Report the model used and file location

## Configuration

Settings stored in `.claude/gemini-image-gen.local.md`:

```markdown
---
api_key: "your-gemini-api-key-here"
model: "gemini-2.5-flash-image"
---
```

Fields:
- **api_key**: Gemini API key (can also use `GEMINI_API_KEY` env var)
- **model**: Default model for generation

Environment variable `GEMINI_API_KEY` takes priority over the settings file.

## Error Handling

| Error | Resolution |
|-------|------------|
| No API key | Set `GEMINI_API_KEY` or add to settings file |
| HTTP 400/403 | Check API key validity or model name |
| Empty response | Try a different or more descriptive prompt |
| Rate limit | Wait and retry, or check quota at Google AI Studio |

## Tips for Better Results

- Write detailed, descriptive prompts for best results
- Specify style, lighting, composition, and mood
- Use the Pro model (`gemini-3-pro-image-preview`) for highest quality
- Use Flash models for quick iterations and drafts
