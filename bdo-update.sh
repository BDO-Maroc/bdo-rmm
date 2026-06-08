#!/usr/bin/env bash

SCRIPT_VERSION="1"
SCRIPT_URL='https://raw.githubusercontent.com/VOTRE_GITHUB_USER/bdo-rmm/main/bdo-update.sh'

# ============================================================
# BDO RMM - Script de mise a jour personnalise
# Base sur le update.sh officiel de Tactical RMM
# ============================================================
# Ce script met a jour votre instance BDO RMM depuis votre
# repo GitHub prive. Il preserve :
#   - local_settings.py (tokens, DB, secrets)
#   - media/ (logos uploades)
#   - La base de donnees (seulement des migrations)
# ============================================================

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'
THIS_SCRIPT=$(readlink -f "$0")

# ============ CONFIGURATION ============
# Modifiez ces valeurs avec vos repos GitHub
BDO_BACKEND_REPO="https://github.com/VOTRE_GITHUB_USER/bdo-rmm.git"
BDO_FRONTEND_REPO="https://github.com/VOTRE_GITHUB_USER/bdo-rmm-web.git"
BDO_BRANCH="main"

# Chemins sur le serveur (standard Tactical RMM)
RMM_DIR="/rmm"
API_DIR="${RMM_DIR}/api/tacticalrmm"
FRONTEND_DIR="/var/www/rmm"
SETTINGS_FILE="${API_DIR}/tacticalrmm/settings.py"
LOCAL_SETTINGS="${API_DIR}/tacticalrmm/local_settings.py"
MEDIA_DIR="${API_DIR}/media"
SCRIPTS_DIR="/opt/trmm-community-scripts"

# Fichiers a ne JAMAIS ecraser
PROTECTED_FILES=(
  "tacticalrmm/local_settings.py"
)

# ============ VERIFICATIONS ============

if [ $EUID -eq 0 ]; then
  echo -ne "${RED}Ne PAS executer ce script en root. Quittez.${NC}\n"
  exit 1
fi

strip="User="
ORIGUSER=$(grep ${strip} /etc/systemd/system/rmm.service | sed -e "s/^${strip}//")

if [ "$ORIGUSER" != "$USER" ]; then
  printf >&2 "${RED}ERREUR: Vous devez executer ce script avec le meme utilisateur que l'installation: ${GREEN}${ORIGUSER}${NC}\n"
  exit 1
fi

# ============ OPTIONS ============

force=false
skip_frontend=false
backup_only=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --force) force=true; shift ;;
    --skip-frontend) skip_frontend=true; shift ;;
    --backup-only) backup_only=true; shift ;;
    --help)
      echo "Usage: ./bdo-update.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --force           Forcer la mise a jour meme si deja a jour"
      echo "  --skip-frontend   Ne pas mettre a jour le frontend"
      echo "  --backup-only     Sauvegarder seulement, sans mise a jour"
      echo "  --help            Afficher cette aide"
      exit 0
      ;;
    *) echo "Option inconnue: $1"; exit 1 ;;
  esac
done

# ============ FONCTIONS ============

backup_db() {
  local backup_dir="/rmmbackups"
  if [ ! -d "$backup_dir" ]; then
    sudo mkdir -p "$backup_dir"
    sudo chown ${USER}:${USER} "$backup_dir"
  fi

  local timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_file="${backup_dir}/bdo_rmm_${timestamp}.sql"

  printf >&2 "${CYAN}[BDO] Sauvegarde de la base de donnees...${NC}\n"
  sudo -u postgres pg_dump tacticalrmm > "$backup_file"

  if [ $? -eq 0 ]; then
    printf >&2 "${GREEN}[BDO] Sauvegarde: ${backup_file}${NC}\n"
  else
    printf >&2 "${RED}[BDO] ERREUR: Sauvegarde echouee !${NC}\n"
    exit 1
  fi

  # Garder seulement les 5 derniers backups
  ls -t ${backup_dir}/bdo_rmm_*.sql 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null
}

