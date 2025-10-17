
"""
Creați 2 scripturi:
○	Un script python ce face backup la fișierul system-state.log
■	Backup-ul trebuie să fie făcut doar dacă fișierul s-a modificat.
■	Perioada la care se face backup este primită ca variabilă de mediu cu valoarea implicită 5 secunde.
■	Fișierul de backup trebuie să conțină în nume și data la care a fost efectuat backup-ul.
■	Directorul în care se fac backup-urile este primit ca variabilă de mediu cu valoare implicită backup.
■	Scriptul trebuie să printeze loguri relevante și suficiente pentru investigarea unei eventuale erori. 
■	Scriptul trebuie să trateze toate cazurile de excepție și să nu se termine cu eroare.
"""

#!/usr/bin/env python3


import os, sys, time, shutil, signal
from datetime import datetime
#!/usr/bin/env python3


import os, sys, time, shutil, signal
from datetime import datetime

# ========================= CONFIGURARE ==============================

BACKUP_INTERVAL = int(os.getenv("BACKUP_INTERVAL", "5"))    # Intervalul (în secunde) la care scriptul verifică dacă fișierul s-a modificat
SRC_FILE = os.getenv("SRC_FILE", "./system-state.log")      # Calea către fișierul sursă (cel generat de scriptul de monitorizare)
BACKUP_DIR = os.getenv("BACKUP_DIR", "./backup")            # Directorul unde se salvează copiile de backup
MAX_BACKUPS = int(os.getenv("MAX_BACKUPS", "10"))           # Câte backup-uri maxime se păstrează (cele mai vechi se șterg automat)

# Variabilă globală care permite oprirea elegantă
_running = True

# ========================== FUNCȚII AJUTATOARE =======================

# Funcție simplă de log — afișează mesaje cu timestamp
def log(level, msg):
    print(f"[{datetime.now():%Y-%m-%d %H:%M:%S}] {level} {msg}", flush=True)

# Handler pentru semnalele SIGTERM/SIGINT - permite oprirea grațioasă
def sig_handler(signum, _frame):
    global _running
    log("INFO", f"Primit semnal {signum}. Oprire grațioasă...")
    _running = False

# Funcție sigură pentru a obține data ultimei modificări și dimensiunea fișierului
def safe_stat(path):
    try:
        st = os.stat(path)
        return st.st_mtime, st.st_size  # (timp_modificare, dimensiune)
    except FileNotFoundError:
        return None, None
    except Exception as e:
        log("WARN", f"stat({path}): {e}")
        return None, None

# Funcție care șterge backup-urile vechi dacă depășim limita MAX_BACKUPS
def rotate_backups():
    try:
        files = [f for f in os.listdir(BACKUP_DIR)
                 if f.startswith("system-state-") and f.endswith(".log")]
        files.sort(key=lambda x: os.path.getmtime(os.path.join(BACKUP_DIR, x)))

        # Dacă sunt prea multe fișiere, ștergem cele mai vechi
        if len(files) > MAX_BACKUPS:
            for old in files[:len(files) - MAX_BACKUPS]:
                path = os.path.join(BACKUP_DIR, old)
                try:
                    os.remove(path)
                    log("INFO", f"Backup vechi șters: {path}")
                except Exception as e:
                    log("WARN", f"Nu pot șterge {path}: {e}")
    except Exception as e:
        log("WARN", f"Rotație backupuri: {e}")

# ========================== LOGICA PRINCIPALA =======================

def main():
    global _running

    # Legăm semnalele SIGTERM și SIGINT de funcția de oprire
    signal.signal(signal.SIGTERM, sig_handler)
    signal.signal(signal.SIGINT, sig_handler)

    # Creăm directorul de backup (dacă nu există)
    try:
        os.makedirs(BACKUP_DIR, exist_ok=True)
    except Exception as e:
        log("ERROR", f"Nu pot crea directorul de backup {BACKUP_DIR}: {e}")

    log("INFO", f"Pornit backup; src={SRC_FILE}, dir={BACKUP_DIR}, "
               f"interval={BACKUP_INTERVAL}s, max_backups={MAX_BACKUPS}")

    last_mtime, last_size = None, None  # Ultima stare cunoscută a fișierului

    # Bucla principală — rulează continuu până la oprire
    while _running:
        try:
            # Obținem timpul și dimensiunea curentă a fișierului sursă
            mtime, size = safe_stat(SRC_FILE)

            # Dacă fișierul nu există, doar logăm o avertizare
            if mtime is None:
                log("WARN", f"Fișierul sursă nu există încă: {SRC_FILE}")

            # Dacă fișierul s-a modificat față de ultima verificare
            elif last_mtime is None or mtime != last_mtime or size != last_size:
                # Creăm un nume de backup cu data și ora curentă
                ts = datetime.now().strftime("%Y%m%d-%H%M%S")
                dest = os.path.join(BACKUP_DIR, f"system-state-{ts}.log")

                # Copiem fișierul
                try:
                    shutil.copy2(SRC_FILE, dest)
                    log("INFO", f"Backup creat: {dest}")

                    # Actualizăm ultimele valori cunoscute
                    last_mtime, last_size = mtime, size

                    # Facem rotația (ștergem backup-urile vechi)
                    rotate_backups()
                except Exception as e:
                    log("ERROR", f"Eroare la crearea backup-ului: {e}")

            # Dacă fișierul nu s-a modificat, nu facem nimic
            else:
                log("INFO", "Nicio modificare detectată; nu fac backup.")
        except Exception as e:
            log("ERROR", f"Eroare neașteptată în bucla principală: {e}")

        # Pauză de BACKUP_INTERVAL secunde, dar verifică dacă trebuie să se oprească
        for _ in range(BACKUP_INTERVAL):
            if not _running:
                break
            time.sleep(1)

    log("INFO", "Script oprit grațios.")

# ========================== PUNCTUL DE INTRARE ======================

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        # Ultima plasă de siguranță — nu lăsăm scriptul să pice
        log("ERROR", f"Excepție neprevăzută: {e}")
        sys.exit(0)




# In alt terminal:
# BACKUP_INTERVAL=5
# SRC_FILE=./system-state.log
# BACKUP_DIR=./backup

# Rulare
# python3 backup.py