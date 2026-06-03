#!/usr/bin/env python3
"""Import IPC benchmark instances and add problem-level action costs."""

from __future__ import annotations

import argparse
import re
import shutil
from pathlib import Path
from typing import Callable


COST_MODELS = ["unit", "value", "inverse", "heavy"]


DOMAIN_SOURCES = {
    "logistics": "ipc-2000/domains/logistics-strips-typed/instances",
    "miconic": "ipc-2000/domains/elevator-strips-simple-typed/instances",
    "driverlog": "ipc-2002/domains/driverlog-strips-automatic/instances",
    "satellite": "ipc-2002/domains/satellite-strips-automatic/instances",
    "rovers": "ipc-2002/domains/rovers-strips-automatic/instances",
    "depots": "ipc-2002/domains/depots-strips-automatic/instances",
    "zenotravel": "ipc-2002/domains/zenotravel-strips-automatic/instances",
}


TYPE_MAPS = {
    "logistics": {
        "airport": "location",
        "place": "location",
        "location": "location",
        "truck": "truck",
        "airplane": "airplane",
        "package": "package",
        "city": "city",
    },
    "miconic": {"passenger": "passenger", "floor": "floor"},
    "driverlog": {
        "driver": "driver",
        "truck": "truck",
        "obj": "package",
        "package": "package",
        "location": "location",
    },
    "satellite": {
        "satellite": "satellite",
        "instrument": "instrument",
        "mode": "mode",
        "direction": "direction",
    },
    "rovers": {
        "rover": "rover",
        "waypoint": "waypoint",
        "store": "store",
        "camera": "camera",
        "mode": "mode",
        "objective": "objective",
        "lander": "lander",
    },
    "depots": {
        "depot": "place",
        "distributor": "place",
        "place": "place",
        "truck": "truck",
        "hoist": "hoist",
        "pallet": "surface",
        "surface": "surface",
        "crate": "crate",
    },
    "zenotravel": {
        "aircraft": "aircraft",
        "person": "person",
        "city": "city",
        "flevel": None,
    },
}


TYPE_ORDER = {
    "logistics": ["city", "location", "truck", "airplane", "package"],
    "miconic": ["floor", "passenger"],
    "driverlog": ["location", "truck", "driver", "package"],
    "satellite": ["satellite", "instrument", "mode", "direction"],
    "rovers": ["rover", "waypoint", "store", "camera", "mode", "objective", "lander"],
    "depots": ["place", "truck", "hoist", "surface", "crate"],
    "zenotravel": ["city", "aircraft", "person"],
}


COST_FUNCTIONS = {
    "logistics": [("package-cost", "package"), ("drive-cost", None), ("fly-cost", None)],
    "miconic": [("passenger-cost", "passenger"), ("move-cost", None)],
    "driverlog": [
        ("package-cost", "package"),
        ("driver-cost", "driver"),
        ("drive-cost", None),
        ("walk-cost", None),
    ],
    "satellite": [
        ("target-cost", "direction"),
        ("instrument-cost", "instrument"),
        ("satellite-move-cost", "satellite"),
    ],
    "rovers": [
        ("sample-cost", "waypoint"),
        ("image-cost", "objective"),
        ("rover-cost", "rover"),
        ("communicate-cost", None),
    ],
    "depots": [("crate-cost", "crate"), ("drive-cost", None)],
    "zenotravel": [("person-cost", "person"), ("fly-cost", None), ("zoom-cost", None)],
}


def strip_comments(text: str) -> str:
    return re.sub(r";.*", "", text)


def tokenize(text: str) -> list[str]:
    return re.findall(r"\(|\)|[^\s()]+", strip_comments(text).lower())


def parse_tokens(tokens: list[str]) -> list:
    stack: list[list] = []
    root: list = []
    current = root
    for token in tokens:
        if token == "(":
            child: list = []
            current.append(child)
            stack.append(current)
            current = child
        elif token == ")":
            if not stack:
                raise ValueError("unbalanced closing parenthesis")
            current = stack.pop()
        else:
            current.append(token)
    if stack:
        raise ValueError("unbalanced opening parenthesis")
    if len(root) != 1:
        raise ValueError("expected a single top-level expression")
    return root[0]


def section(expr: list, name: str) -> list:
    for item in expr:
        if isinstance(item, list) and item and item[0] == name:
            return item
    raise ValueError(f"missing {name} section")


def parse_typed_objects(items: list[str]) -> dict[str, str]:
    result: dict[str, str] = {}
    pending: list[str] = []
    index = 0
    while index < len(items):
        token = items[index]
        if token == "-":
            if index + 1 >= len(items):
                raise ValueError("typed object list ended after '-'")
            typ = items[index + 1]
            for name in pending:
                result[name] = typ
            pending = []
            index += 2
        else:
            pending.append(token)
            index += 1
    for name in pending:
        result[name] = "object"
    return result


def natural_key(path: Path) -> tuple:
    parts = re.split(r"(\d+)", path.stem)
    return tuple(int(part) if part.isdigit() else part for part in parts)


