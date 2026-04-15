<div style="width:30%; margin: auto;">

![alt text](image-5.png)

</div>

# Introduction

80% des entreprises dans le monde gèrent leur réseau de sessions internes à l'aide de Active Directory (AD).  
AD est un service proposé par Windows permettant de répertorier et gérer les utilisateurs ainsi que les informations qui leurs sont attribuées, telles que les noms et adresses e-mails des utilisateurs. AD gère également l'authentification et les autorisations des différents utilisateurs.

AD possède différents objets, que l'on peut classer selon 3 catégories : les utilisateurs, les groupes, et les ressources (ou le matériel informatique de l'inetreprise). Ces différents objets sont regroupés dans des OU (Organization Unit), qui sont régis par des GPO (Group Policy Objects). Le tout est à l'intérieur d'un domaine, qui peut être autogéré.

Un domaine peut être l'origine d'un arbre de domaines s'il possède des child domains, une forêt est quand il y a d'autres couches de root/child domains en plus.

Voici un exemple de possible configuration d'Active Directory :

- Root Entreprise (*Forest level*)
    - Région France (*Tree level*)
        - Département Paris (*Domain*)
        - Département Bordeaux (*Domain*)
    - Région USA (*Tree level*)
        - Département Chicago (*Domain*)
        - Département New-York (*Domain*)
            - *OU* Marketing
            - *OU* Ressources Humaines
                - *User* Jessica
                - *User* Clément
            - *OU* Informatique
                - *Group* Admin
                    - *User* Olivier
                - *User* François
        - Département Miami (*Domain*)

On a également des DC (Domain Controller) qui servent basiquement à synchroniser le réseau, et permettre aux utilisateurs de partager et lire des fichiers sur le réseau. D'un autre côté, on a des RODC (Read-Only DC) qui permettent la même chose, mais en lecture uniquement, augmentant considérablement la sécurité.

Bloodhound sert ici à analyser et visualiser les relations au sein d'un AD, afin de permettre à un pentesteur/défenseur de trouver des chemins de failles (mauvaises configurations...) à partir d'un compte utilisateur vers un compte administrateur.

## Sommaire

