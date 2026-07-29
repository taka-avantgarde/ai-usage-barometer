# AI Usage Barometer v0.1.5

This release fixes provider-wide colouring by evaluating every usage window independently.

- Claude stage 1 / 2 / 3: `#b54f02`, `#B85A00`, `#ff7045`
- Codex stage 1 / 2 / 3: `#4F7FA8`, `#0e8ba1`, `#ed5d40`
- Stage thresholds: 0–69%, 70–89%, and 90–100% used
- A healthy 5h window and a critical 7d window now appear in different colours at the same time
- Exact 24-bit RGB is used in the macOS menu bar; dropdown window rows use the matching hex colour
