#!/usr/bin/env python3
"""Generate solvable 3x4 sliding-tile benchmark instances."""

from __future__ import annotations

import argparse
import random
import shutil
from pathlib import Path


WIDTH = 3
HEIGHT = 4
NUM_TILES = WIDTH * HEIGHT - 1
DEFAULT_SEED = 20260604
DEFAULT_INSTANCES = 100
DEFAULT_WALK_STEPS = 180
DEFAULT_MIN_MANHATTAN = 24


def position_names() -> list[str]:
    return [f"pos{col}{row}" for row in range(HEIGHT) for col in range(WIDTH)]


POSITIONS = position_names()
GOAL_BOARD = tuple(list(range(1, NUM_TILES + 1)) + [0])
GOAL_POS = {tile: index for index, tile in enumerate(GOAL_BOARD) if tile}


def index_to_row_col(index: int) -> tuple[int, int]:
    row, col = divmod(index, WIDTH)
    return row, col


def neighbors(blank_index: int) -> list[int]:
    row, col = index_to_row_col(blank_index)
    result = []
    if row > 0:
        result.append(blank_index - WIDTH)
    if row < HEIGHT - 1:
        result.append(blank_index + WIDTH)
    if col > 0:
        result.append(blank_index - 1)
    if col < WIDTH - 1:
        result.append(blank_index + 1)
    return result


def manhattan(board: tuple[int, ...]) -> int:
    total = 0
    for index, tile in enumerate(board):
        if tile == 0:
            continue
        goal_index = GOAL_POS[tile]
        row, col = index_to_row_col(index)
        goal_row, goal_col = index_to_row_col(goal_index)
        total += abs(row - goal_row) + abs(col - goal_col)
    return total


def random_walk(rng: random.Random, steps: int) -> tuple[int, ...]:
    board = list(GOAL_BOARD)
    blank = board.index(0)
    previous_blank = None
    for _ in range(steps):
        candidates = neighbors(blank)
        if previous_blank in candidates and len(candidates) > 1:
            candidates.remove(previous_blank)
        next_blank = rng.choice(candidates)
        board[blank], board[next_blank] = board[next_blank], board[blank]
        previous_blank, blank = blank, next_blank
    return tuple(board)


def adjacency_atoms() -> list[str]:
    atoms = []
    for index, name in enumerate(POSITIONS):
        for neighbor in neighbors(index):
            atoms.append(f"    (adjacent {name} {POSITIONS[neighbor]})")
    return atoms


def cost_assignments(cost_model: str) -> list[str]:
    costs = {}
    if cost_model == "unit":
        costs = {tile: 1 for tile in range(1, NUM_TILES + 1)}
    elif cost_model == "value":
        costs = {tile: tile for tile in range(1, NUM_TILES + 1)}
    elif cost_model == "inverse":
        costs = {tile: NUM_TILES + 1 - tile for tile in range(1, NUM_TILES + 1)}
    elif cost_model == "heavy":
        heavy_count = (NUM_TILES + 3) // 4
        heavy_tiles = set(range(NUM_TILES - heavy_count + 1, NUM_TILES + 1))
        costs = {
            tile: 10 if tile in heavy_tiles else 1
            for tile in range(1, NUM_TILES + 1)
        }
    else:
        raise ValueError(f"unknown cost model: {cost_model}")
    return [f"    (= (tile-cost tile{tile}) {costs[tile]})" for tile in costs]


def board_atoms(board: tuple[int, ...]) -> list[str]:
    atoms = []
    for index, tile in enumerate(board):
        if tile == 0:
            atoms.append(f"    (blank-at {POSITIONS[index]})")
        else:
            atoms.append(f"    (at tile{tile} {POSITIONS[index]})")
    return atoms


def goal_atoms() -> list[str]:
    atoms = []
    for index, tile in enumerate(GOAL_BOARD):
        if tile == 0:
            atoms.append(f"      (blank-at {POSITIONS[index]})")
        else:
            atoms.append(f"      (at tile{tile} {POSITIONS[index]})")
    return atoms


