# Tactical RMM

![GitHub Repo stars](https://img.shields.io/github/stars/amidaware/tacticalrmm?style=social)
![GitHub last commit](https://img.shields.io/github/last-commit/amidaware/tacticalrmm)
![License](https://img.shields.io/github/license/amidaware/tacticalrmm)

&gt; **Tactical RMM** est un outil de surveillance et de gestion à distance (Remote Monitoring & Management), construit avec **Django**, **Vue.js** et **Go**.

---

## 🎯 Description

Tactical RMM est une solution RMM open-source conçue pour les professionnels de l'informatique et les MSP (Managed Service Providers). Il permet de surveiller, gérer et prendre le contrôle à distance des postes de travail Windows, Linux et macOS via un agent léger écrit en Go.

L'outil s'intègre avec **MeshCentral** pour offrir des capacités de contrôle à distance avancées.

---

## 🚀 Fonctionnalités Principales

### Contrôle à Distance
- 🖥️ **Bureau à distance** (style TeamViewer)
- 💻 **Shell à distance** en temps réel
- 📁 **Explorateur de fichiers** (téléchargement et upload)
- 📝 **Éditeur de Registre Windows**

### Exécution & Scripts
- ⚡ **Exécution de commandes et scripts** à distance (Batch, PowerShell, Python, Nushell, Deno)
- 📋 **Journal des événements** (Event Log Viewer)
- 🔧 **Gestion des services**
- 🔄 **Gestion des correctifs Windows** (Patch Management)

### Automatisation & Alertes
- 📊 **Vérifications automatisées** avec alertes (CPU, disque, mémoire, services, scripts, logs)
- 📧 **Alertes** via Email / SMS / Webhook
- ⏰ **Planificateur de tâches** (exécution de scripts planifiée)

### Gestion Logicielle
- 📦 **Installation de logiciels** via Chocolatey
- 📋 **Inventaire matériel et logiciel**

---

## 💻 Compatibilité des Agents

### Windows
| Version | Support |
|---------|---------|
| Windows 7 | ✅ |
| Windows 8.1 | ✅ |
| Windows 10 | ✅ |
| Windows 11 | ✅ |
| Server 2008 R2 | ✅ |
| Server 2012 R2 | ✅ |
| Server 2016 | ✅ |
| Server 2019 | ✅ |
| Server 2022 | ✅ |
| Server 2025 | ✅ |

### Linux
Toute distribution utilisant **systemd**, incluant mais ne se limitant pas à :
- Debian (10, 11, 12)
- Ubuntu x86_64 (18.04, 20.04, 22.04, 24.04)
- Synology DSM 7
- CentOS / Rocky Linux / AlmaLinux
- FreePBX

### macOS
- Intel 64 bits
- Apple Silicon (M-Series)

---

## ⭐ Fonctionnalités Sponsor (Sponsorship)

Les fonctionnalités suivantes nécessitent un parrainage :

| Fonctionnalité | Description |
|----------------|-------------|
| **Agents Mac & Linux** | Support complet des agents non-Windows |
| **Agents Windows signés** | Agents Windows avec signature de code |
| **Module de reporting** | Rapports entièrement personnalisables |
| **Single Sign-On (SSO)** | Authentification unique |

---

## 🛠️ Architecture Technique

| Composant | Technologie |
|-----------|-------------|
| **Backend** | Django (Python) |
| **Frontend** | Vue.js |
| **Agent** | Go (Golang) |
| **Contrôle à distance** | Intégration MeshCentral |
| **Base de données** | PostgreSQL |

---

## 📦 Installation

Pour l'installation, la sauvegarde, la restauration et l'utilisation, veuillez consulter la documentation officielle :

📖 **[Documentation Officielle](https://docs.tacticalrmm.com)**

---

## 🎮 Démo en Direct

Une démo en ligne est disponible (la base de données se réinitialise toutes les heures) :

🔗 **[LIVE DEMO](https://demo.tacticalrmm.com)**

&gt; ⚠️ *Certaines fonctionnalités sont désactivées pour des raisons de sécurité évidentes.*

---

## 💬 Communauté

- **Discord** : Rejoignez la communauté sur Discord pour du support et des discussions
- **GitHub Issues** : Signalez des bugs ou proposez des fonctionnalités

---

## 📄 Licence

Ce projet est distribué sous une licence open-source. Veuillez consulter le fichier `LICENSE` du dépôt pour plus de détails.

---

## 🔗 Liens Utiles

| Ressource | Lien |
|-----------|------|
| **GitHub** | https://github.com/amidaware/tacticalrmm |
| **Documentation** | https://docs.tacticalrmm.com |
| **Démo** | https://demo.tacticalrmm.com |
| **Discord** | Disponible sur le dépôt GitHub |

---

*Dernière mise à jour : Juin 2026*