------------------------------------------------------------------------------------------------------
ATELIER API-DRIVEN INFRASTRUCTURE
------------------------------------------------------------------------------------------------------
L’idée en 30 secondes : **Orchestration de services AWS via API Gateway et Lambda dans un environnement émulé**.  
Cet atelier propose de concevoir une architecture **API-driven** dans laquelle une requête HTTP déclenche, via **API Gateway** et une **fonction Lambda**, des actions d’infrastructure sur des **instances EC2**, le tout dans un **environnement AWS simulé avec LocalStack** et exécuté dans **GitHub Codespaces**. L’objectif est de comprendre comment des services cloud serverless peuvent piloter dynamiquement des ressources d’infrastructure, indépendamment de toute console graphique.Cet atelier propose de concevoir une architecture API-driven dans laquelle une requête HTTP déclenche, via API Gateway et une fonction Lambda, des actions d’infrastructure sur des instances EC2, le tout dans un environnement AWS simulé avec LocalStack et exécuté dans GitHub Codespaces. L’objectif est de comprendre comment des services cloud serverless peuvent piloter dynamiquement des ressources d’infrastructure, indépendamment de toute console graphique.
  
-------------------------------------------------------------------------------------------------------
Séquence 1 : Codespace de Github
-------------------------------------------------------------------------------------------------------
Objectif : Création d'un Codespace Github  
Difficulté : Très facile (~5 minutes)
-------------------------------------------------------------------------------------------------------
RDV sur Codespace de Github : <a href="https://github.com/features/codespaces" target="_blank">Codespace</a> **(click droit ouvrir dans un nouvel onglet)** puis créer un nouveau Codespace qui sera connecté à votre Repository API-Driven.
  
---------------------------------------------------
Séquence 2 : Création de l'environnement AWS (LocalStack)
---------------------------------------------------
Objectif : Créer l'environnement AWS simulé avec LocalStack  
Difficulté : Simple (~5 minutes)
---------------------------------------------------

Dans le terminal du Codespace copier/coller les codes ci-dessous etape par étape :  

**Installation de l'émulateur LocalStack**  
```
sudo -i mkdir rep_localstack
```
```
sudo -i python3 -m venv ./rep_localstack
```
```
sudo -i pip install --upgrade pip && python3 -m pip install localstack && export S3_SKIP_SIGNATURE_VALIDATION=0
```
Rendez-vous chez Localstack pour vous créez un Token : https://app.localstack.cloud/
```
localstack auth set-token <YOUR_AUTH_TOKEN>
localstack start -d
```
**vérification des services disponibles**  
```
localstack status services
```
**Réccupération de l'API AWS Localstack** 
Votre environnement AWS (LocalStack) est prêt. Pour obtenir votre AWS_ENDPOINT cliquez sur l'onglet **[PORTS]** dans votre Codespace et rendez public votre port **4566** (Visibilité du port).
Réccupérer l'URL de ce port dans votre navigateur qui sera votre ENDPOINT AWS (c'est à dire votre environnement AWS).
Conservez bien cette URL car vous en aurez besoin par la suite.  

Pour information : IL n'y a rien dans votre navigateur et c'est normal car il s'agit d'une API AWS (Pas un développement Web type UX).

