// ==================
// VARIABLES GLOBALES
// ==================

individu_requete = 's37';
image_requete = '8'; 

function test()
    path_image_requete = strcat([path_images slash_c individu_requete slash_c image_requete '.pgm']);
    check = chdir(path_images);
    assert_checktrue(check);
    
    image_requete = chargerImage(path_image_requete); // Prendre une image n'ayant pas été utilisée dans la base de test ! 
    requete_vecteur = imageEnVecteur(image_requete);
    
    // Chargement des données
    moyenne = recupererInformation('moyenne_T');
    ecart_type = recupererInformation('ecart_type_T');
    eigenfaces = recupererInformation('eigenfaces_48');
    descripteurs = recupererInformation('descripteurs');
    
    //requete_normalise = normaliser(requete_vecteur, moyenne, ecart_type); // Appel à la même fonction que pour la phase d'apprentissage
   // descripteur_requete = calculDescripteurs(requete_normalise, eigenfaces);
    
   // comparaisonDescripteurs(descripteur_requete, descripteurs);
    
    afficherImage(image_requete);
endfunction

function individu = comparaisonDescripteurs(descripteur_requete, descripteurs) // descripteurs = issus de la phase d'apprentissage
    individu = 0; // Individu ayant été reconnu
    descripteur_requete_rep = repmat(vector, size(D,1),1); // Repète le descripteur de l'image requête pour obtenir une matrice de la même taille que l'enssemble des descripteurs
    distance = descripteur_requete_rep - descripteurs;
    [distance,c] = min(diag(distance * distance'));
   
    nb = 3;
    individu = ceil(c/nb); // TODO: C'EST QUOI nb ? voir avec Alexis
    disp(individu);
endfunction

clc;
test
