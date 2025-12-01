#!/usr/bin/env bash
set -euo pipefail

###########################################################
# Timpi Synaptron – Installer (Linux)
# - Creates ~/Synaptron
# - Fixes permissions ONLY if needed
# - Downloads run_synaptron.sh + docker-compose.yml
# - Prompts user for:
#     NAME (>=17 chars, safe charset)
#     GUID
# - Patches docker-compose.yml
# - Runs run_synaptron.sh
###########################################################

REPO_BASE="https://raw.githubusercontent.com/johnolofs/timpi/main/Synaptron"
INSTALL_DIR="${HOME}/Synaptron"
YML_FILE="docker-compose.yml"
RUN_FILE="run_synaptron.sh"

echo "===== Timpi Synaptron – Installer ====="
echo
echo "Install directory: ${INSTALL_DIR}"
echo

mkdir -p "${INSTALL_DIR}"

###########################################################
# CONDITIONAL PERMISSION FIX (only if needed)
###########################################################
if [ ! -w "${INSTALL_DIR}" ]; then
  echo "⚠ Permission issue detected for ${INSTALL_DIR}"
  echo "🔧 Fixing ownership (sudo chown -R ${USER}:${USER} ${INSTALL_DIR})..."
  sudo chown -R "$USER:$USER" "${INSTALL_DIR}"
  echo "✔ Permissions fixed."
fi

cd "${INSTALL_DIR}"

echo "📂 Using directory: ${INSTALL_DIR}"
echo

echo "📥 Downloading ${RUN_FILE}..."
curl -fsS -o "${RUN_FILE}" "${REPO_BASE}/${RUN_FILE}"

echo "📥 Downloading ${YML_FILE}..."
curl -fsS -o "${YML_FILE}" "${REPO_BASE}/${YML_FILE}"

chmod +x "${RUN_FILE}"

###########################################################
# Helper: read input from TTY (works with curl | bash)
###########################################################
read_from_tty() {
  local prompt="$1"
  local varname="$2"
  local value

  while true; do
    printf "%s" "${prompt}" > /dev/tty
    if ! IFS= read -r value < /dev/tty; then
      echo >&2 "❌ Could not read input from terminal."
      exit 1
    fi
    value="${value#" "}"
    value="${value%" "}"
    eval "$varname=\"\$value\""
    return 0
  done
}

###########################################################
# Ask for NAME (>=17 chars, safe characters only)
###########################################################
echo
echo "🧾 Configure your Synaptron node identity"
echo "Your node will need:"
echo "  - A NAME (at least 17 characters)"
echo "  - A GUID (provided by Timpi)"
echo

NODE_NAME=""
while true; do
  read_from_tty "Enter Synaptron node NAME (>=17 chars, A–Z, a–z, 0–9, _ and - only): " NODE_NAME

  # Keep only safe characters
  SAFE_NAME="$(printf "%s" "$NODE_NAME" | tr -cd 'A-Za-z0-9_-')"

  if [[ -z "$SAFE_NAME" ]]; then
    echo "❌ Name became empty after removing invalid characters. Try again." > /dev/tty
    continue
  fi

  if [[ ${#SAFE_NAME} -lt 17 ]]; then
    echo "❌ Name too short (${#SAFE_NAME} chars). Must be at least 17 characters." > /dev/tty
    continue
  fi

  echo "✅ Using node NAME: ${SAFE_NAME}" > /dev/tty
  NODE_NAME="$SAFE_NAME"
  break
done

###########################################################
# Ask for GUID (simple sanitization)
###########################################################
NODE_GUID=""
while true; do
  read_from_tty "Paste your Synaptron GUID: " NODE_GUID

  # Keep only A–Z, a–z, 0–9 and dash
  SAFE_GUID="$(printf "%s" "$NODE_GUID" | tr -cd 'A-Za-z0-9-')"

  if [[ -z "$SAFE_GUID" ]]; then
    echo "❌ GUID became empty after removing invalid characters. Try again." > /dev/tty
    continue
  fi

  if [[ ${#SAFE_GUID} -lt 16 ]]; then
    echo "⚠ GUID looks short (${#SAFE_GUID} chars). Are you sure it's correct?" > /dev/tty
    # still allow – some GUID formats may vary
  fi

  echo "✅ Using GUID: ${SAFE_GUID}" > /dev/tty
  NODE_GUID="$SAFE_GUID"
  break
done

###########################################################
# Patch NAME and GUID into docker-compose.yml
###########################################################
echo
echo "✏ Updating docker-compose.yml with your NAME and GUID..."
sed -i "s#^\s*NAME:.*#  NAME: ${NODE_NAME}#" "${YML_FILE}"
sed -i "s#^\s*GUID:.*#  GUID: ${NODE_GUID}#" "${YML_FILE}"

echo "✅ Configuration written."
echo

###########################################################
# Launch main Synaptron runner
###########################################################
echo "🚀 Starting Synaptron setup..."
./"${RUN_FILE}"
