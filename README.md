# Platforma de Monitorizare a Starii unui Sistem

## Scopul Proiectului
- [Descriere detaliata a scopului proiectului. ]

Acest proiect reprezintă o platformă completă de monitorizare și automatizare DevOps, dezvoltată pentru a demonstra un flux de integrare continuă (CI/CD) și administrare a infrastructurii containerizate.

Aplicația urmărește starea sistemului (sau a unui container), colectând periodic informații despre:
- utilizarea procesorului (CPU),
- memoria disponibilă,
- numărul de procese active,
- spațiul de stocare (disk usage),
- uptime, hostname, și alți parametri relevanți.

Datele sunt salvate într-un fișier jurnal (system-state.log), care este actualizat la fiecare interval configurabil de timp.
Un al doilea serviciu, de backup automat, monitorizează modificările fișierului de log și creează copii de siguranță etichetate temporal, asigurând persistența și trasabilitatea datelor în timp.

### Arhitectura proiectului

⚙️ Arhitectura și componentele principale

1. Cele 2 scripturi

📜 Scriptul de monitorizare (monitoring.sh)
- Rulează periodic și scrie în fișierul system-state.log informații despre starea sistemului.
- Intervalul este configurabil prin variabila de mediu INTERVAL (implicit 5 secunde).
- Poate fi executat atât local, cât și în container Docker.

💾 Scriptul de backup (backup.py)
- Monitorizează fișierul system-state.log și efectuează backup automat dacă detectează modificări.
- Copiile sunt salvate în directorul /data/backup/ și denumite după data și ora curentă.
- Include un mecanism de rotație automată (șterge backup-urile vechi, păstrând ultimele N fișiere).

2. 🐳 Docker
- Fiecare serviciu rulează în propriul container (monitorizare și backup).
- Volumele partajate (/data) permit comunicarea și partajarea logurilor între containere.
- Configurația este gestionată central prin fișierul docker-compose.yml.

3. ☸️ Kubernetes
- Aplicația este orchestrată într-un cluster Kubernetes.
- Un deployment rulează ambele containere în același pod, alături de un container NGINX care expune fișierele de loguri.
- Include un HPA (Horizontal Pod Autoscaler) care scalează automat aplicația între 2 și 10 replici pe baza utilizării CPU și memoriei.
- Rulează într-un namespace dedicat: monitoring.

4. 🧩 Ansible
- Automatizează instalarea și configurarea mediului de rulare (inclusiv Docker și Docker Compose).
- Gestionează deploy-ul aplicației pe mașini remote (VM-uri dedicate).
- Include playbook-uri distincte pentru:
  - instalarea Docker (install_docker.yml),
  - rularea aplicației (deploy_platform.yml).

5. 🏗️ Jenkins (CI/CD)
- Integrează pipeline-uri pentru:
  - build-ul imaginilor Docker;
  - push-ul către Docker Hub;
  - deploy automat în Kubernetes;
  - testarea aplicației și verificarea backup-urilor.

- Fiecare serviciu (monitoring și backup) are propriul pipeline în jenkins/pipelines/.

6. 🌍 Terraform
- Definește infrastructura de bază pentru rularea aplicației:
  - crearea VM-urilor,
  - configurarea rețelei și volumelor persistente,
  - setarea backend-ului de stocare pentru starea Terraform.

- Permite aprovizionarea rapidă a mediilor de test, staging și producție.


📊 Beneficii și rezultate
- 🔁 Monitorizare continuă și centralizată a resurselor.
- 💾 Backup automat, sigur și trasabil al datelor.
- 🧱 Containere ușor portabile, integrate în pipeline-uri DevOps.
- ☸️ Scalabilitate automată prin Kubernetes HPA.
- ⚙️ Automatizare completă a instalării și deploy-ului prin Ansible.
- 🚀 CI/CD configurat end-to-end cu Jenkins.
- ☁️ Infrastructură definită ca cod (IaC) prin Terraform.

```bash
├── ansible
│   ├── inventory.ini
│   └── playbooks
│       ├── deploy_platform.yml
│       └── install_docker.yml
├── data
│   ├── backup
│   │   └── system-state-20251027-124842.log
│   └── system-state.log
├── docker
│   ├── backup
│   │   └── Dockerfile
│   ├── docker-compose.yml
│   └── monitoring
│       └── Dockerfile
├── imagini
│   └── jenkins-logo.png
├── jenkins
│   └── pipelines
│       ├── backup
│       │   └── Jenkinsfile
│       └── monitoring
│           └── Jenkinsfile
├── k8s
│   ├── deployment.yaml
│   └── hpa.yaml
├── README.md
├── scripts
│   ├── backup.py
│   └── monitoring.sh
└── terraform
    ├── backend.tf
    └── main.tf
```

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

