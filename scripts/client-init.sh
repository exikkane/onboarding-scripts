#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOMAIN="${1:-}"
IMPORT_MODE="${CLIENT_INIT_MODE:-full}"
STATE_FILE="${ROOT_DIR}/.client-domain"
PROJECTS_ROOT="$(dirname "${ROOT_DIR}")"

LIGHT_IMPORT_SKIP_TABLES=(
    cscart_also_bought_products
    cscart_attachment_descriptions
    cscart_attachments
    cscart_cp_em_logs
    cscart_csc_search_speedup_clusters
    cscart_csc_search_speedup_index
    cscart_csc_search_speedup_products_clusters_0
    cscart_csc_search_speedup_products_clusters_1
    cscart_csc_search_speedup_products_clusters_2
    cscart_csc_search_speedup_products_clusters_3
    cscart_csc_search_speedup_products_clusters_4
    cscart_csc_search_speedup_products_clusters_5
    cscart_csc_search_speedup_products_clusters_6
    cscart_csc_search_speedup_products_clusters_7
    cscart_csc_search_speedup_products_clusters_8
    cscart_csc_search_speedup_products_clusters_9
    cscart_discussion
    cscart_discussion_messages
    cscart_discussion_posts
    cscart_discussion_rating
    cscart_images
    cscart_images_links
    cscart_logs
    cscart_order_data
    cscart_order_details
    cscart_order_docs
    cscart_order_logs
    cscart_order_transactions
    cscart_orders
    cscart_product_bundle_descriptions
    cscart_product_bundle_images
    cscart_product_bundle_product_links
    cscart_product_bundles
    cscart_product_descriptions
    cscart_product_feature_variant_descriptions
    cscart_product_feature_variants
    cscart_product_features_values
    cscart_product_file_descriptions
    cscart_product_file_ekeys
    cscart_product_file_folder_descriptions
    cscart_product_file_folders
    cscart_product_files
    cscart_product_option_variants
    cscart_product_option_variants_descriptions
    cscart_product_options_exceptions
    cscart_product_options_inventory
    cscart_product_point_prices
    cscart_product_popularity
    cscart_product_prices
    cscart_product_required_products
    cscart_product_sales
    cscart_product_subscriptions
    cscart_product_variation_data_identity_map
    cscart_product_variation_group_products
    cscart_product_variation_groups
    cscart_products
    cscart_products_categories
    cscart_seo_redirects
    cscart_sessions
    cscart_stored_sessions
    cscart_ult_product_descriptions
    cscart_user_session_products
    cscart_warehouses_destination_products_amount
    cscart_warehouses_products_amount
    cscart_warehouses_sum_products_amount
    cscart_yml_exclude_objects
)

if [[ -z "${DOMAIN}" ]]; then
    echo "Domain is required. Usage: make init domain=client.example [mode=light]" >&2
    exit 1
fi

case "${IMPORT_MODE}" in
    "" | full)
        IMPORT_MODE="full"
        ;;
    light | lite | minimal)
        IMPORT_MODE="light"
        ;;
    *)
        echo "Unsupported init mode: ${IMPORT_MODE}. Use full or light." >&2
        exit 1
        ;;
esac

if [[ -f "${ROOT_DIR}/.gitignore.env" && ! -e "${ROOT_DIR}/.gitignore" ]]; then
    mv "${ROOT_DIR}/.gitignore.env" "${ROOT_DIR}/.gitignore"
fi

update_local_conf() {
    local file_path="${1}"

    if [[ ! -f "${file_path}" ]]; then
        echo "Config file not found: ${file_path}" >&2
        exit 1
    fi

    DOMAIN="${DOMAIN}" perl -0pi -e 's/\$config\[\x27http_host\x27\]\s*=\s*\x27[^\x27]*\x27;/\$config[\x27http_host\x27] = \x27$ENV{DOMAIN}\x27;/g; s/\$config\[\x27https_host\x27\]\s*=\s*\x27[^\x27]*\x27;/\$config[\x27https_host\x27] = \x27$ENV{DOMAIN}\x27;/g' "${file_path}"
}

update_vhost() {
    local file_path="${1}"

    if [[ ! -f "${file_path}" ]]; then
        echo "Vhost file not found: ${file_path}" >&2
        exit 1
    fi

    perl -0pi -e "s/ServerName\\s+\\S+/ServerName ${DOMAIN}/g" "${file_path}"
}

find_sql_dump() {
    local extracted_dir="${1}"

    find "${extracted_dir}/var/restore" -maxdepth 1 -type f -name '*.sql' | sort | head -n 1
}