def problem_text(instance_id: int, cost_model: str, board: tuple[int, ...]) -> str:
    problem_name = f"sliding-tile-3x4-{instance_id:03d}-{cost_model}"
    tiles = " ".join(f"tile{tile}" for tile in range(1, NUM_TILES + 1))
    positions = " ".join(POSITIONS)
    init_lines = (
        ["    (= (total-cost) 0)"]
        + cost_assignments(cost_model)
        + adjacency_atoms()
        + board_atoms(board)
    )

    return "\n".join(
        [
            f"(define (problem {problem_name})",
            "  (:domain sliding-tile)",
            "",
            "  (:objects",
            f"    {tiles} - tile",
            f"    {positions} - position",
            "  )",
            "",
            "  (:init",
            *init_lines,
            "  )",
            "",
            "  (:goal",
            "    (and",
            *goal_atoms(),
            "    )",
            "  )",
            "",
            "  (:metric minimize (total-cost))",
            ")",
            "",
        ]
    )


def generate_boards(
    rng: random.Random, count: int, walk_steps: int, min_manhattan: int
) -> list[tuple[int, ...]]:
    boards = []
    seen = {GOAL_BOARD}
    attempts = 0
    max_attempts = count * 1000
    while len(boards) < count and attempts < max_attempts:
        attempts += 1
        board = random_walk(rng, walk_steps)
        if board in seen:
            continue
        if manhattan(board) < min_manhattan:
            continue
        seen.add(board)
        boards.append(board)
    if len(boards) < count:
        raise RuntimeError(
            f"only generated {len(boards)} boards after {attempts} attempts"
        )
    return boards


def write_manifest(
    output_dir: Path,
    boards: list[tuple[int, ...]],
    seed: int,
    walk_steps: int,
    min_manhattan: int,
) -> None:
    lines = [
        "domain=domains/sliding-tile.pddl",
        f"seed={seed}",
        f"instances={len(boards)}",
        f"random_walk_steps={walk_steps}",
        f"min_manhattan={min_manhattan}",
        "cost_models=unit,value,inverse,heavy",
        "",
        "# board entries use 0 for the blank and positions ordered as:",
        "# pos00 pos10 pos20 pos01 ... pos23",
    ]
    for index, board in enumerate(boards, start=1):
        board_text = " ".join(str(value) for value in board)
        lines.append(
            f"{index:03d}: manhattan={manhattan(board):02d} board=({board_text})"
        )
    (output_dir / "MANIFEST.txt").write_text("\n".join(lines) + "\n", encoding="ascii")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", default="problems/sliding-tile/3x4")
    parser.add_argument("--seed", type=int, default=DEFAULT_SEED)
    parser.add_argument("--instances", type=int, default=DEFAULT_INSTANCES)
    parser.add_argument("--walk-steps", type=int, default=DEFAULT_WALK_STEPS)
    parser.add_argument("--min-manhattan", type=int, default=DEFAULT_MIN_MANHATTAN)
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    if output_dir.exists() and any(output_dir.iterdir()):
        if not args.force:
            raise SystemExit(f"{output_dir} is not empty; rerun with --force")
        shutil.rmtree(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    rng = random.Random(args.seed)
    boards = generate_boards(
        rng, args.instances, args.walk_steps, args.min_manhattan
    )

    cost_models = ["unit", "value", "inverse", "heavy"]
    for cost_model in cost_models:
        model_dir = output_dir / cost_model
        model_dir.mkdir(parents=True, exist_ok=True)
        for instance_id, board in enumerate(boards, start=1):
            problem_path = model_dir / f"sliding-tile-3x4-{instance_id:03d}.pddl"
            problem_path.write_text(
                problem_text(instance_id, cost_model, board),
                encoding="ascii",
            )

    write_manifest(
        output_dir, boards, args.seed, args.walk_steps, args.min_manhattan
    )


if __name__ == "__main__":
    main()
