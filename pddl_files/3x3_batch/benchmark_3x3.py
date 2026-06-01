import csv
import re
import subprocess
import time
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DOMAIN = ROOT / "pddl_files" / "sliding-tile-domain.pddl"
PROBLEM_DIR = ROOT / "pddl_files" / "3x3_batch"
OUTPUT_CSV = PROBLEM_DIR / "benchmark_results.csv"

# Keep these simple and directly comparable:
# - astar and my_astar use the same evaluator (manhattan)
# - gbfs uses lazy_greedy with the same heuristic
SEARCH_CONFIGS = {
    "astar_manhattan": 'astar(manhattan())',
    "my_astar_manhattan": 'my_astar(manhattan())',
    "gbfs_manhattan": 'lazy_greedy([manhattan()])',
}


def parse_metric(output: str, label: str) -> str:
    match = re.search(rf"{re.escape(label)}:\s+([^\n]+)", output)
    return match.group(1).strip() if match else ""


def run_once(problem_path: Path, config_name: str, search_config: str) -> dict:
    cmd = [
        "python3",
        "fast-downward.py",
        str(DOMAIN),
        str(problem_path),
        "--search",
        search_config,
    ]
    start = time.perf_counter()
    completed = subprocess.run(
        cmd,
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    elapsed = time.perf_counter() - start
    out = completed.stdout + completed.stderr

    solved = "Solution found." in out
    return {
        "problem": problem_path.name,
        "config": config_name,
        "exit_code": completed.returncode,
        "solved": solved,
        "time_sec": f"{elapsed:.6f}",
        "plan_cost": parse_metric(out, "Plan cost"),
        "plan_length": parse_metric(out, "Plan length"),
        "expanded": parse_metric(out, "Expanded"),
        "evaluated": parse_metric(out, "Evaluated"),
    }


def main() -> None:
    problems = sorted(PROBLEM_DIR.glob("sliding-3x3-problem-*.pddl"))
    if not problems:
        raise RuntimeError("No 3x3 problem files found.")

    rows = []
    for problem in problems:
        for config_name, search_config in SEARCH_CONFIGS.items():
            row = run_once(problem, config_name, search_config)
            rows.append(row)
            print(
                f"{problem.name:28} | {config_name:20} | "
                f"solved={row['solved']} | time={row['time_sec']}s"
            )

    with OUTPUT_CSV.open("w", newline="", encoding="ascii") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "problem",
                "config",
                "exit_code",
                "solved",
                "time_sec",
                "plan_cost",
                "plan_length",
                "expanded",
                "evaluated",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)

    print(f"\nWrote results to {OUTPUT_CSV}")


if __name__ == "__main__":
    main()
