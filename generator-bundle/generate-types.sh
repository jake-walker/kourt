#!/bin/bash
deno run -A npm:quicktype --lang swift --src-lang schema -t InputSchema -o ../Sources/Kourt/Lib/InputSchema.g.swift ./input.schema.json
deno run -A npm:quicktype --lang swift --src-lang schema -t OutputSchema -o ../Sources/Kourt/Lib/OutputSchema.g.swift ./output.schema.json
deno run -A npm:quicktype --lang ts --src-lang schema -t InputSchema -o ./inputSchema.g.ts ./input.schema.json
deno run -A npm:quicktype --lang ts --src-lang schema -t OutputSchema -o ./outputSchema.g.ts ./output.schema.json
