# Dockerfile pentru imaginea scriptului de backup Python.

# ============================
# Dockerfile pentru backup.py
# ============================

FROM python:3.10-slim

# Director de lucru
WORKDIR /app

# Copiem scriptul din folderul scripts
COPY scripts/backup.py ./backup.py

# Variabile de mediu implicite
ENV BACKUP_INTERVAL=5
ENV SRC_FILE=/data/system-state.log
ENV BACKUP_DIR=/data/backup
ENV MAX_BACKUPS=10

# Volum partajat
VOLUME ["/data"]

# Comanda implicită de execuție
CMD ["python3", "backup.py"]
