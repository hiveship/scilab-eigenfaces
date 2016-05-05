clc;

// ===============================
// VARIABLES / CONSTANTES GLOBALES
// ===============================

slash_c = '\'; // TODO: Dépends du système utilisé

path_base = '\\Mac\Home\Desktop\TraitementImage\CCARIOU\eigenfaces'; // Emplacement racine du projet. TODO: A MODIFIER POUR CHAQUE UTILISATEUR
path_images = strcat([path_base slash_c 'att_faces']);  // Structure attendue pour la base : 1 répertoire par individu, contenant uniquement des images nommés 1..n.extension
path_sauvegardes = strcat([path_base slash_c 'data']); // Répertoire où sauvegarder/charger les données calculées

image_extension = '.pgm';


// =====================
// FONCTIONS UTILITAIRES
// =====================

// Sauvegarde une donnée en l'enregistrant au format CSV. 'estString' indique si on sauvegarde une information contenant des chaines de caractères
function memoriser(information, nom_fichier, estString)
    check = chdir(path_sauvegardes);
    assert_checktrue(check);

    nom_fichier_csv = strcat([nom_fichier '.csv']);
    csvWrite(information, nom_fichier_csv); // Si le fichier éxiste déjà il y a réécriture
    chdir('..');

    // Test pour vérifier qu'on est capable de récupérer correctement ce qu'on sauvegarde (utile pendant le développement)
    //information_recup = recupererInformation(nom_fichier, estString);
    //assert_checkequal(information, information_recup);
endfunction

// Récupère une information à partir d'un fichier CSV éxistant. Ne pas préciser l'extension dans le nom du fichier
function information = recupererInformation(nom_fichier, estString)
    check = chdir(path_sauvegardes); // On veux charger une donnée donc le répertoire cible est supposé éxistant
    assert_checktrue(check);

    nom_fichier_csv = strcat([nom_fichier '.csv']);
    assert_checktrue(isfile(nom_fichier_csv)); // Vérifie que le fichier que l'on veux lire éxiste

    if estString == %t then  // Scilab ne gère pas de la même manière la lecture de csv contenant des string ou des doubles (les identifiants d'individus sont des strings)
        information = read_csv(nom_fichier_csv);
    else
        information = csvRead(nom_fichier_csv);
    end
    chdir('..');
endfunction

// Converti une matrice image en un seul vecteur ligne. La taille du vecteur résultant est donc nb_lignes * nb_colonnes de l'imagine 
function vecteur = imageEnVecteur(image)
    [lignes, colonnes] = size(image);
    vecteur = matrix(image, lignes * colonnes, 1)';
endfunction

function image_redimensionne = redimensionnerImage(image)
    image_redimensionne = imresize(image, [56 46]);
endfunction

// Charge une image depuis le système de fichier
function matrice_image = chargerImage(path)
    matrice_image = double(imread(path));
endfunction

// Affiche la représentation d'une imge à partir de sa matrice dans l'utilitaire de scilab
function afficherImage(matrice_image)
    imshow(uint8(matrice_image));
endfunction
