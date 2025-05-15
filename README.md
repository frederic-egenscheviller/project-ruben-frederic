# Guide d'utilisation : Docker Compose, Kubernetes et Ansible

Membres du groupe :
- Ruben SAILLY
- Frédéric EGENSCHEVILLER

## Docker Compose

Ce projet inclut un fichier `docker-compose.yml` qui permet de build les images et lancer les services.

### Commandes nécessaires au lancement du projet

```bash
docker compose up  # Démarre les services et build si images non présentes
docker compose down   # Arrête et supprime les conteneurs
```

### Description de ce qui a été mis en place

- Service vote avec healthcheck (accessible sur http://localhost:8000) loadbalancé par un service nginx
- Service résultat (accessible sur http://localhost:4000)
- Service seed (votes générés au lancement)
- Service worker --> traitement des votes
- Service redis avec healthcheck pour le cache
- Service base de données PGSQL avec healthcheck
- Service Nginx faisant office de loadbalancer (répartisseur de charge) pour les services votes

Réduction de la taille des images au maximum en utilisant du multi-stage (première image pour build et la finale où on récupère uniquement le code et on l'exécute avec le runtime plus léger, ex: worker).

Scripts healthchecks partagés aux conteneurs par un volumes.

## Kubernetes

Version du projet utilisant Kubernetes pour être déployée.

La mandatory version a été réalisée ainsi que les bonus.

### Déploiement version initiale

Afin d'avoir toutes les images docker des services générées, lancer aupréalable la version déployée avec docker qui se chargera de build les images.

Se placer dans le dossier kubernetes avec la commande :

```bash
cd kubernetes
```

Exécuter le script `.sh` nommé `build-load-images.sh`

```bash
sh build-load-images.sh
```

Ce script va permettre de charger les images générées vers minikube afin qu'il puisse les utiliser à son tour. De plus, une petite modification du service seed-data nécessite qu'une nouvelle image soit créée spécifiquement pour kubernetes car nous devons passer par un service qui possède un nom différent du loadbalancer nginx utilisé précédemment.

Les images sont maintenant chargées dans minikube, on peut alors lancer le projet en se plaçant à la racine du dépôt et en entrant la commande :

```bash
kubectl apply -k kubernetes/overlays/dev
```

Elle aura pour rôle de lancer l'ensemble des services, déploiements, job avec la configuration dev.

- Service vote accessible sur http://localhost:5001
- Service résultat accessible sur http://localhost:4001

Mise en place du Kustomize pour gestion d'environnement de production et développement (changement des ports).

La version 'prod' est déployable avec la commande :

```bash
kubectl apply -k kubernetes/overlays/prod
```

La configuration des services sera alors modifiée.

Pour stopper les déploiements on tape la commande :

```bash
kubectl delete -k kubernetes/overlays/dev
```

L'ensemble des healthchecks ont été mis en place (vote, redis, postgres).

De plus, le HorizontalPodAutoscaler a été configuré pour le service vote.

⚠️ Penser à installer le metric server pour qu'il puisse fonctionner.

### Déploiement version base de données gérée par Ansible

Les images docker utilisées sont les mêmes, nous n'avons donc pas besoin d'en générer d'autres. De même, celles transférées sur minikube sont celles dont on a besoin pour effectuer le déploiement.

La base de données est alors distante, sur le serveur fourni lors du tp ansible.

On lance le projet avec la commande :

```bash
kubectl apply -f kubernetes-ansible
```

## Ansible

Le dossier `ansible` contient l'ensemble des playbooks créés.

Le dossier inventories contient les informations de connexion aux 2 VMs. Le dossier playbooks contient les playbooks demandés et ceux optionnels.

Le dossier `group_vars` contient les variables utilisées dans les différents rôles.

Le dossier `roles` contient les rôles qui sont appelés par les différents playbooks.

### Déploiement base de donnée PGSQL

Le playbook se nomme `deploy_postgres.yaml`. Il installe postgres sur les deux VMs, en commançant par ajouter le repo apt qui n'est pas présent initialement pour la version 15.

Mise en place du paramétrage système.
Prise en compte du cas où le serveur a moins de 1 GB de RAM.

Il exécute un seul rôle : `pg_install`.

Il possède un handler qui permet de ne rémarrer le service que si une modification est effectuée sur celui-ci (skipping sinon).

Commande pour le lancer :

```bash
ansible-playbook -i inventories/development.yaml playbooks/deploy_postgres.yaml
```

Commande pour visualiser les facts :

```bash
ansible -m setup <vm1/vm2>
```

### Backup db streamé depuis le serveur

Le playbook se nomme `pg_backup.yaml`. Il vient faire un dump de la base de la vm1 et le télécharger sur le contrôlleur ansible (pc dans ce cas) de manière streamé.

Il exécute un seul rôle : `pg_backup_controller`.

Commande pour le lancer :

```bash
ansible-playbook -i inventories/development.yaml playbooks/pg_backup.yaml
```

### Cold replica A

Le playbook se nomme `cold-replica-A.yaml`. Il vient faire un dump de la base de la vm1 et le télécharger sur le contrôlleur ansible (pc dans ce cas) de manière streamé.

La base de données de la vm2 est effacée puis on envoie le fichier sur la vm.

La base de données est restaurée à partir du fichier puis il est supprimé.

Le playbook exécute deux rôles : `pg_backup_controller` et `pg_restore_secondary`.

Commande pour le lancer :

```bash
ansible-playbook -i inventories/development.yaml playbooks/cold-replica-A.yaml
```

### Cold replica B

Le playbook se nomme `cold-replica-B.yaml`. Il vient faire un dump de la base de la vm1 et l'envoyer directement dans la base de la vm2

La base de données de la vm2 est effacée puis on insère les données depuis la vm1 par la connexion avec l'utilisateur postgres.

Le playbook exécute un rôle : `pg_direct_replication`.

Commande pour le lancer :

```bash
ansible-playbook -i inventories/development.yaml playbooks/cold-replica-B.yaml
```