backup_media() {
  if [ -d "$MEDIA_DIR" ]; then
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="/rmmbackups/bdo_media_${timestamp}.tar.gz"
    printf >&2 "${CYAN}[BDO] Sauvegarde du dossier media...${NC}\n"
    tar -czf "$backup_file" -C "$API_DIR" media/ 2>/dev/null
    printf >&2 "${GREEN}[BDO] Media sauvegarde: ${backup_file}${NC}\n"
  fi
}

stop_services() {
  printf >&2 "${CYAN}[BDO] Arret des services...${NC}\n"
  for svc in celerybeat celery; do
    sudo systemctl stop ${svc} 2>/dev/null
  done
  for svc in nginx nats-api nats rmm daphne; do
    sudo systemctl stop ${svc} 2>/dev/null
  done
}

start_services() {
  printf >&2 "${CYAN}[BDO] Demarrage des services...${NC}\n"
  for svc in nats nats-api rmm daphne celery celerybeat nginx; do
    printf >&2 "${GREEN}  Demarrage de ${svc}...${NC}\n"
    sudo systemctl start ${svc}
  done
}

# ============ SAUVEGARDE ============

backup_db
backup_media

if [ "$backup_only" = true ]; then
  printf >&2 "${GREEN}[BDO] Sauvegarde terminee. Aucune mise a jour effectuee.${NC}\n"
  exit 0
fi

# ============ ARRET DES SERVICES ============

stop_services

# ============ MISE A JOUR DU BACKEND ============

printf >&2 "${CYAN}[BDO] Mise a jour du backend depuis GitHub...${NC}\n"

cd ${RMM_DIR}

# Sauvegarder les fichiers proteges
for pfile in "${PROTECTED_FILES[@]}"; do
  if [ -f "${API_DIR}/${pfile}" ]; then
    cp "${API_DIR}/${pfile}" "/tmp/bdo_protected_$(basename ${pfile})"
  fi
done

# Sauvegarder le dossier media
if [ -d "${MEDIA_DIR}" ]; then
  cp -r "${MEDIA_DIR}" /tmp/bdo_media_backup
fi

# Configurer git si necessaire
git config user.email "bdo-admin@bdo.com"
git config user.name "BDO Admin"

# Verifier si le remote pointe deja vers notre repo
CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null)
if [ "$CURRENT_REMOTE" != "$BDO_BACKEND_REPO" ]; then
  printf >&2 "${YELLOW}[BDO] Changement du remote origin vers le repo BDO...${NC}\n"
  git remote set-url origin "$BDO_BACKEND_REPO"
fi

# Mettre a jour
git fetch origin
git checkout ${BDO_BRANCH}
git reset --hard origin/${BDO_BRANCH}

# Restaurer les fichiers proteges
for pfile in "${PROTECTED_FILES[@]}"; do
  local tmpfile="/tmp/bdo_protected_$(basename ${pfile})"
  if [ -f "$tmpfile" ]; then
    cp "$tmpfile" "${API_DIR}/${pfile}"
    rm -f "$tmpfile"
  fi
done

# Restaurer le dossier media
if [ -d /tmp/bdo_media_backup ]; then
  rm -rf "${MEDIA_DIR}"
  mv /tmp/bdo_media_backup "${MEDIA_DIR}"
fi

# S'assurer que le dossier media existe
mkdir -p "${MEDIA_DIR}/branding"

sudo chown ${USER}:${USER} -R ${RMM_DIR}

# ============ MISE A JOUR COMMUNITY SCRIPTS ============

if [[ -d ${SCRIPTS_DIR} ]]; then
  printf >&2 "${CYAN}[BDO] Mise a jour des community scripts...${NC}\n"
  cd ${SCRIPTS_DIR}
  git config user.email "bdo-admin@bdo.com"
  git config user.name "BDO Admin"
  git fetch
  git checkout main
  git reset --hard FETCH_HEAD
  git pull
fi

# ============ MISE A JOUR PYTHON ============

