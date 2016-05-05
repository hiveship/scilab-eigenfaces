clc;

// ======================
// VARIABLES / CONSTANTES
// ======================

identifiant_individu_requete = 's4';
id_image_requete = 10; 
assert_checktrue(id_image_requete > 5 & id_image_requete <= 10); // Prendre une image n'ayant pas été utilisée dans la base de test ! // TODO: Test uniquement valable pour la base d'image fournie
photo_requete = string(id_image_requete); // Pour la concaténation de strings

// ======================
// PHASE DE RECONAISSANCE
// ======================

function reconaissance()
    [image_requete, image_requete_redim, descripteur_requete] = preparerRequete();

    index_meilleur_descripteur = comparaisonDescripteurs(descripteur_requete);
    identifiant_individu_reconnu = retrouverIndividu(index_meilleur_descripteur); // Reconaissance terminée après cette fonction

    // AFFICHAGE
    // ---------

    disp(strcat(['Reconnu -> ' identifiant_individu_reconnu ' . La requête était -> ' identifiant_individu_requete]));

    // Récupérer l'image de l'individu reconnu. On recupère arbitrairement sa première image 1.pgm (ATTENTION : peut évoluer si on change de base d'images)
    path_image_individu_reconnu = strcat([path_images slash_c identifiant_individu_reconnu slash_c '1' image_extension])
    individu_reconnu = chargerImage(path_image_individu_reconnu);
    render = cat(2, image_requete, individu_reconnu);
    afficherImage(render);
endfunction

function [image_requete, image_requete_redim, descripteur_requete] = preparerRequete()
    path_image_requete = strcat([path_images slash_c identifiant_individu_requete slash_c photo_requete image_extension]);
    image_requete = chargerImage(path_image_requete);  

    // Il faut appliquer éxactement les même transformations que dans la phase d'apprentissage pour calculer le descripteur
    image_requete_redim = redimensionnerImage(image_requete);
    requete_vecteur = imageEnVecteur(image_requete_redim);

    // Récupérer les données calculées pendant l'apprentissage
    moyenne_apprentissage = recupererInformation('moyenne_T', %f);
    ecart_type_apprentissage = recupererInformation('ecart_type_T', %f);
    requete_normalise = normaliser(requete_vecteur, moyenne_apprentissage, ecart_type_apprentissage); // Appel à la même fonction que pour la phase d'apprentissage

    eigenfaces = recupererInformation('eigenfaces', %f);
    descripteur_requete = requete_normalise * eigenfaces;
endfunction

function index_meilleur_descripteur = comparaisonDescripteurs(descripteur_requete) 
    descripteur_requete = repmat(descripteur_requete, size(descripteurs_tous_individus, 1), 1); // Repète le descripteur de l'image requête pour obtenir une matrice de la même taille que l'enssemble des descripteurs

    descripteurs_tous_individus = recupererInformation('descripteurs', %f);
    delta = descripteurs_tous_individus - descripteur_requete;

    // On veux le descripteur ayant le plus de ressemblance :  dont la distance avec le descripteur de la requête est le plus faible
    distances = delta * delta'; // Calcul des normes pour pouvoir comparer les deux descripteurs (ce sont des vecteurs)

    // La diagonale contient la distance entre le descripteur de la requête et chacun des autres edescripteurs. (On a fait des calculs "pour rien" (les autres termes) mais c'est plus rapide que de faire des boucles)
    [dsitance_min, index_meilleur_descripteur] = min(diag(distances)); 
endfunction

// Retrouver à quel individu appartient un descripteur
function identifiant_individu_reconnu = retrouverIndividu(index_descripteur)
    identifiants_individus = recupererInformation('identifiants', %t);
    identifiant_individu_reconnu = identifiants_individus(index_descripteur);
endfunction

clc;
reconaissance;
