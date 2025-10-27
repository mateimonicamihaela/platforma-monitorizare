# Platforma de Monitorizare a Starii unui Sistem

## Scopul Proiectului
- [Descriere detaliata a scopului proiectului. ]

### Arhitectura proiectului


Acest subpunct este BONUS.
- [Desenati in excalidraw sau in orice tool doriti arhitectura generala a proiectului si includeti aici poza cu descrierea pasilor]

- Acesta este un exemplu de inserare de imagine in README.MD. Puneti imagine in directorul de imagini si o inserati asa:

![Jenkins Logo](imagini/jenkins-logo.png)

Consultati si [Sintaxa Markdown](https://www.markdownguide.org/cheat-sheet/)

## Structura Proiectului
[Aici descriem rolul fiecarui director al proiectului. Descrierea trebuie sa fie foarte pe scurt la acest pas. O sa intrati in detalii la pasii urmatori.]
- `/scripts`: 
    - `monitoring.sh`: Un script shell care scrie intr-un fisier, la un interval de timp, informatii despre sistem (CPU, memorie, uptime, procese active, utilizare disk, retea).
    - `backup.py`: Un script Python care face backup la fișierul de log, dacă acesta s-a modificat.
.
- `/docker`: [Descriere Dockerfiles și docker-compose.yml. Aici descrieti legatura dintre fiecare Dockerfile si scripturile de mai sus (vedeti comentariul din fiecare Dockerfile)]
- `/ansible`: [Descriere rolurilor playbook-urilor și inventory]
- `/jenkins`: [Descrierea rolului acestui director si a subdirectoarelor. Unde sunt folosite fisierele din acest subdirector.]
- `/terraform`: [Descriere rol fiecare fisier Terraform folosit]

## Setup și Rulare
- [Instrucțiuni de setup local și remote. Aici trebuiesc puse absolut toate informatiile necesare pentru a putea instala si rula proiectul. De exemplu listati aici si ce tool-uri trebuiesc instalate (Ansible, SSH config, useri, masini virtuale noi daca este cazul, etc) pasii de instal si comenzi].
- [Cand includeti instructiuni folositi blocul de code markdown cu limbajul specific codului ]

```bash
# Rulare
chmod +x monitoring.sh  
./monitoring.sh

# Verificare rapida
# Intr-un alt terminal:
# watch -n 1 'head -n 30 "/media/eu/More data/platforma-monitorizare/scripts/system-state.log"'
# „Afișează primele 30 de linii din fișierul system-state.log la fiecare 1 secundă, actualizând ecranul automat.”
```

```python
python3 backup.py
```

## Setup și Rulare Docker

- [Descrieti cum ati pornit containerele si cum ati verificat ca aplicatia ruleaza corect.] 

Intram in folderul Docker:
- cd "/media/eu/More data/platforma-monitorizare/docker" 

Construim imaginile Docker:
- docker compose build 

Pornim serviciile in fundal:
- docker compose up -d  

Verificam daca ambele containere ruleaza:
- docker ps      

Vizualizam logurile aplicatiei:
- docker compose logs -f       

Oprim containerele:
- docker compose down                              


După câteva secunde de rulare, verificăm fisierele locale:
```bash
ls -lh ../data/
ls -lh ../data/backup/
```
🔗 Cum comunică între ele containerele

Containerele nu comunică prin rețea, ci prin volumul local montat:

| Container            | Scrie în                 | Citește din              | Director local            |
| -------------------- | ------------------------ | ------------------------ | ------------------------- |
| `monitoring-service` | `/data/system-state.log` | —                        | `./data/system-state.log` |
| `backup-service`     | `/data/backup/`          | `/data/system-state.log` | `./data/backup/`          |

Astfel, backup-service vede fișierul actualizat de monitoring-service și creează copii noi doar dacă fișierul s-a modificat.

🧰 Testare manuală

Putem verifica direct continutul din containere:

```bash
docker exec -it monitoring-service cat /data/system-state.log
docker exec -it backup-service ls /data/backup
```
☁️ (Opțional) Publicarea imaginilor în Docker Hub

După ce verificam că totul funcționează, rulam:
```bash
docker images
```

Avem doua imagini locale:
- docker-monitoring:latest → monitoring
- docker-backup:latest → backup

Le etichetam corect pentru Docker Hub și le dam push cu comenzile de mai jos:

(1) Autentificare o singură dată (dacă nu ești logat)
```bash
docker login
```

(2) Monitoring → tag + push
```bash
docker tag docker-monitoring:latest mateimonicamihaela/monitoring:latest
docker push mateimonicamihaela/monitoring:latest
```

(3) Backup → tag + push
```bash
docker tag docker-backup:latest mateimonicamihaela/backup:latest
docker push mateimonicamihaela/backup:latest
```








- [Includeti aici pasii detaliati de configurat si rulat Ansible pe masina noua]
- [Descrieti cum verificam ca totul a rulat cu succes? Cateva comenzi prin care verificam ca Ansible a instalat ce trebuia]

## Setup și Rulare in Kubernetes
- [Adaugati aici cateva detalii despre cum se poate rula in Kubernetes aplicatia]
- [Bonus: Adaugati si o diagrama cu containerele si setupul de Kubernetes] 

## CI/CD și Automatizari
- [Descriere pipeline-uri Jenkins. Puneti aici cat mai detaliat ce face fiecare pipeline de jenkins cu poze facute la pipeline in Blue Ocean. Detaliati cat puteti de mult procesul de CI/CD folosit.]
- [Detalii cu restul cerintelor de CI/CD (cum ati creat userul nou ce are access doar la resursele proiectului, cum ati creat un View now pentru proiect, etc)]
- [Daca ati implementat si punctul E optional atunci detaliati si setupul de minikube.]


## Terraform și AWS
- [Prerequiste]
- [Instrucțiuni pentru rularea Terraform și configurarea AWS]
- [Daca o sa folositi pentru testare localstack in loc de AWS real puneti aici toti pasii pentru install localstack.]
- [Adaugati instructiunile pentru ca verifica faptul ca Terraform a creat corect infrastructura]

## Depanare si investigarea erorilor
- [Descrieti cum putem accesa logurile aplicatiei si cum ne logam pe fiecare container pentru eventualele depanari de probleme]
- [Descrieti cum ati gandit logurile (formatul logurilor, levelul de log)]


## Resurse
- [Listati aici orice link catre o resursa externa il considerti relevant]
- Exemplu de URL:
- [Sintaxa Markdown](https://www.markdownguide.org/cheat-sheet/)
- [Schelet Proiect](https://github.com/amihai/platforma-monitorizare)
