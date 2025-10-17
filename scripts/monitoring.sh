#! /bin/bash

# Creați 2 scripturi:
# ○	Un script shell care scrie la un anumit interval de timp într-un fișier system-state.log următoarele informații legate de sistem: 
# cpu, memorie, numărul de procese active și utilizare disk (disk usage),hostname si orice alta informatie considerati relevanta despre starea sistemului.
# ■	La fiecare rulare, scriptul suprascrie conținutul fișierului system-state.log.
# ■	Perioada la care se printează în fișierul system-state.log este primită ca variabilă de mediu cu valoarea implicită 5 secunde.
# ■	Informațiile adăugate în fișier trebuie să fie adăugate într-un mod cât mai ușor de urmărit de către utilizator.




# =====================================================================
# ----------------------------------------------------------------------
# Activăm modurile de execuție sigură pentru script
# ----------------------------------------------------------------------
set -euo pipefail
#  -e → oprește execuția dacă apare o eroare într-o comandă
#  -u → oprește execuția dacă o variabilă folosită nu este definită
#  -o pipefail → marchează eroare dacă oricare comandă dintr-un „pipe” eșuează

# ----------------------------------------------------------------------
# Variabile de configurare (cu valori implicite)
# ----------------------------------------------------------------------

# Intervalul în secunde între două actualizări (se poate schimba cu variabila de mediu INTERVAL)
INTERVAL="${INTERVAL:-5}"

# Calea fișierului de ieșire (se poate suprascrie cu variabila OUT_FILE)
OUT_FILE="${OUT_FILE:-./system-state.log}"

# Formatul datei pentru loguri (ex: 2025-10-17 15:22:45)
DATE_FMT="${DATE_FMT:-%Y-%m-%d %H:%M:%S}"

# ----------------------------------------------------------------------
# Asigurăm existența directorului pentru fișierul de ieșire
# ----------------------------------------------------------------------
mkdir -p "$(dirname "$OUT_FILE")"

# ----------------------------------------------------------------------
# Funcție simplă de log — afișează mesaje cu dată și oră
# ----------------------------------------------------------------------
log() {
  printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*"
}

# ----------------------------------------------------------------------
# Gestionăm oprirea grațioasă a scriptului (la Ctrl+C sau docker stop)
# ----------------------------------------------------------------------
trap 'log "Primit SIGTERM/SIGINT. Ies..."; exit 0' SIGTERM SIGINT

# ----------------------------------------------------------------------
# Bucla principală — rulează la infinit (până la întrerupere)
# ----------------------------------------------------------------------
while true; do
  {
    # ====== INFORMAȚII GENERALE DESPRE SISTEM ======
    echo "=== STAREA SISTEMULUI ==="
    echo "Timestamp: $(date +"$DATE_FMT")"
    echo "Hostname : $(hostname)"            # Numele sistemului
    echo "Kernel   : $(uname -sr)"           # Versiunea kernelului
    echo "Uptime   : $(uptime -p)"           # Timpul de funcționare al sistemului
    echo -n "LoadAvg  : "                    # Media de încărcare pe 1, 5, 15 minute
    awk '{print $1, $2, $3}' /proc/loadavg
    echo

    # ====== CPU ======
    echo "-----Utilizare CPU-----"
        top -bn1 | grep "Cpu(s)" | awk '{print "  User: " $2 "%, System: " $4 "%, Idle: " $8 "%"}'
    echo   

    # ====== MEMORIE ======
    echo "--------------------- MEMORIE ---------------------"
    free -h       # afișează utilizarea memoriei RAM și swap
    echo

    # ====== PROCESE ======
    echo "------- PROCESE ACTIVE --------"
    # Primele 10 procese sortate după CPU
    ps -eo pid,comm,pcpu,pmem --sort=-pcpu | head -n 10
    echo

    # Numărul total de procese active
    echo "Total procese: $(ps -e --no-headers | wc -l)"
    echo

    # ====== DISK USAGE ======
    echo "--- DISK USAGE ---"
    df -hT | awk 'NR==1 || /^\/dev\//'    # spațiu utilizat și disponibil pe fiecare partiție
    echo

    # ====== REȚEA ======
    echo "--- REȚEA (interfețe up) ---"
    ip -o -4 addr show | awk '{print $2": "$4}'   # afișează interfețele și adresele IP asociate
    echo

  } > "$OUT_FILE"   # Tot blocul de mai sus este redirectat în fișierul OUT_FILE (suprascris)

  # Mesaj în consolă pentru confirmare
  log "Starea sistemului a fost scrisă în $OUT_FILE (suprascris)."
  sleep "$INTERVAL" # Pauză de INTERVAL secunde înainte de următoarea colectare
done


# Rulare
# chmod +x monitoring.sh  
# ./monitoring.sh

# Verificare rapida
# Intr-un alt terminal:
# watch -n 1 'head -n 30 "/media/eu/More data/platforma-monitorizare/scripts/system-state.log"'
# „Afișează primele 30 de linii din fișierul system-state.log la fiecare 1 secundă, actualizând ecranul automat.”