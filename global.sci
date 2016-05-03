slash_c = '\'; // Dépends du système utilisé
path_base = '\\Mac\Home\Desktop\TraitementImage\CCARIOU'; // Emplacement racine du projet 
path_images = strcat([path_base slash_c 'att_faces']); 
path_sauvegardes = strcat([path_base slash_c 'data']); // Répertoire où sauvegarder/charger les données calculées

// Sauvegarde une donnée en l'enregistrant au format CSV
function memoriser(information, nom_fichier)
    check = chdir(path_sauvegardes);
    assert_checktrue(check);
    nom_fichier_csv = strcat([nom_fichier '.csv']);
    csvWrite(information, nom_fichier_csv);
    chdir('..');
    
    // Test pour vérifier qu'on est capable de récupérer correctement ce qu'on sauvegarde // TODO: commenter les tests ?
    information_recup = recupererInformation(nom_fichier);
    assert_checkequal(information, information_recup);
endfunction

function information = recupererInformation(nom_fichier)
    check = chdir(path_sauvegardes); // On veux charger une donnée donc le répertoire cible est supposé éxistant
    assert_checktrue(check);
    nom_fichier_csv = strcat([nom_fichier '.csv']);
    information = csvRead(nom_fichier_csv);
endfunction

// Converti une matrice image en un seul vecteur ligne
function vecteur = imageEnVecteur(image)
    [lignes, colonnes] = size(image);
    vecteur = matrix(image, lignes * colonnes, 1)';
endfunction

function image_redimensionne = redimensionnerImage(image, lignes, colonnes)
    image_redimensionne = imresize(image, [lignes colonnes]);
endfunction

function matrice_image = chargerImage(path)
    matrice_image = double(imread(path));
endfunction

function afficherImage(matrice_image)
    // Affiche la représentation d'une imge à partir de sa matrice dans l'utilitaire de scilab
    imshow(uint8(matrice_image));
endfunction
