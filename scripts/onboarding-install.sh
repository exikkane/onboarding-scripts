#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECTS_ROOT="${PROJECTS_ROOT:-${HOME}/projects}"
CODEX_HOME_DIR="${CODEX_HOME:-${HOME}/.codex}"
CODEX_SKILLS_DIR="${CODEX_SKILLS_DIR:-${CODEX_HOME_DIR}/skills}"
CODEX_COMPAT_SKILLS_DIR="${CODEX_COMPAT_SKILLS_DIR:-${HOME}/codex/skills}"
ONBOARDING_FAILED=0

REQUIRED_SKILLS=(
    cscart-hooks-finder
    playwright
    cscart-db-inspector
)

PROJECT_ONBOARDING_PATHS=(
    AGENTS.md
    docs
    .gitignore.env
    .pre-commit-config.yaml
    Makefile
    phpcs.xml.dist
    scripts/client-down.sh
    scripts/client-init.sh
    scripts/client-up.sh
    scripts/dev-bootstrap.sh
    scripts/hooks-install.sh
    scripts/onboarding-install.sh
    scripts/pwcli.sh
    tools/pre-commit
)

mark_failed() {
    ONBOARDING_FAILED=1
}

is_onboarding_source() {
    local candidate="${1}"

    [[ -n "${candidate}" && -f "${candidate}/AGENTS.md" && -d "${candidate}/docs" ]]
}

resolve_onboarding_source() {
    local candidate

    if [[ -n "${ONBOARDING_SOURCE_ROOT:-}" ]]; then
        if is_onboarding_source "${ONBOARDING_SOURCE_ROOT}"; then
            printf '%s\n' "${ONBOARDING_SOURCE_ROOT}"
            return 0
        fi

        echo "Invalid ONBOARDING_SOURCE_ROOT: ${ONBOARDING_SOURCE_ROOT}" >&2
        mark_failed
    fi

    for candidate in \
        "${PROJECTS_ROOT}/onboarding-scripts" \
        "${PROJECTS_ROOT}/docker-sample" \
        "${ROOT_DIR}" \
        "${PROJECTS_ROOT}"
    do
        if is_onboarding_source "${candidate}"; then
            printf '%s\n' "${candidate}"
            return 0
        fi
    done

    echo "Cannot resolve onboarding source. Expected AGENTS.md and docs in onboarding-scripts, docker-sample, current project, or PROJECTS_ROOT." >&2
    mark_failed
    printf '%s\n' "${ROOT_DIR}"
}

SOURCE_ROOT="$(resolve_onboarding_source)"

same_path() {
    [[ "$(readlink -m "${1}")" == "$(readlink -m "${2}")" ]]
}

ensure_symlink() {
    local source_path="${1}"
    local target_path="${2}"
    local keep_existing="${3:-0}"

    if [[ ! -e "${source_path}" ]]; then
        echo "Missing source path: ${source_path}" >&2
        mark_failed
        return 0
    fi

    mkdir -p "$(dirname "${target_path}")"

    if same_path "${source_path}" "${target_path}"; then
        echo "Already installed: ${target_path}"
        return 0
    fi

    if [[ -L "${target_path}" ]]; then
        ln -sfn "${source_path}" "${target_path}"
        echo "Linked ${target_path} -> ${source_path}"
        return 0
    fi

    if [[ -e "${target_path}" ]]; then
        if [[ "${keep_existing}" == "1" ]]; then
            echo "Existing target kept: ${target_path}"
            return 0
        fi

        echo "Target exists and is not a symlink: ${target_path}" >&2
        echo "Move it away and rerun onboarding install." >&2
        mark_failed
        return 0
    fi

    ln -s "${source_path}" "${target_path}"
    echo "Linked ${target_path} -> ${source_path}"
}

shared_source_path() {
    local relative_path="${1}"

    if [[ -e "${SOURCE_ROOT}/${relative_path}" ]]; then
        printf '%s\n' "${SOURCE_ROOT}/${relative_path}"
        return 0
    fi

    printf '%s\n' "${PROJECTS_ROOT}/${relative_path}"
}

