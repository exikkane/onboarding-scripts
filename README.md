# **Онбординг и развёртывание первого проекта**

## **Требования**

Перед началом работы должны быть установлены:

* `docker`
* `docker compose`
* `git`
* `make`
* `sudo`
* `node`/`npm` с доступным `npx` для Playwright skill

## **1. Установить onboarding-пакет на машину**

Один раз клонируем `onboarding-scripts` в общий каталог проектов и запускаем bootstrap.

```bash
mkdir -p ~/projects
git clone git@github.com:exikkane/onboarding-scripts.git ~/projects/onboarding-scripts
cd ~/projects/onboarding-scripts
make bootstrap
```

После этого на машине появятся:

- `~/projects/AGENTS.md` и `~/projects/docs` как инструкции для всех проектов. Они будут прилинкованы в каждый проект при подключении onboarding.

- `~/projects/codex` как источник Codex skills

## **2. Склонировать клиентский проект** (ссылку на репо получить у Антона)

Проект клонируется сразу в `~/projects/<project-name>`.

```bash
git clone <client-project-repo-url> ~/projects/<project-name>
cd ~/projects/<project-name>
```

В проекте должен быть SQL-дамп (если дампа нет - попросить у Антона или Даниила):

```text
var/restore/*.sql
```

## **3. Развёртывание проекта**

Перед импортом базы и запуском контейнеров подключаем onboarding-пакет.

Для первого подключения проекта запускаем installer из `onboarding-scripts`:

```bash
ONBOARDING_SOURCE_ROOT=~/projects/onboarding-scripts \
  bash ~/projects/onboarding-scripts/scripts/onboarding-install.sh --shared --project "$PWD" --skills
```

Если проект уже подключён к onboarding и в нём доступна команда `make onboarding`, дальнейшие обновления onboarding-пакета можно выполнять короче:

```bash
make onboarding
```

Этот шаг добавляет или обновляет ссылки на:

* `AGENTS.md`
* `docs`
* `.gitignore.env`
* `.pre-commit-config.yaml`
* `Makefile`
* `phpcs.xml.dist`
* `scripts/client-init.sh`
* `scripts/client-up.sh`
* `scripts/client-down.sh`
* `scripts/dev-bootstrap.sh`
* `scripts/hooks-install.sh`
* `scripts/onboarding-install.sh`
* `scripts/pwcli.sh`
* `tools/pre-commit`

После подключения onboarding запускаем первичную инициализацию.

```bash
make init domain=<client-domain>
```

Для быстрого старта без тяжёлых данных можно использовать light-режим (на случай если у клиентов огромная база):

```bash
make init domain=<client-domain> mode=light
```

> `make init` доступен только после подключения onboarding `Makefile`/scripts. Поэтому для старого проекта сначала один раз выполняется installer из `onboarding-scripts`, потом уже `make init`.

## **Что делают команды**

`make init`

* используется только для первичного разворачивания проекта
* требует `domain=...`
* автоматически запускает `make up`

`make up`

* читает домен из `.client-domain`
* добавляет запись в `/etc/hosts`
* поднимает контейнеры

`make down`

* удаляет запись проекта из `/etc/hosts`
* останавливает контейнеры

При `make up` в `/etc/hosts` автоматически добавляется блок вида:

```text
# >>> client-project:/home/exikane/projects/client-project >>>
127.0.0.1 client-domain.ru
# <<< client-project:/home/exikane/projects/client-project <<<
```

Это позволяет работать на локали используя доменное имя клиента. В случаях когда клиент использует стороннюю тему или модули с менеджером лицензий - это позволяет работать на копии магазина клиента без постоянной проблемы с валидациями лицензий.

При `make down` этот блок автоматически удаляется.



## **Быстрый гайд**

Короткий сценарий:

```bash
mkdir -p ~/projects
git clone git@github.com:exikkane/onboarding-scripts.git ~/projects/onboarding-scripts
cd ~/projects/onboarding-scripts
make bootstrap

git clone <client-project-repo-url> ~/projects/<project-name>
cd ~/projects/<project-name>

# Шаг 1 развёртывания проекта: подключить onboarding-пакет.
ONBOARDING_SOURCE_ROOT=~/projects/onboarding-scripts \
  bash ~/projects/onboarding-scripts/scripts/onboarding-install.sh --shared --project "$PWD" --skills

make init domain=<client-domain>
```
