# Claude Banana

Generate images directly in Claude Code using Google's Gemini API — with smart prompt crafting that analyzes your frontend codebase for design context.

**Zero dependencies** - only requires a Gemini API key. Uses `curl` and `base64` which are available on all operating systems.

## Features

- Generate images from text prompts using Gemini's image generation models
- **Smart Prompt Crafting** — analyzes your frontend code (CSS, Tailwind, design tokens) to infer style and colors
- **Context-Aware** — detects placeholder images, empty `src` attributes, and TODO comments in your code
- **Targeted Questions** — asks only what it can't infer, then crafts optimized Gemini prompts
- **Code Integration** — optionally places generated images into your assets folder and updates references
- Multiple model support with configurable defaults
- Explicit `/generate-image` command for direct control
- Works on Linux, macOS, and Windows

## Installation

### From Marketplace (Recommended)

```bash
# Step 1: Add the marketplace
/plugin marketplace add Crypto-star/claude-banana

# Step 2: Install the plugin
/plugin install claude-banana
```

### Manual Installation

```bash
# Clone the repo and point Claude Code to it
git clone https://github.com/Crypto-star/claude-banana.git
claude --plugin-dir ./claude-banana
```

### Verify Installation

Run `/plugins` in Claude Code — you should see `claude-banana` listed and enabled.

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

### Smart Prompt Crafting

For vague requests, the plugin automatically activates the prompt-crafter agent:
- "I need a hero banner for my landing page" — scans your CSS/Tailwind for colors and style
- "Add images to my website" — detects your design system and asks targeted questions
- "This component needs a background image" — reads surrounding code for context

The agent crafts an optimized prompt, shows it for your approval, then generates and optionally integrates the image into your code.

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
