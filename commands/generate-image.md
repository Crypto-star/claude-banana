---
description: Generate an image using Google's Gemini API
argument-hint: [prompt] [--model model-name] [--output filename.png]
allowed-tools: Bash(*), Read
---

Generate an image using the Gemini API based on the user's request.

## Parse Arguments

The user's input: $ARGUMENTS

Parse the following from the input:
- **prompt**: The image description (everything that isn't a flag)
- **--model**: Optional model override. Available models:
  - `gemini-2.5-flash-image` (default - fast and efficient)
  - `gemini-3.1-flash-image-preview` (optimized for speed and volume)
  - `gemini-3-pro-image-preview` (professional quality, advanced reasoning)
- **--output**: Optional output filename (default: auto-generated descriptive name with .png)

## Generate Image

Construct and run the command:

```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/generate-image.sh -p "<prompt>" -o "<output_path>" [-m <model>]
```

If no output filename was specified, create a descriptive filename based on the prompt (e.g., `sunset-over-mountains.png`). Use kebab-case, max 40 characters, always ending in `.png`.

## Handle Result

Parse the JSON output from the script:

- **On success**: Display the output path and model used. Read the image file to show it to the user.
- **On error with "No Gemini API key"**: Tell the user to configure their API key:
  1. Set environment variable: `export GEMINI_API_KEY=your-key`
  2. Or create `.claude/gemini-image-gen.local.md` with their key in the frontmatter
- **On other errors**: Show the error message and suggest trying a different prompt or model
