#!/usr/bin/env bash
# =============================================================================
# ECE 574 -- launch VC Formal FPV for one run
#
#   ./scripts/run_fpv.sh <tag> [--size small|medium|full] [--define NAME]...
#
#   <tag>          name of the run; results go to results/<tag>_<size>/
#   --size         configuration size (small, medium, or full; default full)
#   --define NAME  pass an additional +define+NAME to the compile (repeatable)
#   --gui          open the VC Formal / Verdi GUI instead of batch mode
#
# Examples:
#   ./scripts/run_fpv.sh baseline --size small
#   ./scripts/run_fpv.sh bug_wstrb --size medium --define BUG_WSTRB_IGNORED
#   ./scripts/run_fpv.sh baseline --gui
# =============================================================================
set -euo pipefail

cd "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/.."

if (( $# == 0 )) || [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
    sed -n '2,19p' "$0"
    exit 0
fi

tag="$1"
shift
mode="-batch"
size="full"
defs=""

while (( $# > 0 )); do
    case "$1" in
        --gui)
            mode="-verdi"
            ;;
        --size)
            if (( $# < 2 )); then
                echo "ERROR: --size requires small, medium, or full" >&2
                exit 1
            fi
            size="${2,,}"
            shift
            ;;
        --define)
            if (( $# < 2 )); then
                echo "ERROR: --define requires a macro name" >&2
                exit 1
            fi
            if [[ ! "$2" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
                echo "ERROR: invalid define name: $2" >&2
                exit 1
            fi
            defs="${defs} +define+$2"
            shift
            ;;
        *)
            echo "ERROR: unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

case "$size" in
    small)  size_define="+define+SMALL" ;;
    medium) size_define="+define+MEDIUM" ;;
    full)   size_define="" ;;
    *)
        echo "ERROR: invalid size '$size'; use small, medium, or full" >&2
        exit 1
        ;;
esac

if [[ ! "${tag}" =~ ^[A-Za-z0-9_.-]+$ ]]; then
    echo "ERROR: tag may contain only letters, digits, '.', '_', and '-'" >&2
    exit 1
fi

if ! command -v vcf >/dev/null 2>&1; then
    echo "ERROR: 'vcf' is not available in PATH" >&2
    exit 1
fi

export FV_DEFINES="${size_define}${defs}"
export FV_TAG="${tag}_${size}"
mkdir -p "results/${FV_TAG}"

echo "== VC Formal: tag=${tag} size=${size} defines='${FV_DEFINES}'"
vcf ${mode} -f scripts/run_fpv.tcl 2>&1 | tee "results/${FV_TAG}/vcf.log"