def convert_objects(domain: str, source_objects: dict[str, str]) -> dict[str, str]:
    type_map = TYPE_MAPS[domain]
    converted: dict[str, str] = {}
    for name, source_type in source_objects.items():
        target_type = type_map.get(source_type)
        if target_type is None:
            continue
        if target_type not in TYPE_ORDER[domain]:
            continue
        converted[name] = target_type
    return converted


def generic_rename(atom: list[str]) -> list[str]:
    return [atom[0].replace("_", "-"), *atom[1:]]


def convert_logistics(atom: list[str], object_types: dict[str, str]) -> list[str] | None:
    if atom[0] == "at" and len(atom) == 3:
        obj_type = object_types.get(atom[1])
        if obj_type == "package":
            return ["at-package", atom[1], atom[2]]
        if obj_type in {"truck", "airplane"}:
            return atom
    return atom


def convert_driverlog(atom: list[str], object_types: dict[str, str]) -> list[str] | None:
    if atom[0] == "at" and len(atom) == 3:
        obj_type = object_types.get(atom[1])
        if obj_type == "driver":
            return ["at-driver", atom[1], atom[2]]
        if obj_type == "truck":
            return ["at-truck", atom[1], atom[2]]
        if obj_type == "package":
            return ["at-package", atom[1], atom[2]]
    return atom


def convert_miconic(atom: list[str], object_types: dict[str, str]) -> list[str] | None:
    del object_types
    if atom[0] == "above" and len(atom) == 3:
        return ["above", atom[2], atom[1]]
    if atom[0] in {"not-boarded", "not-served"}:
        return None
    return atom


def convert_satellite(atom: list[str], object_types: dict[str, str]) -> list[str] | None:
    del object_types
    return generic_rename(atom)


def convert_rovers(atom: list[str], object_types: dict[str, str]) -> list[str] | None:
    del object_types
    name = atom[0].replace("_", "-")
    args = atom[1:]
    if name in {"available", "at-soil-sample", "at-rock-sample"}:
        return None
    if name in {"have-soil-analysis", "have-rock-analysis"} and len(args) == 2:
        return [name, args[1]]
    if name == "have-image" and len(args) == 3:
        return [name, args[1], args[2]]
    return [name, *args]


def convert_depots(atom: list[str], object_types: dict[str, str]) -> list[str] | None:
    if atom[0] == "at" and len(atom) == 3:
        obj_type = object_types.get(atom[1])
        if obj_type == "truck":
            return ["at-truck", atom[1], atom[2]]
        if obj_type == "hoist":
            return ["at-hoist", atom[1], atom[2]]
        if obj_type == "crate":
            return ["at-crate", atom[1], atom[2]]
        return None
    return atom


def convert_zenotravel(atom: list[str], object_types: dict[str, str]) -> list[str] | None:
    if atom[0] == "at" and len(atom) == 3:
        obj_type = object_types.get(atom[1])
        if obj_type == "aircraft":
            return ["at-aircraft", atom[1], atom[2]]
        if obj_type == "person":
            return ["at-person", atom[1], atom[2]]
    if atom[0] in {"fuel-level", "next"}:
        return None
    return atom


CONVERTERS: dict[str, Callable[[list[str], dict[str, str]], list[str] | None]] = {
    "logistics": convert_logistics,
    "miconic": convert_miconic,
    "driverlog": convert_driverlog,
    "satellite": convert_satellite,
    "rovers": convert_rovers,
    "depots": convert_depots,
    "zenotravel": convert_zenotravel,
}


def convert_atom(
    domain: str, atom: list, object_types: dict[str, str]
) -> list[str] | None:
    if not atom or atom[0] in {"=", "not"}:
        return None
    converted = CONVERTERS[domain]([str(item) for item in atom], object_types)
    if converted is None:
        return None
    return [str(item) for item in converted]


def atoms_from_goal(goal_section: list) -> list[list]:
    goal = goal_section[1]
    if isinstance(goal, list) and goal and goal[0] == "and":
        return [item for item in goal[1:] if isinstance(item, list)]
    if isinstance(goal, list):
        return [goal]
    raise ValueError("unsupported goal section")


def atom_text(atom: list[str], indent: str) -> str:
    return f"{indent}({' '.join(atom)})"


def objects_by_type(object_types: dict[str, str], domain: str) -> dict[str, list[str]]:
    grouped = {typ: [] for typ in TYPE_ORDER[domain]}
    for name, typ in object_types.items():
        grouped[typ].append(name)
    for names in grouped.values():
        names.sort(key=lambda name: natural_key(Path(name)))
    return grouped


def object_costs(names: list[str], cost_model: str) -> dict[str, int]:
    if cost_model == "unit":
        return {name: 1 for name in names}
    if cost_model == "value":
        return {name: index for index, name in enumerate(names, start=1)}
    if cost_model == "inverse":
        return {name: len(names) + 1 - index for index, name in enumerate(names, start=1)}
    if cost_model == "heavy":
        heavy_count = (len(names) + 3) // 4
        heavy = set(names[-heavy_count:])
        return {name: 10 if name in heavy else 1 for name in names}
    raise ValueError(f"unknown cost model: {cost_model}")


