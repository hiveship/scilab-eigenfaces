clc;

// Eigenfaces -> bien adapté pour des photos d'identités par exemple. Pas trop pour le reste.
identifiant_individu_requete = 's4';
image_requete = 10; 
assert_checktrue(image_requete > 5 & image_requete <= 10); // Prendre une image n'ayant pas été utilisée dans la base de test ! // TODO: Dépends de la base d'images utilisée et des proportions prises pour l'apprentissage
photo_requete = string(image_requete);

function reconaissance()
    [image_requete, image_requete_redim, descripteur_requete] = preparerRequete();

    index_meilleur_descripteur = comparaisonDescripteurs(descripteur_requete);
    identifiant_individu_reconnu = retrouverIndividu(index_meilleur_descripteur); // Reconaissance terminée après cette fonction

    // AFFICHAGE
    // ---------

    disp(strcat(['Reconnu -> ' identifiant_individu_reconnu ' . La requête était -> ' identifiant_individu_requete]));

    // Récupérer l'image de l'individu reconnu. On recupère arbitrairement sa première image 1.pgm
    path_image_individu_reconnu = strcat([path_images slash_c identifiant_individu_reconnu slash_c '1.pgm'])
    individu_reconnu = chargerImage(path_image_individu_reconnu);
    render = cat(2, image_requete, individu_reconnu);
    afficherImage(render);
endfunction

function [image_requete, image_requete_redim, descripteur_requete] = preparerRequete()
    path_image_requete = strcat([path_images slash_c identifiant_individu_requete slash_c photo_requete '.pgm']);
    image_requete = chargerImage(path_image_requete);  

    // Il faut appliquer éxactement les même transformations que dans la phase d'apprentissage pour calculer le descripteur
    image_requete_redim = redimensionnerImage(image_requete, 56, 46);
    requete_vecteur = imageEnVecteur(image_requete_redim);

    // Récupérer les données calculées pendant l'apprentissage
    moyenne = recupererInformation('moyenne_T', %f);
    ecart_type = recupererInformation('ecart_type_T', %f);
    requete_normalise = normaliser(requete_vecteur, moyenne, ecart_type); // Appel à la même fonction que pour la phase d'apprentissage

    eigenfaces = recupererInformation('eigenfaces_48', %f);
    descripteur_requete = requete_normalise * eigenfaces;
endfunction

function index_meilleur_descripteur = comparaisonDescripteurs(descripteur_requete) 
    descripteurs_tous_individus = recupererInformation('descripteurs', %f);

    descripteur_requete = repmat(descripteur_requete, size(descripteurs_tous_individus,1),1); // Repète le descripteur de l'image requête pour obtenir une matrice de la même taille que l'enssemble des descripteurs

    delta = descripteurs_tous_individus - descripteur_requete;
    // On veux le descripteur dont la norme est la plus faible (plus petite distance entre les deux descripteurs)
    distances = delta * delta'; // normes pour pouvoir comparer deux vecteurs
    // La diagonale contient la distance entre le descripteur de la requête et chacun des autres edescripteurs. (On a fait des calculs pour rien mais toujours plus rapide que de faire des boucles avec Scilab)
    [dsitance_min, index_meilleur_descripteur] = min(diag(distances)); 
endfunction

// Retrouver à quel individu appartient un descripteur
function individu = retrouverIndividu(index_descripteur)
    identifiants_individus = recupererInformation('identifiants', %t);
    individu = identifiants_individus(index_descripteur);
endfunction

clc;
reconaissance;
