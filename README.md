# Gemini Image Generator

Generate images directly in Claude Code using Google's Gemini API.

**Zero dependencies** - only requires a Gemini API key. Uses `curl` and `base64` which are available on all operating systems.

## Features

- Generate images from text prompts using Gemini's image generation models
- Multiple model support with configurable defaults
- Automatic detection when you ask for image generation
- Explicit `/generate-image` command for direct control
- Works on Linux, macOS, and Windows

## Prerequisites

- A Google Gemini API key ([Get one free here](https://aistudio.google.com/apikey))

## Configuration

### Option 1: Environment Variable (Recommended)

**Linux/macOS:**
```bash
export GEMINI_API_KEY="your-api-key-here"
```
Add to your shell profile (`~/.bashrc`, `~/.zshrc`) to persist across sessions.

**Windows (PowerShell):**
```powershell
$env:GEMINI_API_KEY = "your-api-key-here"
```
To persist, add to your PowerShell profile or set via System Environment Variables.

### Option 2: Settings File

Create `.claude/gemini-image-gen.local.md` in your project:

```markdown
---
api_key: "your-gemini-api-key-here"
model: "gemini-2.5-flash-image"
---
```

**Note:** Add `.claude/*.local.md` to your `.gitignore` to avoid committing your API key.

## Usage

### Slash Command

```
/generate-image a sunset over snow-capped mountains in watercolor style
/generate-image a cute robot --model gemini-3-pro-image-preview
/generate-image company logo --output logo.png
```

### Natural Language

Just ask Claude to generate an image:
- "Generate an image of a futuristic cityscape"
- "Create a picture of a cat wearing a top hat"
- "Make me an illustration of a cozy cabin in the woods"

## Available Models

| Model | ID | Best For |
|-------|-----|----------|
| Gemini 2.5 Flash Image | `gemini-2.5-flash-image` | Default. Fast, efficient |
| Gemini 3.1 Flash Image | `gemini-3.1-flash-image-preview` | Speed and volume |
| Gemini 3 Pro Image | `gemini-3-pro-image-preview` | Professional quality |

## Troubleshooting

**"No API key found"**
- Set `GEMINI_API_KEY` environment variable, or
- Create `.claude/gemini-image-gen.local.md` with your key

**"Gemini API error (400)"**
- Check that the model name is correct
- Try a different prompt (some prompts may be blocked by safety filters)

**"Gemini API error (403)"**
- Your API key may be invalid or expired
- Get a new key at [Google AI Studio](https://aistudio.google.com/apikey)

**Empty or text-only response**
- Try a more descriptive prompt
- Try a different model
- Check your API quota at [Google AI Studio](https://aistudio.google.com/)