🖥️ scripts/monitoring.sh

- Suprascrie fișierul `system-state.log` 
- Perioada la care se printeaza in fisierul `system-state.log` este prin `export INTERVAL=5`

💾 scripts/backup.py

- Creează backup doar dacă fișierul s-a modificat
- Numele backup-ului include data și ora
- Directorul de backup este configurabil cu `export BACKUP_DIR=backup`
- Logurile sunt clare și informative
- Tratează toate excepțiile fără a se opri

⚙️ Variabile de mediu utilizate în proiect

| Variabilă           | Utilizată de  | Descriere                                                              | Valoare implicită                                                         | Exemplu suprascriere                                         |
| ------------------- | ------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------ |
| **INTERVAL**        | monitoring.sh | Intervalul în secunde la care se colectează informațiile despre sistem | `5`                                                                       | `INTERVAL=2 ./scripts/monitoring.sh`                         |
| **OUT_FILE**        | monitoring.sh | Calea către fișierul în care se scrie starea sistemului                | `./system-state.log` *(local)*<br>`/data/system-state.log` *(Docker/K8s)* | `OUT_FILE=./data/system-state.log ./scripts/monitoring.sh`   |
| **BACKUP_INTERVAL** | backup.py     | Intervalul în secunde la care se verifică modificarea logului          | `5`                                                                       | `BACKUP_INTERVAL=5 python3 scripts/backup.py`                |
| **SRC_FILE**        | backup.py     | Calea fișierului `system-state.log` monitorizat pentru schimbări       | `./system-state.log` *(local)*<br>`/data/system-state.log` *(Docker/K8s)* | `SRC_FILE=./data/system-state.log python3 scripts/backup.py` |
| **BACKUP_DIR**      | backup.py     | Directorul în care sunt salvate copiile logului                        | `./backup` *(local)*<br>`/data/backup` *(Docker/K8s)*                     | `BACKUP_DIR=./data/backup python3 scripts/backup.py`         |
| **MAX_BACKUPS**     | backup.py     | Numărul maxim de backup-uri păstrate                                   | `10`                                                                      | `MAX_BACKUPS=5 python3 scripts/backup.py`                    |


Recomandare de rulare:

```bash
# Rulare monitorizare
cd ~/work/platforma-monitorizare/scripts/
chmod +x monitoring.sh
cd ~/work/platforma-monitorizare
export INTERVAL=5
export OUT_FILE=./data/system-state.log 
./scripts/monitoring.sh

# Rulare backup
cd ~/work/platforma-monitorizare
export BACKUP_INTERVAL=5
export SRC_FILE=./data/system-state.log 
export BACKUP_DIR=./data/backup
python3 scripts/backup.py
```


## Setup și Rulare Docker
In această secțiune este documentat modul de împachetare și rulare a celor două scripturi (monitorizare și backup) în imagini Docker separate.
Aplicația poate rula atât individual, cât și împreună, folosind servicii Docker conectate printr-un volum comun.

3 secțiuni pentru Docker:

1️⃣ Build manual al imaginilor Docker

2️⃣ Rulare individuală cu docker run

3️⃣ Rulare orchestrată cu docker compose


🐳 Rulare cu Docker (fără Docker Compose)

✅ 1) Construirea imaginilor Docker

```bash
cd ~/work/platforma-monitorizare/docker

docker build -t mateimonicamihaela/monitoring:latest \
  --file monitoring/Dockerfile ../

docker build -t mateimonicamihaela/backup:latest \
  --file backup/Dockerfile ../
```

✅ 2) Rularea containerelor individual

▶️ Container monitoring

Scrie system-state.log în volumul mapat local:

```bash
docker run -d \
  --name monitoring-container \
  -e INTERVAL=5 \
  -e OUT_FILE=/data/system-state.log \
  -v "$(pwd)"/../data:/data \
  mateimonicamihaela/monitoring:latest
```
▶️ Containerul de backup

Face backup periodic doar dacă logul s-a modificat:

```bash
docker run -d \
  --name backup-container \
  -e BACKUP_INTERVAL=5 \
  -e SRC_FILE=/data/system-state.log \
  -e BACKUP_DIR=/data/backup \
  -v "$(pwd)"/../data:/data \
  mateimonicamihaela/backup:latest
```

Afișare log execuție:
```bash
docker logs -f monitoring-container
docker logs -f backup-container
```

După câteva secunde de rulare, verificăm fisierele locale:
```bash
ls -lh ../data/
ls -lh ../data/backup/
```
🛑 Oprire și ștergere containere

