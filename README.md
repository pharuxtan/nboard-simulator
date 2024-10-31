<div align="center">
  <h1>Simulateur de Nboard</h1>
  <p>Un simulateur destiné aux étudiants en première année à l'IUT de Cachan</p>
</div>

---

<!-- TOC -->

- [Usage](#usage)
- [Compilation du projet](#compilation-du-projet)
  - [Prérequis](#prérequis)
  - [Compilation](#compilation)
  - [Développement](#développement)

<!-- /TOC -->

## Usage

La Nboard est une carte électronique programmable utilisée en première année par les étudiants de l'IUT de Cachan. Elle permet d'apprendre les bases de la programmation embarquée de façon ludique, en utilisant plusieurs modules. Les étudiants seront donc amenés à allumer des LEDs et à interagir avec le potentiomètre ainsi qu'avec les boutons poussoirs.

L'apprentissage est néanmoins limité aux cours de TP, qui sont le seul moment où les cartes physiques sont à leur disposition. Ce simulateur intervient donc pour leur donner la possibilité de s'exercer en dehors des TP.

## Compilation du projet

### Prérequis

Pour compiler le simulateur, vous aurez besoin de :

 - Windows
 - Zig 0.13.0 - https://zvm.app/
 - Node.js - https://nodejs.org/

Une fois que vous avez installé ZVM, vous devez installer Zig 0.13.0. Pour cela, il vous suffit d'exécuter les commandes suivantes :

```sh
zvm install 0.13.0
zvm use 0.13.0
```

### Compilation

Pour compiler, exécutez à la racine du projet la commande suivante :

```sh
zig build
```

Vous trouverez l'exécutable compilé dans le dossier `build/Release`

### Développement

Il est recommandé d'utiliser [Visual Studio Code](https://code.visualstudio.com/) pour développer, car il intègre tous les outils nécessaires pour déboguer efficacement. Néanmoins, si vous souhaitez compiler en mode Debug, exécutez à la racine du projet la commande suivante :

```sh
zig build -Ddev
```

Vous trouverez l'exécutable compilé ainsi que le PDB associé dans le dossier `build/Debug`