- [Installation](#installation)
    - [Bloodhound](#bloodhound)
    - [Rusthound](#rusthound)
- [Utilisation de Bloodhound](#utilisation-de-bloodhound)
    - [Récupération des données](#récupération-des-données)
    - [Visualisation de l'AD](#visualisation-de-lad)
- [Liens utiles](#liens-utiles)

# Installation

## Bloodhound

Voici un résumé pour l'installation de l'outil **Bloodhound** :

```shell
sudo apt upgrade
sudo apt install bloodhound
sudo bloodhound-setup
```

Le navigateur s'ouvrira tout seul sur la page de Neo4j, le service de base de données utilisé par Bloodhound.

Des logins sont demandés, à la première connexion ce sont `user:neo4j`/`passw:neo4j`. Un nouveau mot de passe est demandé, ce sera celui pour le service Neo4j sur la machine.

Ensuite, retournez sur le terminal, et modifiez une ligne dans le fichier :

```shell
sudo nano /etc/bhapi/bhapi.json
```

Et modifiez la ligne `"secret": "neo4j"` avec le nouveau mot de passe défini.

Enfin, ouvrez Bloodhound avec la commande :

```shell
sudo bloodhound
```

Le navigateur s'ouvrira alors, rentrez les logins par défaut `user:admin`/`passw:admin`. A nouveau, un nouveau mot de passe sera demandé, ce sera celui pour Bloodhound sur la machine. Ce sera celui demandé à toutes les nouvelles connexions.

## Rusthound

```shell
# Install rustup and Cargo for Linux                                         
curl https://sh.rustup.rs -sSf | sh

# Add Windows deps
rustup install stable-x86_64-pc-windows-gnu
rustup target add x86_64-pc-windows-gnu

# Static compilation for Windows
git clone https://github.com/OPENCYBER-FR/RustHound
cd RustHound
RUSTFLAGS="-C target-feature=+crt-static" cargo build --release --target x86_64-pc-windows-gnu
```

# Utilisation de Bloodhound

![Interface Bloodhound](image.png)

Voici l'interface principale de Bloodhound. Il y a en haut à gauche 3 onglets :

* Search :
* Pathfinding :
* Cypher :

## Récupération des données

Cette commande est à effectuer depuis notre machine Linux :

```shell
sudo bloodhound-python -u 'utilisateur' -p 'mot-de-passe' -ns 10.20.34.56 -d nom-de-domaine.com -c all
```

- `-u` : Le nom de l'utilisateur infiltré ;
- `-p` : Son mot de passe ;
- `-ns` : L'adresse IP du serveur AD ;
- `-d` : Le nom de domaine correspondant ;
- `-c all` : Pour obtenir le maximum d'informations disponibles.

L'analyse par défaut de Blodhound n'est pas forcément la plus complète, alors on peut utiliser à la place Rusthound, qui est une extension du code de Bloodhound Python. Cette extension est à la fois plus complète et plus rapide. La syntaxe est similaire :

```shell
sudo rusthound -u 'utilisateur' -p 'mot-de-passe' -f 10.20.34.56 -d nom-de-domaine.com -z
```
- `-u` : Le nom de l'utilisateur infiltré ;
- `-p` : Son mot de passe ;
- `-f` : L'adresse IP du serveur AD ;
- `-d` : Le nom de domaine correspondant ;
- `-z` : Compresse tous les JSON obtenus en un seul fichier ZIP.

Dans le cas où l'on ne possède pas les logins d'un utilisateur, mais qu'on accède tout de même à sa session via un autre moyen, on peut utiliser Sharphound, qui se présente cette fois sous forme d'exécutable à l'adresse suivante :

> https://github.com/SpecterOps/BloodHound-Legacy/tree/master/Collectors

Il y a le .exe à exécuter directement sur le Windows, ou le fichier .ps1 qui est la version PowerShell.

*Rappel pour lancer un exécutable Windows :*

```powershell
.\executable.exe
.\executable.ps1
```

## Visualisation de l'AD

Avec les commandes précédentes, on a obtenu des fichiers JSON, que l'on peut désormais upload dans l'interface de Bloodhound.

![alt text](image-1.png)
![alt text](image-2.png)

Dans l'exemple ici, on va étudier le dataset officiel fourni par Bloodhound. Ces données ont été générées via **Sharphound**.

### Nœuds et recherche de nœuds

![alt text](image-6.png)

Un nœud est un élément du réseau de l'Active Directory. Ça peut être un utilisateur, un groupe, un ordinateur... Ici, on recherche l'utilisateur *Alice*, et on obtient les informations associées au compte, comme par exemple :

- Type de nœud (*User*)
- Date de création
- Droits administrateurs
- Dernière modification du mot de passe
- Etc.

On peut également connaître les groupes dont *Alice* fait partie, les ordinateurs sur lesquels son compte a été connecté, les différents privilèges qu'elle possède, et de manière générale tous les objets du réseau connecté au compte, que ça soit sur des relations entrantes ou sortantes.

Pour les autres types de nœuds, les catégories s'adaptent à ce qui correspond au besoin et aux relations que ce nœud possède avec les autres.

Bloodhound permet de marquer des nœuds, permettant de garder trace des nœuds auxquels on a accès. Pour ça, il faut faire un clic-droit sur le nœud correspondant, puis cliquer sur *Add to Owned*. Cela permet à Bloodhound de se concentrer sur ces nœuds marqués et de proposer des chemins de *privilege escalation*.

![alt text](image-7.png)

Entre chaque nœud du graphe est noté la relation qu'il y a entre les deux. Cette relation est en réalité un chemin (via un exploit, une permission donnée...), qui est expliquée lorsque l'on clique sur la relation en question.

![alt text](image-9.png)

### Pathfinding

Pour connaître chaque relation et chaque nœud entre deux nœuds connus (un détenu et un visé par exemple), on peut utiliser l'outil Pathfinding.

On y rentre le nœud de départ (Ici Alice), puis le nœud d'arrivée (ici Bob), puis Bloodhound nous trace le chemin à parcourir et les différents nœuds à s'emparer avant de récupérer notre objectif.

![alt text](image-10.png)

### Requêtes Cypher

Dans l'onglet Cypher en haut à gauche, il y a beaucoup de requêtes déjà préfaites pour chercher efficacement des nœeuds à interêt dans le graphe. Par exemple, la commande préfaite *All Domain Admins* permet de lister et de visualiser tous les admins du réseau.

![alt text](image-8.png)

D'autres requêtes sont listées, et pour en avoir encore plus, voire aux [liens utiles en bas de page](#liens-utiles).

# Liens utiles

- [Documentation Bloodhound](https://www.kali.org/tools/bloodhound/)
- [Repository Rusthound](https://github.com/NH-RED-TEAM/RustHound)
- [Requêtes Cypher](https://hausec.com/2019/09/09/bloodhound-cypher-cheatsheet/)
