#!/usr/bin/env python3
"""Generate solvable cost-aware Gripper benchmark instances."""

from __future__ import annotations

import argparse
import random
import shutil
from pathlib import Path


DEFAULT_SEED = 20260605
DEFAULT_INSTANCES = 100
DEFAULT_MIN_BALLS = 12
DEFAULT_MAX_BALLS = 24
DEFAULT_ROOMS = 4
GRIPPERS = ["left", "right"]


def cost_assignments(cost_model: str, num_balls: int) -> list[str]:
    if cost_model == "unit":
        costs = {ball: 1 for ball in range(1, num_balls + 1)}
    elif cost_model == "value":
        costs = {ball: ball for ball in range(1, num_balls + 1)}
    elif cost_model == "inverse":
        costs = {ball: num_balls + 1 - ball for ball in range(1, num_balls + 1)}
    elif cost_model == "heavy":
        heavy_count = (num_balls + 3) // 4
        heavy_balls = set(range(num_balls - heavy_count + 1, num_balls + 1))
        costs = {
            ball: 10 if ball in heavy_balls else 1
            for ball in range(1, num_balls + 1)
        }
    else:
        raise ValueError(f"unknown cost model: {cost_model}")
    lines = ["    (= (move-cost) 1)"]
    lines.extend(
        f"    (= (ball-cost ball{ball}) {costs[ball]})"
        for ball in range(1, num_balls + 1)
    )
    return lines


def generate_instance(
    rng: random.Random, min_balls: int, max_balls: int, num_rooms: int
) -> tuple[int, int, list[int], list[int]]:
    num_balls = rng.randint(min_balls, max_balls)
    robot_room = rng.randrange(num_rooms)
    init_rooms = []
    goal_rooms = []
    for _ in range(num_balls):
        init_room = rng.randrange(num_rooms)
        goal_room = rng.randrange(num_rooms - 1)
        if goal_room >= init_room:
            goal_room += 1
        init_rooms.append(init_room)
        goal_rooms.append(goal_room)
    return num_balls, robot_room, init_rooms, goal_rooms


def problem_text(
    instance_id: int,
    cost_model: str,
    num_rooms: int,
    num_balls: int,
    robot_room: int,
    init_rooms: list[int],
    goal_rooms: list[int],
) -> str:
    problem_name = f"gripper-{instance_id:03d}-{cost_model}"
    rooms = " ".join(f"room{room}" for room in range(num_rooms))
    balls = " ".join(f"ball{ball}" for ball in range(1, num_balls + 1))
    grippers = " ".join(GRIPPERS)
    init_lines = ["    (= (total-cost) 0)"] + cost_assignments(
        cost_model, num_balls
    )
    init_lines.append(f"    (at-robby room{robot_room})")
    init_lines.extend(f"    (free {gripper})" for gripper in GRIPPERS)
    init_lines.extend(
        f"    (at ball{ball} room{init_rooms[ball - 1]})"
        for ball in range(1, num_balls + 1)
    )
    goal_lines = [
        f"      (at ball{ball} room{goal_rooms[ball - 1]})"
        for ball in range(1, num_balls + 1)
    ]

    return "\n".join(
        [
            f"(define (problem {problem_name})",
            "  (:domain gripper)",
            "",
            "  (:objects",
            f"    {rooms} - room",
            f"    {balls} - ball",
            f"    {grippers} - gripper",
            "  )",
            "",
            "  (:init",
            *init_lines,
            "  )",
            "",
            "  (:goal",
            "    (and",
            *goal_lines,
            "    )",
            "  )",
            "",
            "  (:metric minimize (total-cost))",
            ")",
            "",
        ]
    )


def write_manifest(
    output_dir: Path,
    seed: int,
    num_rooms: int,
    instances: list[tuple[int, int, list[int], list[int]]],
) -> None:
    lines = [
        "domain=domains/gripper.pddl",
        f"seed={seed}",
        f"instances={len(instances)}",
        f"rooms={num_rooms}",
        f"grippers={len(GRIPPERS)}",
        "cost_models=unit,value,inverse,heavy",
        "",
        "# init/goals list room indices for ball1..ballN.",
    ]
    for index, (num_balls, robot_room, init_rooms, goal_rooms) in enumerate(
        instances, start=1
    ):
        init_text = " ".join(str(room) for room in init_rooms)
        goal_text = " ".join(str(room) for room in goal_rooms)
        lines.append(
            f"{index:03d}: balls={num_balls} robot={robot_room} "
            f"init=({init_text}) goal=({goal_text})"
        )
    (output_dir / "MANIFEST.txt").write_text("\n".join(lines) + "\n", encoding="ascii")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", default="problems/gripper")
    parser.add_argument("--seed", type=int, default=DEFAULT_SEED)
    parser.add_argument("--instances", type=int, default=DEFAULT_INSTANCES)
    parser.add_argument("--min-balls", type=int, default=DEFAULT_MIN_BALLS)
    parser.add_argument("--max-balls", type=int, default=DEFAULT_MAX_BALLS)
    parser.add_argument("--rooms", type=int, default=DEFAULT_ROOMS)
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    if output_dir.exists() and any(output_dir.iterdir()):
        if not args.force:
            raise SystemExit(f"{output_dir} is not empty; rerun with --force")
        shutil.rmtree(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    rng = random.Random(args.seed)
    instances = [
        generate_instance(rng, args.min_balls, args.max_balls, args.rooms)
        for _ in range(args.instances)
    ]

    cost_models = ["unit", "value", "inverse", "heavy"]
    for cost_model in cost_models:
        model_dir = output_dir / cost_model
        model_dir.mkdir(parents=True, exist_ok=True)
        for instance_id, instance in enumerate(instances, start=1):
            num_balls, robot_room, init_rooms, goal_rooms = instance
            problem_path = model_dir / f"gripper-{instance_id:03d}.pddl"
            problem_path.write_text(
                problem_text(
                    instance_id,
                    cost_model,
                    args.rooms,
                    num_balls,
                    robot_room,
                    init_rooms,
                    goal_rooms,
                ),
                encoding="ascii",
            )

    write_manifest(output_dir, args.seed, args.rooms, instances)


if __name__ == "__main__":
    main()
