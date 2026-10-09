"""Проверка студенческого шаблона: есть все задачи, обязательные не закрыты."""
import json
from pathlib import Path

report = json.loads(Path("report.json").read_text())
expected = {f"1.{i}" for i in range(1, 6)}
expected |= {f"2.{i}" for i in range(1, 8)}
expected.add("3.1")
rows = report["tasks"]
assert {row["id"] for row in rows} == expected, rows
assert len(rows) == len(expected), rows
assert report["level1_closed"] is False, report
assert all(row["status"] == "TODO" for row in rows), rows
assert all(row["status"] != "DONE" for row in rows if row["level"] == 1), rows
print("Студенческий шаблон: 13 задач TODO, обязательные не закрыты — OK")
