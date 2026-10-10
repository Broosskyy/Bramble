# Meshy production pipeline

This folder drives Bramble's automated Meshy 3D generation.

## Secret

GitHub Actions requires the repository secret:

`MESHY_API_KEY`

Never commit the key.

## Trigger

Two options are supported:

1. Manually run **Meshy 3D Generate** and choose a job JSON.
2. Commit or change a JSON file under `meshy/jobs/`. That push automatically starts the workflow.

## First job

`meshy/jobs/base_hero_male.json`

Expected references:

- `meshy/references/base_hero_male/front.jpg`
- `meshy/references/base_hero_male/side.jpg`
- `meshy/references/base_hero_male/back.jpg`

The workflow sends the references to Meshy's Multi-Image-to-3D API, waits for completion and uploads a GitHub Actions artifact containing:

- textured GLB
- front/side/back preview renders when Meshy supplies them
- full task JSON
- credit usage metadata

## Production rule

Do not batch all eight heroes until Base Hero Male has been visually approved. After approval, create one job per canonical character and reuse the same pipeline.
