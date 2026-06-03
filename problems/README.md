# Cost-Aware Benchmark Problems

Each benchmark family is organized by cost model:

```text
problems/<domain>/<cost-model>/<domain>-NNN.pddl
```

The four cost models are:

- `unit`: every object-specific cost is `1`.
- `value`: object-specific costs increase by object order.
- `inverse`: object-specific costs decrease by object order.
- `heavy`: the last quarter of the relevant objects cost `10`; the rest cost `1`.

Scalar movement costs such as `drive-cost`, `fly-cost`, `move-cost`, and
`communicate-cost` are initialized to `1` in every model.

## Generated Domains

- `sliding-tile/3x4`: 100 random-walk base instances, cloned across 4 cost models.
- `sliding-tile/4x4`: 100 random-walk base instances, cloned across 4 cost models.
- `gripper`: 100 generated base instances, cloned across 4 cost models.
- `parking/4x4`: 100 random-walk base instances, cloned across 4 cost models.

## IPC-Derived Domains

These instances were imported from the Potassco `pddl-instances` IPC benchmark
mirror and converted to the local cost-aware domain vocabulary. Each domain
directory contains a `MANIFEST.txt` with source paths and per-instance counts.

- `logistics`: IPC 2000 `logistics-strips-typed`, 84 base instances.
- `miconic`: IPC 2000 `elevator-strips-simple-typed`, 150 base instances.
- `driverlog`: IPC 2002 `driverlog-strips-automatic`, 20 base instances.
- `satellite`: IPC 2002 `satellite-strips-automatic`, 20 base instances.
- `rovers`: IPC 2002 `rovers-strips-automatic`, 20 base instances.
- `depots`: IPC 2002 `depots-strips-automatic`, 22 base instances.
- `zenotravel`: IPC 2002 `zenotravel-strips-automatic`, 20 base instances.

Because the local domain files encode costs directly and use a simplified
predicate vocabulary in a few places, the IPC-derived problem files are not
byte-for-byte IPC originals. They are compatible benchmark clones for the local
`domains/*.pddl` files.
