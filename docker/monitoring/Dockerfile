# Dockerfile pentru imaginea scriptului de monitorizare bash.


# ================================
# Dockerfile pentru monitoring.sh
# ================================
FROM ubuntu:22.04

# Instalăm pachetele necesare pentru comenzi (top, free, ip, awk etc.)
RUN apt-get update && apt-get install -y \
    bash procps iproute2 sysstat \
    && rm -rf /var/lib/apt/lists/*

# Setăm directorul de lucru
WORKDIR /app

# Copiem scriptul din folderul părinte (scripts/)
# Atenție: ../scripts este vizibil doar dacă setăm contextul mai sus în docker-compose
COPY scripts/monitoring.sh ./monitoring.sh

# Dăm permisiuni de execuție
RUN chmod +x monitoring.sh

# Variabile de mediu implicite
ENV INTERVAL=5
ENV OUT_FILE=/data/system-state.log

# Montăm volumul /data partajat cu host-ul și cu containerul backup
VOLUME ["/data"]

# Comanda implicită la rulare
CMD ["./monitoring.sh"]