---------------------------------------------------
Séquence 3 : Exercice
---------------------------------------------------
Objectif : Piloter une instance EC2 via API Gateway
Difficulté : Moyen/Difficile (~2h)
---------------------------------------------------  
Votre mission (si vous l'acceptez) : Concevoir une architecture **API-driven** dans laquelle une requête HTTP déclenche, via **API Gateway** et une **fonction Lambda**, lancera ou stopera une **instance EC2** déposée dans **environnement AWS simulé avec LocalStack** et qui sera exécuté dans **GitHub Codespaces**. [Option] Remplacez l'instance EC2 par l'arrêt ou le lancement d'un Docker.  

**Architecture cible :** Ci-dessous, l'architecture cible souhaitée.   
  
![Screenshot Actions](API_Driven.png)   
  
---------------------------------------------------  
## Processus de travail (résumé)

1. Installation de l'environnement Localstack (Séquence 2)
2. Création de l'instance EC2
3. Création des API (+ fonction Lambda)
4. Ouverture des ports et vérification du fonctionnement

---------------------------------------------------
Séquence 4 : Documentation  
Difficulté : Facile (~30 minutes)
---------------------------------------------------
**Complétez et documentez ce fichier README.md** pour nous expliquer comment utiliser votre solution.  
Faites preuve de pédagogie et soyez clair dans vos expliquations et processus de travail.  
   
---------------------------------------------------
Evaluation
---------------------------------------------------
Cet atelier, **noté sur 20 points**, est évalué sur la base du barème suivant :  
- Repository exécutable sans erreur majeure (4 points)
- Fonctionnement conforme au scénario annoncé (4 points)
- Degré d'automatisation du projet (utilisation de Makefile ? script ? ...) (4 points)
- Qualité du Readme (lisibilité, erreur, ...) (4 points)
- Processus travail (quantité de commits, cohérence globale, interventions externes, ...) (4 points) 







# API-Driven Infrastructure

Ce projet permet de démarrer ou arreter une instance EC2 en envoyant une simple requête HTTP.
La requête passe par une API, qui appelle une fonction Lambda, qui agit ensuite sur l'instance EC2.

Tout fonctionne dans un environnement AWS simulé avec LocalStack, exécuté dans GitHub Codespaces.
L'objectif est de montrer qu'on peut piloter une infrastructure cloud uniquement par une API, sans utiliser d'interface graphique.

## Architecture
- API Gateway reçoit la requête HTTP et la transmet à la Lambda.
- La fonction Lambda lit l'action demandée (start ou stop) et l'envoie à EC2.
- L'instance EC2 démarre ou s'arrête selon l'action reçue.

## Prérequis

- Un environnement GitHub Codespaces (ou Docker en local).
- LocalStack installé (émulateur AWS).
- Un token LocalStack (gratuit sur https://app.localstack.cloud/).
- L'outil awslocal : `pip install awscli-local`

## Installation et démarrage

### 1. Créer un réseau Docker dédié

La fonction Lambda et LocalStack doivent communiquer entre eux.
Pour cela, on crée un réseau Docker et on y connecte LocalStack.

```bash
docker network create ls-net
```

### 2. Démarrer LocalStack sur ce réseau

On lance LocalStack en lui indiquant d'utiliser le réseau `ls-net` pour les Lambda.

```bash
export LAMBDA_DOCKER_NETWORK=ls-net
localstack auth set-token "il faut mettre votre token"
localstack start -d
docker network connect ls-net localstack-main
```

### 3. Lancer le script d'installation

Ce script crée automatiquement toute l'infrastructure : l'instance EC2, la fonction Lambda et l'API Gateway.

```bash
chmod +x setup.sh
./setup.sh
```

À la fin, le script affiche l'ID de l'instance EC2, l'ID de l'API, et les commandes à utiliser pour tester.

## Utilisation

Une fois l'infrastructure prête, on pilote l'instance EC2 avec des requêtes HTTP.
Remplacez `<API_ID>` et `<INSTANCE_ID>` par les valeurs affichées à la fin du script.

### Arrêter l'instance

```bash
curl "http://localhost:4566/_aws/execute-api/<API_ID>/dev/ec2?action=stop&instance_id=<INSTANCE_ID>"
```

Réponse attendue :

```json
{"message": "Instance i-xxxxx arretee"}
```

### Démarrer l'instance

```bash
curl "http://localhost:4566/_aws/execute-api/<API_ID>/dev/ec2?action=start&instance_id=<INSTANCE_ID>"
```

### Vérifier l'état de l'instance

```bash
awslocal ec2 describe-instances --query "Reservations[].Instances[].State.Name" --output text
```

Cette commande affiche `running` (démarrée) ou `stopped` (arrêtée).

## Comment ça marche

Le projet repose sur trois services AWS qui travaillent ensemble :

- API Gateway : c'est la porte d'entrée. Il reçoit la requête HTTP et récupère les paramètres `action` et `instance_id` dans l'URL.
- Fonction Lambda : c'est le cerveau. Elle lit l'action demandée, se connecte à EC2 grâce à la librairie `boto3`, puis lance ou arrête l'instance.
- Instance EC2 : c'est la ressource pilotée. Elle change d'état (démarrée ou arrêtée) selon l'action reçue.

La fonction Lambda communique avec EC2 via l'adresse interne `http://localstack-main:4566`, ce qui est possible grâce au réseau Docker `ls-net` configuré à l'installation.