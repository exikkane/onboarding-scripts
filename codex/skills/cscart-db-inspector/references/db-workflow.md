# DB Workflow Reference

Global workflow for any CS-Cart project:

- `sudo docker ps --format '{{.Names}}'`
- `sudo docker exec -it [project-name]-mariadb-1 /bin/bash`
- `mariadb -uroot -p cscart`
- Password: `root`

Practical direct-query form for Codex:

- `sudo docker exec [project-name]-mariadb-1 mariadb -uroot -proot cscart -N -e "<SQL>"`

Read-only query examples:

- `SHOW TABLES LIKE 'cscart_%';`
- `SHOW COLUMNS FROM cscart_users;`
- `SELECT COUNT(*) FROM cscart_orders;`
- `SELECT user_id, email FROM cscart_users WHERE email = 'user@example.com';`
