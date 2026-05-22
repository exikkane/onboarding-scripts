# Изменения проекта

## 2026-05-22

- Добавлена поддержка `mode=light` для `make init domain=...` в docker sample.
- Добавлена короткая команда `make init-light` для light-инициализации.
- Описан light-режим инициализации в `README.md`.
- Добавлена команда `make bootstrap` для линковки shared-инструкций и установки обязательных Codex skills.
- Установка pre-commit hooks встроена в `make init`.
- `AGENTS.md`, `docs` и обязательные Codex skills добавлены в sample как bootstrap-источники для новой машины.
- Добавлен project-local wrapper `scripts/pwcli.sh` и правила Playwright verification, чтобы агент запускал браузерные проверки из контекста проекта.
- Обновлены bundled-инструкции `playwright` skill: при наличии `scripts/pwcli.sh` агент должен использовать project-local wrapper.
- `scripts/hooks-install.sh` теперь пропускает установку hooks вне git-репозитория, чтобы `make init` не падал в локальных non-git копиях.
- Добавлен единый onboarding installer `scripts/onboarding-install.sh`, который синхронизирует `AGENTS.md`, `docs`, Codex skills, Makefile, init/up/down scripts и project tooling из `docker-sample`.
- `make bootstrap`, `make onboarding` и `make init` теперь используют общий onboarding installer, чтобы один пакет автоматически попадал в каждый проект.
- Bundled `AGENTS.md` и `docs` в `docker-sample` синхронизированы с сокращённой root-документацией без старых task-specific артефактов.
- Добавлен текстовый гайд `docs/new-employee-onboarding.md`; в `README.md` подключение onboarding-пакета оформлено как шаг 1 развёртывания проекта.
- Project links для `AGENTS.md` и `docs` теперь предпочитают `docker-sample` как источник, чтобы существующие shared-файлы в `~/projects` не перекрывали актуальный onboarding-пакет.
- В `README.md` структура клиентского проекта разделена на минимальную структуру до onboarding и symlink/tooling, которые добавляются onboarding installer.
- В `README.md` и `docs/new-employee-onboarding.md` уточнено, что `make onboarding` заменяет только прямой вызов `onboarding-install.sh`, а не весь сценарий первого запуска.
- `README.md`, onboarding-гайд и installer приведены к новому имени источника `onboarding-scripts`; fallback на старую папку `docker-sample` сохранён.
- В требования README добавлен `git`, так как первый шаг онбординга начинается с `git clone`.
- По результатам контейнерного smoke test исправлена замена домена в `local_conf.php`: `client-init.sh` больше не ломает кавычки и `$config[...]`.
