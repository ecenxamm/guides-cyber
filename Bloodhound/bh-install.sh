#!/bin/bash

# --- Installation de Bloodhound ---
sudo apt upgrade
sudo apt install bloodhound
sudo bloodhound-setup

read -p "Continuez sur le navigateur, entrez les logins neo4j/neo4j. Une fois terminé, revenez ici et tapez sur Entrée."
read -p "Entrez le nouveau mot de passe neo4j : " neo4jmdp

# Ecris le nouveau mdp Neo4j dans le fichier config de BH
sudo sed -i "s/\"neo4j\":\"neo4j\"/\"neo4j\":\"$neo4jmdp\"/" /etc/bhapi/bhapi.json


# --- Installation de Rusthound ---
# Install rustup and Cargo for Linux
curl https://sh.rustup.rs -sSf | sh

# Add Windows deps
rustup install stable-x86_64-pc-windows-gnu
rustup target add x86_64-pc-windows-gnu

# Static compilation for Windows
git clone https://github.com/OPENCYBER-FR/RustHound
cd RustHound
RUSTFLAGS="-C target-feature=+crt-static" cargo build --release --target x86_64-pc-windows-gnu
