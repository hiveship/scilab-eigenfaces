

Reconaissance faciale par les Eigenfaces
=====================

Implémentation Scilab d'une détection de visage par la méthode des eigenfaces. Projet de machine learning / traitement d'images réalisé dans le cadre de la 2e année de formation d'ingénieur à l'ENSSAT.

> **Note:**

> Avant l'éxécution du script d'apprentissage ou de reconaissance, il est impératif que le script **global.sci** ai été chargé dans l'interpréteur Scilab.

Ce projet est donné fonctionnel uniquement avec la base d'images fournies. Aucun test n'a été réalisé avec une autre base. Si vous souhaitez changer de base d'image, sa structure (son arborescence) doit rester la même.

Global
---------

Script commun à tout le projet. C'est le seul fichier qui doit être modifié par l'utilisateur.
- **slash_c** : caractère slash à utiliser (dépendant de votre système d'exploitation)
- **path_base** : chemin absolu vers la racine du répertoire du projet
- **nombre_image_apprentissage** : nombre d'images à utiliser pour la phase d'apprentissage. Dois être compris entre 1 et 9.
- **taille_descripteurs** : taille utilisée pour le calcul des descripteurs. Corresponds au nombre de vecteurs utilisé lors de la troncature des eigenfaces. Par défaut à 48 selon la norme MPEG-7.

Apprentissage
-------------------

Il s'agit du script permettant de construire la base d'apprentissage. Il est normal qu'il demande un certain temps pour s'exécuter.
La seule fonction appelable est **reconaissance**, aucun paramètre n'est demandé.

Reconnaissance
----------------------

Il s'agit du script permettant d'effectuer des tests de reconaissance. 
- **reconaissance(identifiant_individu_requete, photo_requete)** : permets d'effectuer un test simple de reconaissance faciale. *identifiant_individu_requete* correspond à l'identifiant de l'individu à reconnaitre (par exemple 's40' sur la base fournie).*photo_requete* corresponds à la photo de l'individu que vous voulez utiliser pour la requête (par exemple '6' sur la base fournie).
- **tests** : Permets de lancer un test de reconaissance sur l'ensemble des photos de la base initiale n'ayant pas été traité lors de l'apprentissage. Il est normal que cette fonction demande un certain temps pour s'exécuter. À l'issu de l'exécution, le taux de réussite vous sera affiché.

Vous pouvez changer la valeur du paramètre **affichage** si vous voulez ou non l'affichage des détails lors de la reconaissance. Actif par défaut. Le programme est plus long à s'exécuter si l'affichage est activé.