install_shared_project_sources() {
    echo "Installing shared onboarding sources into ${PROJECTS_ROOT}"
    mkdir -p "${PROJECTS_ROOT}"

    ensure_symlink "${SOURCE_ROOT}/AGENTS.md" "${PROJECTS_ROOT}/AGENTS.md" 1
    ensure_symlink "${SOURCE_ROOT}/docs" "${PROJECTS_ROOT}/docs" 1

    if [[ -d "${SOURCE_ROOT}/codex" ]]; then
        ensure_symlink "${SOURCE_ROOT}/codex" "${PROJECTS_ROOT}/codex" 1
    fi
}

install_project_onboarding() {
    local target_project="${1}"
    local relative_path source_path target_path

    echo "Installing project onboarding links into ${target_project}"

    for relative_path in "${PROJECT_ONBOARDING_PATHS[@]}"; do
        case "${relative_path}" in
            AGENTS.md | docs)
                source_path="$(shared_source_path "${relative_path}")"
                ;;
            *)
                source_path="${SOURCE_ROOT}/${relative_path}"
                ;;
        esac

        target_path="${target_project}/${relative_path}"
        ensure_symlink "${source_path}" "${target_path}" 1
    done
}

find_skill_source() {
    local skill_name="${1}"
    local source_roots=()
    local source_root

    if [[ -n "${CODEX_SKILLS_SOURCE:-}" ]]; then
        source_roots+=("${CODEX_SKILLS_SOURCE}")
    fi

    source_roots+=(
        "${SOURCE_ROOT}/codex/skills"
        "${PROJECTS_ROOT}/codex/skills"
        "${ROOT_DIR}/codex/skills"
        "${HOME}/codex/skills"
        "${HOME}/.codex/skills"
    )

    for source_root in "${source_roots[@]}"; do
        if [[ -d "${source_root}/${skill_name}" ]]; then
            printf '%s\n' "${source_root}/${skill_name}"
            return 0
        fi
    done

    return 1
}

skills_target_dirs() {
    printf '%s\n' "${CODEX_SKILLS_DIR}"

    if [[ "$(readlink -m "${CODEX_COMPAT_SKILLS_DIR}")" != "$(readlink -m "${CODEX_SKILLS_DIR}")" ]]; then
        printf '%s\n' "${CODEX_COMPAT_SKILLS_DIR}"
    fi
}

install_skill() {
    local skill_name="${1}"
    local source_path
    local target_dir

    if ! source_path="$(find_skill_source "${skill_name}")"; then
        echo "Missing Codex skill source: ${skill_name}" >&2
        echo "Expected it in CODEX_SKILLS_SOURCE, onboarding source, PROJECTS_ROOT/codex/skills, ~/codex/skills, or ~/.codex/skills." >&2
        mark_failed
        return 0
    fi

    while IFS= read -r target_dir; do
        mkdir -p "${target_dir}"
        ensure_symlink "${source_path}" "${target_dir}/${skill_name}" 1
    done < <(skills_target_dirs)
}

install_codex_skills() {
    local skill_name

    echo "Installing Codex skills"

    for skill_name in "${REQUIRED_SKILLS[@]}"; do
        install_skill "${skill_name}"
    done
}

usage() {
    cat <<'TEXT'
Usage: onboarding-install.sh [--shared] [--skills] [--project /path/to/project]

Options:
  --shared            Link shared AGENTS.md, docs and codex sources into PROJECTS_ROOT.
  --skills            Install required Codex skills into CODEX_SKILLS_DIR and compatibility dir.
  --project <path>    Link onboarding files into a concrete project.

Environment:
  ONBOARDING_SOURCE_ROOT  Source repo with AGENTS.md, docs and codex/skills.
  PROJECTS_ROOT           Projects root, defaults to ~/projects.
  CODEX_SKILLS_DIR        Primary Codex skills directory, defaults to ~/.codex/skills.
TEXT
}

if [[ "$#" -eq 0 ]]; then
    set -- --shared --skills
fi

echo "Onboarding source: ${SOURCE_ROOT}"

while [[ "$#" -gt 0 ]]; do
    case "${1}" in
        --shared)
            install_shared_project_sources
            shift
            ;;
        --skills)
            install_codex_skills
            shift
            ;;
        --project)
            if [[ -z "${2:-}" ]]; then
                echo "--project requires a path" >&2
                usage >&2
                exit 1
            fi
            install_project_onboarding "${2}"
            shift 2
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: ${1}" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [[ "${ONBOARDING_FAILED}" -ne 0 ]]; then
    echo "Onboarding install completed with errors." >&2
    exit 1
fi

echo "Onboarding install completed."
