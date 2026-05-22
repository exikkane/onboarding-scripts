---
name: cscart-db-inspector
description: "Inspect a CS-Cart database from any project when the user asks to look in the database, check data in DB, verify records in MariaDB, or use the database for deeper context. Use the standard Docker workflow: find the project container with docker ps, enter the mariadb container, and query the cscart database as root."
---

# CS-Cart DB Inspector

This is a global skill. Use it from any CS-Cart project when the user explicitly asks to inspect data in the database or when deeper database context is required to answer the request.

## Required Workflow

Follow this standard workflow for any project:

1. Find the project name.
- Run `sudo docker ps --format '{{.Names}}'`.
- Identify the matching container prefix `[project-name]`.

2. Open the MariaDB container if interactive access is needed.
- Run `sudo docker exec -it [project-name]-mariadb-1 /bin/bash`.
- Inside the container run `mariadb -uroot -p cscart`.
- Use password `root`.

3. Prefer direct non-interactive SQL for focused checks.
- Run `sudo docker exec [project-name]-mariadb-1 mariadb -uroot -proot cscart -N -e "<SQL>"`.
- Use this mode for read-only lookups because it is faster and easier to capture in the answer.

## Operating Rules

- Default to read-only queries: `SELECT`, `SHOW`, `DESCRIBE`, `EXPLAIN`.
- Do not modify data or schema unless the user explicitly asks for it.
- First inspect table structure when names or columns are uncertain.
- Quote exact identifiers and filters in the answer when the query matters.
- Solve the root cause, not only the visible symptom: use DB checks to validate assumptions behind the bug or feature.
- If multiple project containers exist, choose the one that matches the current workspace or task context before querying.
- Assume the current workspace is the primary match unless container names or task context indicate otherwise.

## Response Pattern

When using the database:

1. State which container and database were inspected.
2. Summarize the exact finding briefly.
3. Include the important rows, aggregates, or counts in compact form.
4. Call out uncertainty if the DB state does not fully explain the issue.

## Typical Triggers

- "посмотри в базе"
- "проверь в БД"
- "посмотри записи в mariadb"
- "look in the database"
- "check the DB"
- "verify this in MariaDB"