```bash
docker stop monitoring-container backup-container
docker rm monitoring-container backup-container
```

✅ 3) Rulare orchestrată cu Docker Compose

Pentru rularea completă a aplicației se folosește un volum partajat și setări de rețea automate via Docker Compose.

Intram in folderul Docker:
```bash
cd ~/work/platforma-monitorizare/docker
```

Construim imaginile Docker:
```bash
docker compose build
```

Pornim serviciile in fundal:
```bash
docker compose up -d  
```

Verificam daca ambele containere ruleaza:
```bash
docker ps      
```

Vizualizam logurile aplicatiei:
```bash
docker compose logs -f       
```

Oprim containerele:
```bash
docker compose down                              
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


## Setup și Rulare in Kubernetes
- [Bonus: Adaugati si o diagrama cu containerele si setupul de Kubernetes] 

(1) Precondiții (Porneste Minikube + Activează metrics-server (pentru HPA))
```bash
cd ~/work/platforma-monitorizare
minikube start
minikube addons enable metrics-server
kubectl get pods -A | grep metrics
```

Dacă NU ai imaginile în Docker Hub:
```bash
# după ce ai făcut build local
minikube image load mateimonicamihaela/monitoring:latest
minikube image load mateimonicamihaela/backup:latest
```

(2) Namespace: aplicatia trebuie sa ruleze intr-un namespace cu numele monitoring

k8s/namespace.yaml
```bash
kubectl apply -f k8s/namespace.yaml
```

(3) ConfigMap Nginx (pentru listare /logs și redirect)
```bash
kubectl -n monitoring apply -f k8s/nginx-config.yaml
```

(4) Creati un deployment cu 2 replici ce ruleaza in acelasi pod ambele containere,plus un container nginx ce expunee fisierul de loguri de sistem --> 3 containere/pod + Service

```bash
kubectl -n monitoring apply -f k8s/deployment.yaml
```
(5) Adaugati un HPA pe baza de CPU și memorie configurat cu min replicas 2 si max replicas 10)
```bash
kubectl -n monitoring apply -f k8s/hpa.yaml
```

(6) Verificare rapidă & acces

```bash
kubectl -n monitoring get pods
kubectl -n monitoring get deploy,svc,hpa
kubectl -n monitoring describe hpa platforma-monitorizare-hpa
kubectl top pods -n monitoring   # necesită metrics-server
```

(7) Acces la aplicație (Nginx care servește logurile)

Varianta 1 - Deschide în browser (URL generat de Minikube):
```bash
minikube service -n monitoring platforma-monitorizare --url

# Accesează:
#   <URL>/logs/system-state.log 
#   <URL>/logs/backup/   (listă de fișiere; autoindex activ din ConfigMap) 
```
Varianta 2 - Port-forward (convenabil pentru demo)
```bash
kubectl -n monitoring port-forward svc/platforma-monitorizare 8080:80

# apoi în alt terminal:
curl http://localhost:8080/logs/system-state.log

