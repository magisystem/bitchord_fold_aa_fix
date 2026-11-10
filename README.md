# BitChord Fold

Build automatica di [BitChord](https://github.com/kushagrasinghx/BitChord) con queste modifiche:

1. **Android Auto segue la playlist.** Toccando un brano dentro una cartella (playlist, album, preferiti, recenti…) viene messa in coda l'intera cartella a partire da quel brano. Prima veniva accodato solo il brano toccato e l'AutoPlay riempiva il resto con canzoni esterne.
2. **Layout per pieghevoli.** Sullo schermo interno aperto il player resta fisso a sinistra (copertina, titolo, barra, comandi, volume) e la colonna destra mostra testo o coda, scelti con i pulsanti sotto il player. Si attiva anche in orizzontale e sui tablet in orizzontale; un telefono girato di lato mantiene il layout originale.
3. **Musica locale ordinata in Android Auto.** La musica sul telefono si sfoglia per artista → album → brani (in ordine di traccia), con una voce *Tutti i brani* in cima. Gli album con brani di artisti diversi finiscono sotto *Artisti vari*, i brani senza album sotto *Altri brani*. In *Playlist* c'è una scorciatoia *Musica locale* come primo riquadro.
4. **App separata.** Si installa come *BitChord Fold* (`com.music.bitchord.fold`) accanto a quella ufficiale, e l'avviso di aggiornamento interno segue le release di questo repository.

Il sorgente originale non è copiato qui: il repository contiene solo le patch (`patches/`), lo script che le applica e il workflow.

## Come funziona

Ogni giorno alle 05:17 UTC il workflow `Build BitChord Fold`:

1. legge l'ultima release di BitChord;
2. se qui non esiste ancora una release con lo stesso tag, scarica quel sorgente e applica le patch;
3. compila e firma l'APK con la tua chiave;
4. pubblica la release `BitChord-<versione>.apk` (universale) e `..._arm64-v8a.apk`.

All'avvio, l'app installata vede la nuova release e propone l'aggiornamento dall'interno.

Se lo sviluppatore cambia il codice toccato da una patch, il workflow si ferma e apre una issue **"Patch da riadattare per vX"**. GitHub ti avvisa per mail.

## Configurazione (una volta sola)

1. Crea un repository (anche privato) e caricaci il contenuto di questa cartella.
   Se è privato, l'aggiornamento interno all'app non potrà leggere le release: in quel caso scarica gli APK a mano o usa Obtainium con un token.
2. In **Settings → Secrets and variables → Actions** crea i quattro secret indicati in `SECRET-GITHUB.txt`:
   `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`.
   Facoltativi: `LASTFM_API_KEY` e `LASTFM_SECRET` se vuoi lo scrobbling su Last.fm (chiavi da last.fm/api).
3. In **Actions** abilita i workflow, apri *Build BitChord Fold* → **Run workflow**.
   La prima build richiede 15–30 minuti.
4. Scarica `BitChord-<versione>_arm64-v8a.apk` dalla release e installalo sul telefono.
5. Apri BitChord Fold e accedi di nuovo con il tuo account Google (è un'app separata, non condivide login e impostazioni con quella ufficiale).

In Android Auto comparirà come *BitChord Fold*. Se non compare, verifica che in Android Auto → Impostazioni sviluppatore sia attiva l'opzione per le fonti sconosciute (serve già per BitChord ufficiale).

## Versioni

Le release si chiamano come quella ufficiale più la revisione del fork, letta dal file `FORK_REVISION`: per esempio `v1.9.1.2` è BitChord 1.9.1 con la revisione 2 delle patch. Quando cambi o aggiungi una patch, aumenta il numero in `FORK_REVISION`: l'app proporrà l'aggiornamento.

## Ricompilare a mano

*Actions → Build BitChord Fold → Run workflow*:

- **tag** vuoto = ultima release; oppure un tag preciso, es. `v1.9.1`;
- **force** = ricompila anche se la release esiste già (utile dopo aver modificato una patch).

## Riadattare una patch

```bash
scripts/prepare-source.sh v1.9.2 /tmp/bitchord   # si ferma sulla patch che non si applica
```

Poi correggi il codice nel sorgente, fai commit e rigenera le patch:

```bash
cd /tmp/bitchord
git format-patch <tag-upstream>..HEAD -o <questo-repo>/patches
```

Con Claude Code basta chiedere: *"la patch per vX non si applica più, riadattala"*.

## Limiti noti

- **Wear OS**: l'app per l'orologio si abbina solo all'app ufficiale (stesso pacchetto e stessa firma), non a BitChord Fold.
- **Video musicali**: sullo schermo interno aperto vengono mostrati a schermo intero, come sui tablet in orizzontale.
- **Last.fm**: senza i secret facoltativi lo scrobbling su Last.fm non è attivo; ListenBrainz funziona comunque.

## Licenza

BitChord è distribuito con licenza GPLv3; le patch in questo repository lo sono altrettanto.