wait_for_mariadb() {
    local retries=60

    until sudo docker compose exec -T mariadb mariadb -uroot -proot -e "SELECT 1" >/dev/null 2>&1; do
        retries=$((retries - 1))
        if [[ "${retries}" -le 0 ]]; then
            echo "MariaDB is not ready for authenticated queries in time." >&2
            exit 1
        fi
        sleep 2
    done
}

install_hooks() {
    echo "Installing pre-commit hooks"
    HOOKS_INSTALL_SKIP_STAGED_RUN=1 bash "${ROOT_DIR}/scripts/hooks-install.sh"
}

import_light_sql_dump() {
    local sql_dump="${1}"
    local skip_tables

    skip_tables="$(IFS=,; printf '%s' "${LIGHT_IMPORT_SKIP_TABLES[*]}")"

    echo "Light import skips INSERT rows for ${#LIGHT_IMPORT_SKIP_TABLES[@]} heavy tables."

    {
        printf 'SET FOREIGN_KEY_CHECKS=0;\n'
        CLIENT_INIT_LIGHT_SKIP_TABLES="${skip_tables}" perl -ne '
            BEGIN {
                %skip = map { $_ => 1 } grep { length } split /,/, $ENV{"CLIENT_INIT_LIGHT_SKIP_TABLES"};
            }

            if (/^INSERT INTO `([^`]+)`/ && $skip{$1}) {
                next;
            }

            print;
        ' "${sql_dump}"
        printf '\nSET FOREIGN_KEY_CHECKS=1;\n'
    } | sudo docker compose exec -T mariadb mariadb -uroot -proot cscart
}

run_light_import_cleanup() {
    echo "Resetting product counters after light import"
    sudo docker compose exec -T mariadb mariadb -uroot -proot cscart <<'SQL'
UPDATE cscart_categories SET product_count = 0;
SQL
}

import_sql_dump() {
    local sql_dump="${1}"

    case "${IMPORT_MODE}" in
        full)
            echo "Importing SQL dump ${sql_dump}"
            {
                printf 'SET FOREIGN_KEY_CHECKS=0;\n'
                cat "${sql_dump}"
                printf '\nSET FOREIGN_KEY_CHECKS=1;\n'
            } | sudo docker compose exec -T mariadb mariadb -uroot -proot cscart
            ;;
        light)
            echo "Importing SQL dump ${sql_dump} in light mode"
            import_light_sql_dump "${sql_dump}"
            run_light_import_cleanup
            ;;
    esac
}

install_onboarding_bundle() {
    local installer="${ROOT_DIR}/scripts/onboarding-install.sh"

    if [[ ! -f "${installer}" && -f "${PROJECTS_ROOT}/onboarding-scripts/scripts/onboarding-install.sh" ]]; then
        installer="${PROJECTS_ROOT}/onboarding-scripts/scripts/onboarding-install.sh"
    fi

    if [[ ! -f "${installer}" && -f "${PROJECTS_ROOT}/docker-sample/scripts/onboarding-install.sh" ]]; then
        installer="${PROJECTS_ROOT}/docker-sample/scripts/onboarding-install.sh"
    fi

    if [[ ! -f "${installer}" ]]; then
        echo "Onboarding installer not found. Skipping onboarding sync."
        return 0
    fi

    bash "${installer}" --shared --project "${ROOT_DIR}" --skills
}

install_onboarding_bundle
install_hooks

SQL_DUMP="$(find_sql_dump "${ROOT_DIR}")"

if [[ -z "${SQL_DUMP}" || ! -f "${SQL_DUMP}" ]]; then
    echo "SQL dump not found in ${ROOT_DIR}/var/restore. Put a .sql backup there before make init." >&2
    exit 1
fi

update_local_conf "${ROOT_DIR}/local_conf.php"
update_vhost "${ROOT_DIR}/docker/apache/vhost.conf"
update_vhost "${ROOT_DIR}/docker/apache/vhost-ssl.conf"

printf '%s\n' "${DOMAIN}" > "${STATE_FILE}"

echo "Setting permissions on var/"
if [[ -d "${ROOT_DIR}/var" ]]; then
    sudo chmod -R 0777 "${ROOT_DIR}/var"
fi

echo "Resetting MariaDB data directory"
mkdir -p "${ROOT_DIR}/mariadb"
sudo find "${ROOT_DIR}/mariadb" -mindepth 1 -delete

echo "Starting containers"
make -C "${ROOT_DIR}" up

echo "Waiting for MariaDB"
wait_for_mariadb

echo "Recreating database"
sudo docker compose exec -T mariadb mariadb -uroot -proot -e "DROP DATABASE IF EXISTS cscart; CREATE DATABASE cscart CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

import_sql_dump "${SQL_DUMP}"

echo "Initialization completed for ${DOMAIN}"
