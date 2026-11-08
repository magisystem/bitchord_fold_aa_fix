#!/usr/bin/env bash
# Prepara il sorgente patchato di BitChord per un tag upstream.
#
#   scripts/prepare-source.sh <tag> <cartella-destinazione>
#
# Clona l'upstream (clone parziale: i file vengono scaricati solo quando
# servono, così git am --3way trova le versioni originali quando deve fondere),
# si porta sul tag, applica le patch in patches/ e rinomina l'app.
# Esce con errore se una patch non si applica: è il segnale che l'upstream
# ha cambiato quel codice e la patch va riadattata.
set -euo pipefail

TAG="${1:?tag upstream mancante (es. v1.9.1)}"
DEST="${2:?cartella di destinazione mancante}"
UPSTREAM="${UPSTREAM_REPO:-https://github.com/kushagrasinghx/BitChord.git}"
APP_NAME="${FORK_APP_NAME:-BitChord Fold}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"

rm -rf "$DEST"
git clone --filter=blob:none --no-checkout "$UPSTREAM" "$DEST"
cd "$DEST"
git -c advice.detachedHead=false checkout "tags/$TAG"

git config user.name  "${GIT_AUTHOR_NAME:-bitchord-fold}"
git config user.email "${GIT_AUTHOR_EMAIL:-bitchord-fold@users.noreply.github.com}"

shopt -s nullglob
patches=("$HERE"/patches/*.patch)
if (( ${#patches[@]} == 0 )); then
    echo "Nessuna patch in $HERE/patches" >&2
    exit 1
fi

for p in "${patches[@]}"; do
    echo "::group::Applico $(basename "$p")"
    if ! git am --3way "$p"; then
        echo "::endgroup::"
        echo "::error::La patch $(basename "$p") non si applica su $TAG" >&2
        git am --show-current-patch=diff | head -n 80 >&2 || true
        git status --short >&2 || true
        git am --abort || true
        exit 2
    fi
    echo "::endgroup::"
done

# Nome visibile dell'app, in tutte le lingue: così sul telefono e in
# Android Auto si distingue dalla versione ufficiale.
find app/src/main/res -path '*/values*/strings.xml' -print0 |
    xargs -0 sed -i -E "s#(<string name=\"app_name\">)[^<]*(</string>)#\1${APP_NAME}\2#"

echo "Sorgente pronto in $DEST ($TAG + ${#patches[@]} patch)"