# sau in browser:
http://localhost:8080/logs/system-state.log
```


(8) Vezi logurile din containere

Monitorizare:
```bash
kubectl -n monitoring logs deploy/platforma-monitorizare -c monitoring --tail=30 -f
```

Backup:
```bash
kubectl -n monitoring logs deploy/platforma-monitorizare -c backup --tail=30 -f
```

🔗 Exemple de URL complet pentru accesarea aplicației:

Logul curent al sistemului:

http://192.168.49.2:32055/logs/system-state.log

Backup-urile efectuate

http://192.168.49.2:32055/logs/backup/


🧠 Cum se verifică in terminal:

curl http://192.168.49.2:32055/logs/system-state.log

curl http://192.168.49.2:32055/logs/backup/


🧩 Structura actuală a Pod-ului (din k8s/deployment.yaml)

În Pod avem 3 containere care rulează împreună și partajează un volum /data comun:

| Container        | Rol                                                                                         | Porturi expuse         | Persistență                         |
| ---------------- | ------------------------------------------------------------------------------------------- | ---------------------- | ----------------------------------- |
| 🖥️ `monitoring` | rulează `monitoring.sh` – colectează starea sistemului și scrie în `/data/system-state.log` | ❌ nu expune porturi    | ✅ scrie în `/data/system-state.log` |
| 🧱 `backup`      | rulează `backup.py` – monitorizează fișierul de log și face copii în `/data/backup/`        | ❌ nu expune porturi    | ✅ salvează în `/data/backup/`       |
| 🌐 `nginx`       | servește prin HTTP conținutul din `/data/` (loguri + backup-uri)                            | ✅ expune portul **80** | ✅ montează `/data` read-only        |

Alternativă completă — „hard reset” (dacă vrem să curețam tot proiectul)
```bash
docker compose down --remove-orphans
docker container prune -f
docker image prune -f
docker volume prune -f
docker network prune -f
docker compose up -d
```


## Setup și Rulare in Ansible
- [Includeti aici pasii detaliati de configurat si rulat Ansible pe masina noua]
- [Descrieti cum verificam ca totul a rulat cu succes? Cateva comenzi prin care verificam ca Ansible a instalat ce trebuia]

(1) Bootstrap VM nou + user nou (o singură dată)

 Pe masina remote (masina noua) adaugam un user nou si ii setam cheia de ssh 

Creează userul nou (ex: monitor) 
```bash
sudo adduser monitor
```

Adaugam userul monitor in userii cu drept de sudo
```bash
sudo usermod -aG sudo monitor
groups monitor
```

Adaugam userul monitor in lista de useri ce nu au nevoie de parola la sudo
```bash
cd /etc/sudoers.d/
echo "monitor ALL=(ALL) NOPASSWD:ALL" | sudo tee monitor-nopasswd
```

(monitor este userul pe care il foloseste Ansible sa faca ssh pe masina server)
```bash
su - monitor
```

Verificam ca putem face sudo fara parola
```bash
sudo ls
```

Adaugam cheia de ssh a userului monitor in masina remote. Atentie: trebuie sa fiti logati cu userul monitor cand rulati aceste comenzi
```bash
mkdir .ssh
touch ~/.ssh/authorized_keys
echo “cheie ssh publica de pe masina client” >> ~/.ssh/authorized_keys
cat ~/.ssh/authorized_keys
```

Instalam ssh server pe masina remote
```bash
sudo apt update
sudo apt install -y openssh-server
service ssh status
```

Luam IP-ul masinii remote (IP-ul care nu se termina in .1)
```bash
ip addr | grep 192.168
```

Ne afiseaza: 
```bash
monitor@baseline:~$ ip addr | grep 192.168
    inet 192.168.100.238/24 brd 192.168.100.255 scope global dynamic noprefixroute enp0s8
    inet 192.168.49.1/24 brd 192.168.49.255 scope global br-4ef4fc0cb34f
```

Revenim pe masina client (ubuntu2204) si incercam sa facem ssh cu userul monitor
```bash
ssh monitor@192.168.100.238
```

(2) Ansible pe mașina locala + inventory

Instalam pip pentru Python3
```bash
sudo apt update
sudo apt install -y python3-pip
pip3 --version
```

Instalam Ansible pe masina client (ubuntu2204).
```bash
sudo apt update
sudo apt install -y ansible 
ansible --version
```

Pe masina client (ubuntu2204) citim cheia publica a userului curent
```bash
cat ~/.ssh/id_rsa.pub
```

Revenim pe masina client (ubuntu2204) si incercam sa facem ssh cu userul monitor
```bash
ssh monitor@192.168.100.238
```
Asigură-te că există Python 3 pe VM (Ansible are nevoie)
```bash
sudo apt-get update
sudo apt-get install -y python3
```
Intoarce-te la userul eu
```bash
exit
```

ansible/ansible.cfg

ansible/inventory.ini (actualizează IP-ul!)

ansible/requirements.yml

Instalează colecția pe mașina de control:

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
```

Test ping simplu
```bash
ansible monitoring_vm -m ping
```


(3) Playbook 1 — Instalează Docker (Docker CE + compose plugin)

ansible/playbooks/install_docker.yml

Rulează:
```bash
cd ansible
ansible-playbook playbooks/install_docker.yml
```


(4) Playbook 2 — Deploy cu docker compose + verificări log & backup

Acest playbook:

- clonează repo-ul meu pe VM în /opt/platforma-monitorizare

- rulează docker compose up -d din docker/

- așteaptă să apară system-state.log

- verifică faptul că s-a creat cel puțin un fișier în data/backup/


ansible/playbooks/deploy_platform.yml

```bash
ansible-playbook playbooks/deploy_platform.yml
```

Verificări manuale: 

Pe masina remote cu userul nou

```bash
ssh monitor@192.168.100.238
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
sudo ls -lh /opt/platforma-monitorizare/data
sudo ls -lh /opt/platforma-monitorizare/data/backup
sudo tail -n 20 /opt/platforma-monitorizare/data/system-state.log
```
Pe masina locala

```bash
ansible monitoring_vm -m command -a "docker ps"
```



## Jenkins CI/CD și Automatizari
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
