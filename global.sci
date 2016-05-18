clc;

// ===============================
// VARIABLES / CONSTANTES GLOBALES
// ===============================

slash_c = '\'; // TODO: Dépends du système utilisé

path_base = '\\Mac\Home\Desktop\TraitementImage\CCARIOU\eigenfaces'; // Emplacement racine du projet. TODO: À modifier pour chaque utilisateur
path_sauvegardes = strcat([path_base slash_c 'data']); // Répertoire où sauvegarder/charger les données calculées

// PARAMETRES LIES A LA BASE D'IMAGE
// ---------------------------------
path_images = strcat([path_base slash_c 'att_faces']);  // Structure attendue pour la base : 1 répertoire par individu, contenant uniquement des images nommées 1..n.extension
image_extension = '.pgm';
nombre_individus = 40; 
images_total_par_individu = 10;

// PARAMETRES CONFIGURABLE
// -----------------------
nombre_image_apprentissage = 5; // Nombre de photos par individu réservées à l'apprentissage TODO: Faire varier pour observer l'influence
nombre_images_total = nombre_individus * nombre_image_apprentissage;
taille_descripteurs = 48; // On garde un certain nombre de eigenfaces pour avoir de bons résultats sans trop d'informations superflues. Fixé "arbitrairement" 

assert_checktrue(nombre_individus > 0);
assert_checktrue(nombre_image_apprentissage > 0);
assert_checktrue(nombre_image_apprentissage < 10);
assert_checktrue(taille_descripteurs > 0);
assert_checktrue(taille_descripteurs < 2576);

// =====================
// FONCTIONS UTILITAIRES
// =====================

// Fonction initialement prévue pour la phase d'apprentissage mais également utilisée pour le calcul du descripteur lors de la reconaissance
function T_normalise = normaliser(T, moyenne, ecart_type)
    nombre_individu = size(T,1); 
    moyenne = repmat(moyenne, nombre_individu, 1);
    ecart_type = repmat(ecart_type, nombre_individu, 1);
    T_normalise = T - moyenne;
    T_normalise = T_normalise ./ ecart_type;

    // Après normalisation on ne doit pas changer la taille de T
    assert_checktrue(size(T_normalise, 1) == size(T, 1)); 
    assert_checktrue(size(T_normalise, 2) == size(T, 2)); 
endfunction

// Sauvegarde une donnée en l'enregistrant au format CSV. 'estString' indique si on sauvegarde une information contenant des chaines de caractères
function memoriser(information, nom_fichier, estString)
    check = chdir(path_sauvegardes);
    assert_checktrue(check);

    csvWrite(information, calculerNomCSV(nom_fichier)); // Si le fichier existe déjà il y a réécriture
    chdir('..');

    // Test pour vérifier qu'on est capable de récupérer correctement ce qu'on sauvegarde (utile pendant le développement)
    information_recup = recupererInformation(nom_fichier, estString);
    assert_checkequal(information, information_recup);
endfunction

// Récupère une information à partir d'un fichier CSV existant. Ne pas préciser l'extension dans le nom du fichier
function information = recupererInformation(nom_fichier, estString)
    check = chdir(path_sauvegardes); // On veut charger une donnée donc le répertoire cible est supposé existant
    assert_checktrue(check);

    nom_fichier_csv = calculerNomCSV(nom_fichier);
    assert_checktrue(isfile(nom_fichier_csv)); // Vérifie que le fichier que l'on veut lire existe

    if estString == %t then  // Scilab ne gère pas de la même manière la lecture de csv contenant des strings ou des doubles (les identifiants d'individus sont des strings)
        information = read_csv(nom_fichier_csv);
    else
        information = csvRead(nom_fichier_csv);
    end
    chdir('..');
endfunction

function nom_fichier_csv = calculerNomCSV(nom_fichier)
    nom_fichier_csv = strcat([nom_fichier '.csv']);
endfunction

// Converti une matrice image en un seul vecteur ligne. La taille du vecteur résultant est donc nb_lignes * nb_colonnes de l'image originale
function vecteur = imageEnVecteur(image)
    [lignes, colonnes] = size(image);
    vecteur = matrix(image, lignes * colonnes, 1)';
endfunction

function image_redimensionne = redimensionnerImage(image)
    image_redimensionne = imresize(image, [56 46]);
endfunction

function matrice_image = chargerImage(path)
    matrice_image = double(imread(path));
endfunction

function afficherImage(matrice_image)
    imshow(uint8(matrice_image));
endfunction