def cost_lines(domain: str, object_types: dict[str, str], cost_model: str) -> list[str]:
    grouped = objects_by_type(object_types, domain)
    lines = ["    (= (total-cost) 0)"]
    for function_name, typ in COST_FUNCTIONS[domain]:
        if typ is None:
            lines.append(f"    (= ({function_name}) 1)")
            continue
        names = grouped[typ]
        costs = object_costs(names, cost_model)
        lines.extend(
            f"    (= ({function_name} {name}) {costs[name]})" for name in names
        )
    return lines


def converted_problem(
    domain: str, source_path: Path, instance_id: int, cost_model: str
) -> tuple[str, int, int]:
    expr = parse_tokens(tokenize(source_path.read_text(encoding="ascii", errors="ignore")))
    source_objects = parse_typed_objects(section(expr, ":objects")[1:])
    object_types = convert_objects(domain, source_objects)
    converter_object_types = {name: object_types[name] for name in object_types}

    init_atoms = []
    for item in section(expr, ":init")[1:]:
        if isinstance(item, list):
            converted = convert_atom(domain, item, converter_object_types)
            if converted is not None:
                init_atoms.append(converted)

    goal_atoms = []
    for item in atoms_from_goal(section(expr, ":goal")):
        converted = convert_atom(domain, item, converter_object_types)
        if converted is not None:
            goal_atoms.append(converted)

    problem_name = f"{domain}-ipc-{instance_id:03d}-{cost_model}"
    grouped = objects_by_type(object_types, domain)
    object_lines = [
        f"    {' '.join(names)} - {typ}"
        for typ, names in grouped.items()
        if names
    ]
    init_lines = cost_lines(domain, object_types, cost_model) + [
        atom_text(atom, "    ") for atom in init_atoms
    ]
    goal_lines = [atom_text(atom, "      ") for atom in goal_atoms]

    text = "\n".join(
        [
            f"(define (problem {problem_name})",
            f"  (:domain {domain})",
            "",
            "  (:objects",
            *object_lines,
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
    return text, len(init_atoms), len(goal_atoms)


def write_manifest(
    output_dir: Path,
    domain: str,
    source_root: Path,
    instance_paths: list[Path],
    stats: list[tuple[int, int]],
) -> None:
    lines = [
        f"domain=domains/{domain}.pddl",
        f"source={source_root}",
        f"instances={len(instance_paths)}",
        "cost_models=unit,value,inverse,heavy",
        "",
        "# Imported from Potassco's pddl-instances IPC benchmark mirror.",
        "# Instances are converted to the local cost-aware domain vocabulary.",
    ]
    for index, (path, (init_count, goal_count)) in enumerate(
        zip(instance_paths, stats), start=1
    ):
        lines.append(
            f"{index:03d}: source={path.name} init_atoms={init_count} "
            f"goal_atoms={goal_count}"
        )
    (output_dir / "MANIFEST.txt").write_text("\n".join(lines) + "\n", encoding="ascii")


def import_domain(domain: str, ipc_root: Path, output_root: Path, force: bool) -> None:
    source_root = ipc_root / DOMAIN_SOURCES[domain]
    if not source_root.exists():
        raise FileNotFoundError(f"missing IPC source directory: {source_root}")

    output_dir = output_root / domain
    if output_dir.exists() and any(output_dir.iterdir()):
        if not force:
            raise SystemExit(f"{output_dir} is not empty; rerun with --force")
        shutil.rmtree(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    instance_paths = sorted(source_root.glob("*.pddl"), key=natural_key)
    stats: list[tuple[int, int]] = []
    for cost_model in COST_MODELS:
        model_dir = output_dir / cost_model
        model_dir.mkdir(parents=True, exist_ok=True)
        for instance_id, source_path in enumerate(instance_paths, start=1):
            text, init_count, goal_count = converted_problem(
                domain, source_path, instance_id, cost_model
            )
            (model_dir / f"{domain}-{instance_id:03d}.pddl").write_text(
                text, encoding="ascii"
            )
            if cost_model == "unit":
                stats.append((init_count, goal_count))

    write_manifest(output_dir, domain, source_root, instance_paths, stats)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--ipc-root",
        default="/tmp/pddl-instances-master",
        help="path to a checkout/archive of potassco/pddl-instances",
    )
    parser.add_argument("--output-root", default="problems")
    parser.add_argument(
        "--domains",
        nargs="+",
        default=list(DOMAIN_SOURCES),
        choices=sorted(DOMAIN_SOURCES),
    )
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    ipc_root = Path(args.ipc_root)
    output_root = Path(args.output_root)
    for domain in args.domains:
        import_domain(domain, ipc_root, output_root, args.force)


if __name__ == "__main__":
    main()
