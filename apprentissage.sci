clc;

// =====================
// PHASE D'APPRENTISSAGE
// =====================

function apprentissage()
    images = chargerImages(); 

    [T,moyenne,ecart_type] = creerT(images); // T est le tableau individu attribut
    // afficherImage(T);

    T_normalise = normaliser(T, moyenne, ecart_type);
    //afficherImage(T_normalise);

    eigenfaces = analyseComposantesPrincipales(T_normalise);
    afficherEigenfaces(eigenfaces); 

    descripteurs = calculDescripteurs(T_normalise, eigenfaces); // Pas de sens de l'afficher
endfunction

// Récupère la moitié des images proposées. Elles vont constituer la base d'apprentissage.
function images = chargerImages()
    check = chdir(path_images); // Nécessaire pour faire le ls
    assert_checktrue(check);

    resultat_ls = ls(path_images); 
    // Supprimer ce qui n'est pas répertoire, par exemple de fichiers cachés, README...
    for i = 1 : size(resultat_ls, 1)
        if isdir(resultat_ls(i)) == %t then 
            individus($ + 1) = string(resultat_ls(i));
        end
    end
    assert_checktrue(size(individus, 1) == nombre_individus); 

    image_num = 0; // Nombre d'images total déjà chargé
    for indice_individu = 1 : nombre_individus 
        path_temp = strcat([path_images slash_c individus(indice_individu)]);
        check = chdir(path_temp); 
        assert_checktrue(check);

        // Choix effectué : prendre les premières images triées par ordre croissant (1...n). D'autres choix possibles ayant une influence sur le résultat de l'apprentissage !
        for indice_image = 1 : nombre_image_apprentissage
            image_num = image_num + 1;
            nom_image = strcat([string(indice_image) image_extension]); 
            assert_checktrue(isfile(nom_image)); // Vérifie que l'image existe bien
            image_originale = chargerImage(nom_image);
            images(:, :, image_num) =  redimensionnerImage(image_originale); // Hypermatrice contenant les images réduites
            vecteur_identifiants(image_num) = individus(indice_individu); // Création d'un vecteur contenant l'identifiant de l'individu pour chaque image chargée
        end
        check = chdir('..');
        assert_checktrue(check);
    end

    assert_checktrue(image_num == nombre_images_total); 
    assert_checktrue(size(vecteur_identifiants,1) == nombre_images_total);
    assert_checktrue(size(vecteur_identifiants,2) == 1);

    memoriser(vecteur_identifiants, 'identifiants', %t);
endfunction

function [T,moyenne,ecart_type] = creerT (images)
    for i = 1 : size(images, 3)
        T(i,:) = imageEnVecteur(images(:,:,i));
    end
    assert_checktrue(size(T,1) == nombre_images_total); 
    assert_checktrue(size(T,2) == 2576); // Toute l'image rendue sur une ligne. Dépends de la taille des images pour l'apprentissage, on a choisi de travailler uniquement en 56*46

    // Calculs de la moyenne et de l'écart-type nécessaire pour les normalisations
    moyenne = mean(T,1);
    ecart_type = stdev(T,1);

    memoriser(moyenne, 'moyenne_T', %f);
    memoriser(ecart_type,'ecart_type_T', %f);
endfunction

function eigenfaces_tronquees = analyseComposantesPrincipales(T_normalise)
    stacksize('max'); // Eviter des dépassements de pile mémoire sur Scilab pour le calcul de la matrice de covariance
    [eigenfaces,S,V] = svd(cov(T_normalise)); // U correspond aux eigenfaces   

    // On tronque les eigenfaces aux 'taille_descripteurs' premiers vecteurs (colonnes)
    eigenfaces_tronquees = eigenfaces(:, [1:1:taille_descripteurs]); 
    assert_checktrue(size(eigenfaces_tronquees, 1) == 2576); 

    memoriser(eigenfaces_tronquees, 'eigenfaces', %f);
endfunction

function descripteurs = calculDescripteurs(T_normalise, eigenfaces) 
    // Les descripteurs sont en quelque sorte un résumé de la base d'image d'apprentissage
    descripteurs = T_normalise * eigenfaces; 
    assert_checktrue(size(descripteurs, 1) == nombre_images_total);
    assert_checktrue(size(descripteurs, 2) == taille_descripteurs);

    memoriser(descripteurs, 'descripteurs', %f);
endfunction

// On doit retravailler les eigenfaces pour pouvoir les afficher
function afficherEigenfaces(eigenfaces)
    render = [];
    eigenfaces = eigenfaces * 1000 + 128;
    for i = 1 : size(eigenfaces, 2) // On a l'eigenfaces sous forme d'une seule ligne, pour affichage on remet en [lignes,colonnes]
        image = matrix(eigenfaces(:, i), 56, 46);
        render = [render image];
    end
    afficherImage(render);
endfunction

clc;
apprentissage;
