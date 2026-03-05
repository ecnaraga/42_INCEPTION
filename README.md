# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to set up a small infrastructure composed of different services using **Docker** and **Docker Compose**, running inside a virtual machine.

The project requires building custom Docker images (no pre-built images from Docker Hub, except base OS images) and orchestrating three services:

- **NGINX** — acts as the sole entry point, handling HTTPS (TLS) traffic on port 443 and proxying requests to WordPress.
- **WordPress** — runs with PHP-FPM (no apache), serving the website and communicating with MariaDB via port 9000.
- **MariaDB** — the relational database storing all WordPress content, accessible only internally on port 3306.

All containers are connected through a dedicated Docker network (`Inception`) and use persistent volumes to store data (database files and WordPress files).

### Design Choices

**Docker over Virtual Machines**

| | Virtual Machines | Docker |
|---|---|---|
| Isolation | Full OS isolation | Process-level isolation |
| Resource usage | Heavy (full OS per VM) | Lightweight (shared kernel) |
| Startup time | Minutes | Seconds |
| Portability | Moderate | Very high |
| Use case | Full OS emulation | Application containerization |

Docker containers share the host kernel and are much more lightweight than VMs. However, VMs offer stronger isolation. In this project, Docker is used to isolate services from each other while remaining efficient.

**Secrets vs Environment Variables**

| | Environment Variables (`.env`) | Docker Secrets |
|---|---|---|
| Storage | Plain text file | Mounted in-memory (`/run/secrets/`) |
| Visibility | Exposed via `docker inspect` | Not exposed in inspect |
| Complexity | Simple | Requires additional configuration |
| Best for | Development / 42 projects | Production environments |

This project uses a `.env` file for simplicity. The file is listed in `.gitignore` to prevent sensitive data from being committed. Docker Secrets (commented out in `docker-compose.yml`) would be the preferred approach in a production context as they are never exposed via `docker inspect`.

**Docker Network vs Host Network**

| | Docker Network | Host Network |
|---|---|---|
| Isolation | Services isolated in a private network | Services share the host's network stack |
| Port exposure | Only explicitly exposed ports are accessible | All ports accessible from the host |
| DNS resolution | Containers resolve each other by name | No built-in container DNS |
| Security | Better (by default) | Less secure |

This project uses a custom bridge network named `Inception`. Only NGINX exposes a port to the outside (443). WordPress and MariaDB communicate internally within the Docker network, never directly exposed to the host.

**Docker Volumes vs Bind Mounts**

| | Docker Volumes | Bind Mounts |
|---|---|---|
| Managed by | Docker daemon | Host filesystem directly |
| Portability | High | Low (depends on host path) |
| Use case | Production data | Development / direct file access |
| Visibility | Via `docker volume` commands | Direct path on host |

This project uses **bind mounts** (configured as local driver with `type: none` and `o: bind`), which means data is stored directly at a defined path on the host machine (`/home/galambey/data/`). This makes data easy to inspect and persist across container restarts while satisfying the project's requirements.

---

## Instructions

### Prerequisites

- Vagrant installed on your system, if not please run :
```sh
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```
- VirtualBox as the provider for Vagrant.

- Launch the Virtual machine :
```sh
cd VM # The VM directory is at the root of the github repository
echo "USERNAME=<Your_VM_username>
PASSWD=<Your_VM_username_password_first_connection>
GITHUB_TOKEN=<Your_github_access_token>
GITHUB_MAIL=<Your_github_mail_adresse>
GITHUB_NAME=<Your_github_username>
PROJECT_REPOSITORY=42_INCEPTION
NGINX_HOST=galambey.42.fr
WP_DB_HOST=mariadb
WP_DB_NAME=wordpress
WP_SITEPATH=/var/www/html/galambey.42.fr
WP_SITEURL=https://galambey.42.fr
WP_HOME=galambey.42.fr
WP_ADMIN_USER=<Your_admin_name>
WP_ADMIN_PASSWORD=<Your_admin_password>
WP_ADMIN_MAIL=<Your_admin_mail>
MARIADB_USER=wordpress
MARIADB_PASSWORD=wordpress
MARIADB_ROOT_PASSWORD=<Your_maria_db_root_password>
MARIADB_DATABASE=wordpress" > .vagrant-secret 
vagrant up
```
- **GITHUB_TOKEN** : Token GitHub classique avec les scopes `repo`, `write:public_key` et `read:public_key` dans `admin:public_key`, et `read:org` dans `admin:org`.

> PS : The password will be change at the first connection to the Virtual machine

> PS : You can launch the project outside of a virtual machine, if so, please make sure that all the tools (installed by /VM/vm_init.sh) are available and don't forget to modify the hosts file and to create the .env

### Connect to ssh with your user
```sh
ssh -p 2222 <Your_VM_username>@127.0.0.1
```
> PS: At first connection you'll have to change your VM_password, then run the command again

### Connect to ssh with your user and X11(graphic display protocol)
```sh
ssh -p 2222 -X <Your_VM_username>@127.0.0.1
```
- Run the following command to open VM's firefox on your host:
```bash
firefox &
```

### Build and Run

```bash
cd 42_INCEPTION
make
```

### Stop and Clean

```bash
# Stop containers
make stop

# Stop & destroy containers & networks
make down

# Remove all containers, volumes & images (depends on down)
make clean

# Stop, destroy containers & networks and wipe volumes
make downvolume

# Full system wipe (depends on downvolume)
make fclean

```

### List

```bash
# Show running containers
make ps

# Show all containers
make psa

# Show containers' logs
make logs
```

### Access

Open your browser and navigate to `https://galambey.42.fr`

```bash
ssh -p 2222 -X <Your_VM_username>@127.0.0.1
firefox &
```

---
