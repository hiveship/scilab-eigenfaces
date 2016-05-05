clc;

// ======================
// VARIABLES / CONSTANTES
// ======================

nombre_individus = 40; 
nombre_image_apprentissage = 5; // Nombre de photos par individu réservées à l'apprentissage TODO: Faire varier pour observer l'influence
nombre_images_total = nombre_individus * nombre_image_apprentissage;

nombre_descripteurs = 48; // 48 fixé ("arbitrairement") pour avoir un bon résultat sans trop d'infos supplémentaires

assert_checktrue(nombre_individus > 0);
assert_checktrue(nombre_image_apprentissage > 0);
assert_checktrue(nombre_descripteurs > 0);

// =====================
// PHASE D'APPRENTISSAGE
// =====================

function apprentissage()
    [images,repertoires] = chargerImages(200); // On prends la moitié de la base totale d'images soit 400/2=200

    [T,moyenne,ecart_type] = creerT(images, repertoires); // T est le tableau individu-attribut
    // afficherImage(T);

    T_normalise = normaliser(T, moyenne, ecart_type);
    //afficherImage(T_normalise);

    eigenfaces = analyseComposantesPrincipales(T_normalise);
    //afficherEigenfaces(eigenfaces); 

    descripteurs = calculDescripteurs(T_normalise, eigenfaces);
endfunction

// Récupère la moitiée des images proposées. Elles vont constituer la base d'apprentissage.
function [images,repertoires] = chargerImages(images_voulues)
    check = chdir(path_images); // Nécéssaire pour faire le ls
    assert_checktrue(check);

    resultat_ls = ls(path_images); 
    // Supprimer ce qui n'est pas répertoire, par exemples de fichiers cachés, README...
    for i = 1 : size(resultat_ls, 1)
        if isdir(resultat_ls(i)) == %t then 
            repertoires($ + 1) = string(resultat_ls(i));
        end
    end
    assert_checktrue(size(repertoires, 1) == nombre_individus); 

    image_num = 0; // Nombre d'images total déjà chargées
    dernier_identifiant = 0; // Variable temporaire pour la construction du veteur identifiant
    for indice_repertoire = 1 : nombre_individus 
        path_temp = strcat([path_images slash_c repertoires(indice_repertoire)]);
        check = chdir(path_temp); // On est assuré que c'est bien un repertoire
        assert_checktrue(check);

        // Choix éffectué : prendre les premières images triées par ordre croissant (1...n). D'autres choix possible ayant une influence sur le résultat de l'apprentissage !
        for indice_image = 1 : nombre_image_apprentissage
            image_num = image_num + 1;
            nom_image = strcat([string(indice_image) image_extension]); // Dépencdant de la base d'images
            assert_checktrue(isfile(nom_image)); // Vérifie que l'image éxiste bien
            image_originale = chargerImage(nom_image);
            images(:, :, image_num) =  redimensionnerImage(image_originale); // hypermatrice contenant les images réduite
            vecteur_identifiants(image_num) = repertoires(indice_repertoire); // Création d'un vecteur contenant l'identifiant de l'individu pour chaque image chargée
        end
        check = chdir('..');
        assert_checktrue(check);
    end

    assert_checktrue(image_num == nombre_images_total); 
    assert_checktrue(size(vecteur_identifiants,1) == nombre_images_total);
    assert_checktrue(size(vecteur_identifiants,2) == 1);

    memoriser(vecteur_identifiants, 'identifiants', %t);
endfunction

function [T,moyenne,ecart_type] = creerT (images, repertoires)
    for i = 1 : size(images, 3)
        image_vecteur = imageEnVecteur(images(:,:,i));
        T(i,:) = image_vecteur;
    end
    assert_checktrue(size(T,1) == nombre_images_total); 
    assert_checktrue(size(T,2) == 2576); // Toute l'image rendu sur une ligne. Dépends de la taille des images pour l'apprentissage, on a choisi de travailler uniquement en 56*46

    // Calculs de la moyenne et de l'écart-type nécéssaire pour les normalisations
    moyenne = mean(T, 1);
    ecart_type = stdev(T, 1);

    memoriser(moyenne, 'moyenne_T', %f);
    memoriser(ecart_type,'ecart_type_T', %f);
endfunction

function T_normalise = normaliser(T, moyenne, ecart_type)
    nombre_individu = size(T, 1); 
    moyenne = repmat(moyenne, nombre_individu, 1);
    ecart_type = repmat(ecart_type, nombre_individu, 1);
    T_normalise = T - moyenne;
    T_normalise = T_normalise ./ ecart_type;

    // Après normalisation on ne doit pas changer la taille de T
    assert_checktrue(size(T_normalise, 1) == size(T,1)); 
    assert_checktrue(size(T_normalise, 2) == size(T,2)); 
endfunction

function eigenfaces = analyseComposantesPrincipales(T_normalise)
    matrice_covariance = cov(T_normalise);
    [U,S,V] = svd(matrice_covariance); // U correspond aux eigenfaces   

    // On tronque les eigenfaces aux 'nombre_descripteurs' premiers vecteurs (colonnes)
    eigenfaces = U(:, [1:1:nombre_descripteurs]); 
    assert_checktrue(size(eigenfaces, 1) == 2576); 

    memoriser(eigenfaces, 'eigenfaces', %f);
endfunction

function descripteurs = calculDescripteurs(T_normalise, eigenfaces) 
    // Les descripteurs sont en quelque sorte un résumé de la base d'image d'apprentissage
    descripteurs = T_normalise * eigenfaces; 
    assert_checktrue(size(descripteurs, 1) == nombre_images_total);
    assert_checktrue(size(descripteurs, 2) == nombre_descripteurs);

    memoriser(descripteurs, 'descripteurs', %f);
endfunction

// On doit retravailler les eigenfaces pour pouvoir les afficher
function afficherEigenfaces(eigenfaces)
    render = [];
    eigenfaces = eigenfaces * 1000 + 128;
    for i = 1 : size(eigenfaces,2) // On a l'eigenfaces sous forme d'une seule ligne, pour affichage on remet en [lignes,colonnes]
        image = matrix(eigenfaces(:, i), 56, 46);
        render = [render image];
    end
    afficherImage(render);
endfunction

clc;
stacksize('max'); // Eviter des dépassement de pile mémoire sur Scilab
apprentissage;
