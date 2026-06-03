# Cost-Aware Benchmark Domains

These PDDL domain files define the action-cost structure for the algorithm
comparison experiments. The numeric cost values are intentionally not encoded
here. Each problem file should initialize `(total-cost)` and the domain-specific
cost functions, then include `(:metric minimize (total-cost))`.

For each cost model (`unit`, `value`, `inverse`, `heavy`), generate a matching
set of problem files with different assignments to these functions.

Example problem init fragment:

```lisp
(= (total-cost) 0)
(= (tile-cost tile1) 1)
(= (tile-cost tile2) 2)
```

The main experimental search configs should use `cost_type=normal` so the
planner respects the costs encoded by the benchmark instance.

## Domain Cost Functions

- `sliding-tile.pddl`: `(tile-cost ?t)`
- `blocksworld.pddl`: `(block-cost ?b)`
- `gripper.pddl`: `(ball-cost ?b)`, `(move-cost)`
- `logistics.pddl`: `(package-cost ?p)`, `(drive-cost)`, `(fly-cost)`
- `driverlog.pddl`: `(package-cost ?p)`, `(driver-cost ?d)`, `(drive-cost)`, `(walk-cost)`
- `miconic.pddl`: `(passenger-cost ?p)`, `(move-cost)`
- `satellite.pddl`: `(target-cost ?d)`, `(instrument-cost ?i)`, `(satellite-move-cost ?s)`
- `rovers.pddl`: `(sample-cost ?w)`, `(image-cost ?o)`, `(rover-cost ?r)`, `(communicate-cost)`
- `depots.pddl`: `(crate-cost ?c)`, `(drive-cost)`
- `zenotravel.pddl`: `(person-cost ?p)`, `(fly-cost)`, `(zoom-cost)`
- `parking.pddl`: `(car-cost ?c)`
