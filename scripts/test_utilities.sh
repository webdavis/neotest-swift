#!/usr/bin/env bash

project_root_folder="$(dirname "$(cd "${BASH_SOURCE[0]%/*}" && pwd)")"
readonly PROJECT_ROOT="$project_root_folder"

readonly MINIMAL_INIT_FILE="${PROJECT_ROOT}/scripts/minimal_init.lua"
readonly LOG_FILE="${PROJECT_ROOT}/test_output.txt"

function setup_signal_handling() {
  # Handle process interruption signals.
  trap wrap_up SIGINT SIGTERM

  # Handle the EXIT signal for any script termination.
  trap wrap_up EXIT
}

function wrap_up() {
    # Capture the exit status of the last command before trap was triggered.
    local exit_status=$?

    local errors
    set +e
    errors="$(detect_plenary_errors)"
    set -e
    if [[ -n $errors || $exit_status -ne 0 ]]; then
      echo "Terminating... script failed!" >&2
      exit $exit_status
    fi
}

function verify_nvim_installed() {
  if ! command -v nvim &>/dev/null; then
    echo 'nvim is not installed' >&2
    exit 1
  fi
}

function check_dependencies() {
  verify_nvim_installed
}

function parse_command_line_arguments() {
  local short='o:s:'
  local long='options:,scope:'

  local options
  options="$(getopt -o "$short" --long "$long" -- "$@")"

  eval set -- "$options"

  local test_scope plenary_options

  while true; do
    case "$1" in
      -o | --options)
        plenary_options="$2"
        shift 2
        ;;
      -s | --scope)
        test_scope="${PROJECT_ROOT}/${2}"
        shift 2
        ;;
      --)
        shift
        break
        ;;
    esac
  done

  if [[ -z $test_scope ]]; then
    test_scope="${PROJECT_ROOT}/tests/"
    if [[ ! -d $test_scope ]]; then
      echo "Test path does not exist: ${test_scope}" >&2
      exit 1
    fi

    if ! find "$test_scope" -name "*_spec.lua" -print -quit | read -r; then
      echo "No test files detected in $test_scope" >&2
      exit 1
    fi
  fi

  if [[ -z $plenary_options ]]; then
    plenary_options="{ minimal_init = '$MINIMAL_INIT_FILE' }"
  fi

  readonly NVIM_COMMAND="PlenaryBustedDirectory ${test_scope} ${plenary_options}"
}

function run_tests() {
  nvim --headless --noplugin -u "$MINIMAL_INIT_FILE" -c "$NVIM_COMMAND" | tee "$LOG_FILE"
}

# Plenary doesn't emit exit code 1 when tests have errors during setup.
function detect_plenary_errors() {
  sed 's/\x1b\[[0-9;]*m//g' "$LOG_FILE" | awk '/(Errors|Failed) :/ {print $3}' | grep -v '0'
}
