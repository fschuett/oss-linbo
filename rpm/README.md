oss-linbo
==========

GNU/Linux Network Boot  
Lizenz: GNU General Public License Version 2

Buildroot
---------

Verwendet wird gerade `buildroot-2019.11`.
Der Buildroot-Subtree sollte nicht veraendert werden, alle Aenderungen gehen in den Ordner `buildroot-external`. Bei ein paar Sachen liess sich das aber nicht vermeiden, die Veraenderungen sind in `buildroot-2019.11.patch` aufgefuehrt.

### Update

Buildroot bringt alle drei Monate eine neue Version raus.
Falls man mit `git subtree pull` arbeitet, erhält man viele Konflikte, stattdessn lässt
sich der Subtree so updaten (Branch, an dem gearbeitet wird heisst `buildroot`):

    $ git checkout -b buildroot-2019.11
    $ git rm -r buildroot
    $ rm -r buildroot
    $ git commit -a
    $ git subtree add --prefix buildroot git://git.buildroot.net/buildroot 2019.11
    $ git checkout <main branch>
    $ git merge -Xtheirs --squash buildroot-2019.11
    $ git commit -a

### Konfiguration anpassen

Buildroot verwendet menuconfig. Zur Konfiguration erst in den `buildroot`-Ordner wechseln.  
Wenn der Paketbau noch nicht angefangen wurde muss erst die defconfig geladen werden:

    $ make BR2_EXTERNAL=../buildroot-external/ O=../build/build-i386/ linbo-i386_defconfig

Bzw.`x86_64` statt `i386` fuer 64 Bit.

    $ make O=../build/build-i386 menuconfig

Um die defconfig zu aktualisieren:

    $ make O=../build/build-i386/ savedefconfig

Um den Kernel zu konfigurieren:

    $ make O=../build/build-i386/ linux-menuconfig

Um die defconfig vom Kernel zu aktualisieren:

    $ make O=../build/build-i386/ linux-savedefconfig
    $ make O=../build/build-i386/ linux-update-defconfig

Paket bauen
-----------

Getestet auf openSUSE Leap 15.1

    $ rpmbuild -ba oss-linbo.spec

**ACHTUNG**: In der rules-Datei wird vor jedem Paketbau auch der `build`-Ordner geloescht, damit saubere Pakete entstehen.
Zum  Basteln also immer mit `--short-circuit` bauen, denn der Paketbau dauert mindestens 2h!