printf >&2 "${CYAN}[BDO] Mise a jour des dependances Python...${NC}\n"

source /rmm/api/env/bin/activate
cd ${API_DIR}
pip install --no-cache-dir -r requirements.txt

# ============ MIGRATIONS & TACHES ============

printf >&2 "${CYAN}[BDO] Execution des migrations Django...${NC}\n"

python manage.py pre_update_tasks 2>/dev/null
celery -A tacticalrmm purge -f 2>/dev/null
python manage.py migrate
python manage.py collectstatic --no-input
python manage.py reload_nats
python manage.py create_natsapi_conf
python manage.py create_uwsgi_conf
python manage.py clear_redis_celery_locks
python manage.py post_update_tasks 2>/dev/null

# Recuperer les variables pour le frontend
API=$(python manage.py get_config api)
FRONTEND=$(python manage.py get_config webdomain)

deactivate

# ============ MISE A JOUR DU FRONTEND ============

if [ "$skip_frontend" = false ]; then
  printf >&2 "${CYAN}[BDO] Mise a jour du frontend...${NC}\n"

  FRONTEND_SRC="/tmp/bdo-rmm-web-build"

  # Cloner ou mettre a jour le frontend
  if [ -d "${FRONTEND_SRC}" ]; then
    rm -rf "${FRONTEND_SRC}"
  fi

  git clone --depth 1 --branch ${BDO_BRANCH} "${BDO_FRONTEND_REPO}" "${FRONTEND_SRC}"

  if [ $? -ne 0 ]; then
    printf >&2 "${RED}[BDO] ERREUR: Impossible de cloner le repo frontend !${NC}\n"
    printf >&2 "${YELLOW}[BDO] Le backend a ete mis a jour mais pas le frontend.${NC}\n"
  else
    cd "${FRONTEND_SRC}"

    # Installer les dependances et builder
    npm install --legacy-peer-deps
    npm run build

    if [ $? -eq 0 ]; then
      # Deployer le build
      sudo rm -rf ${FRONTEND_DIR}/dist
      sudo cp -r dist/spa ${FRONTEND_DIR}/dist

      # Configurer l'URL de l'API
      echo "window._env_ = {PROD_URL: \"https://${API}\"}" | sudo tee ${FRONTEND_DIR}/dist/env-config.js >/dev/null

      sudo chown www-data:www-data -R ${FRONTEND_DIR}/dist
      printf >&2 "${GREEN}[BDO] Frontend mis a jour avec succes !${NC}\n"
    else
      printf >&2 "${RED}[BDO] ERREUR: Le build du frontend a echoue !${NC}\n"
    fi

    # Nettoyer
    rm -rf "${FRONTEND_SRC}"
  fi
fi

# ============ NGINX - AJOUTER MEDIA ============

rmmconf='/etc/nginx/sites-available/rmm.conf'
if ! grep -q "location /media/" "$rmmconf"; then
  printf >&2 "${CYAN}[BDO] Ajout de la configuration media dans nginx...${NC}\n"

  # Ajouter le bloc media avant le bloc location /
  sudo sed -i '/location \/ {/i \
    location /media/ {\
        alias /rmm/api/tacticalrmm/media/;\
        expires 30d;\
        add_header Cache-Control "public, immutable";\
        add_header "Access-Control-Allow-Origin" "https://'"${FRONTEND}"'";\
    }\
' "$rmmconf"
fi

# Verifier la config nginx
if ! sudo nginx -t >/dev/null 2>&1; then
  printf >&2 "${RED}[BDO] ERREUR: Erreur de syntaxe nginx. Verifiez la configuration.${NC}\n"
  sudo nginx -t
fi

# ============ DEMARRAGE ============

start_services

printf >&2 "\n"
printf >&2 "${GREEN}============================================${NC}\n"
printf >&2 "${GREEN}  BDO RMM mis a jour avec succes !${NC}\n"
printf >&2 "${GREEN}============================================${NC}\n"
printf >&2 "\n"
