function apprentissage()
    images = chargerImages(path_images, 200); // On prends la moitié de la base totale d'images soit 400/2=200
    
    [T,moyenne,ecart_type] = creerT(images); // T est le tableau individu-attribut
   // afficherImage(T); // OK
   
    T_normalise = normaliser(T, moyenne, ecart_type);
    //afficherImage(T_normalise); // OK
    
    eigenfaces = analyseComposantesPrincipales(T_normalise);
    //afficherEigenfaces(eigenfaces); // OK
    
    descripteurs = calculDescripteurs(T_normalise, eigenfaces);
endfunction

// Récupère la moitiée des images proposées. Elles vont constituer la base d'apprentissage.
function images = chargerImages(path, images_voulues)
    check = chdir(path);
    assert_checktrue(check);
    
    repertoires = ls(path); // TODO: fichier cachés ./foo
    nombre_repertoires = size(repertoires, 1); 
    images_par_repertoire = 5; // TODO: Rendre ce calcul plus générique
    
    image_num = 0; // Nombre d'images total déjà chargées
    for indice_repertoire = 1 : nombre_repertoires // Itération sur chaque dossier contenant des images
        path_temp = strcat([path slash_c repertoires(indice_repertoire)]);
        if isdir(path_temp) <> %t then // Pas un répertoire, on passe 
            continue;
        end
        check = chdir(path_temp); // On est assuré que c'est bien un repertoire
        assert_checktrue(check);
        
        // Choix éffectué : prendre les 5 premières images triées par noms (1.pgm, ... 5.pgm) par répertoire pour l'apprentissage. D'autres mode de sélection possible !
        for indice_image = 1 : images_par_repertoire
            image_num = image_num + 1;
            nom_image = strcat([string(indice_image) '.pgm']); // Dépencdant de la base d'images
            assert_checktrue(isfile(nom_image)); // Vérifie que l'image éxiste bien
            image_originale = chargerImage(nom_image);
            images(:, :, image_num) =  redimensionnerImage(image_originale, 56, 46); // hypermatrice contenant les images réduites
        end
        check = chdir('..');
        assert_checktrue(check);
    end
    assert_checktrue(image_num == 200); // TODO: uniquement pour le TP, faire avec un pourcentage
endfunction

function [T,moyenne,ecart_type] = creerT (images)
    for i = 1 : size(images, 3)
        image_vecteur = imageEnVecteur(images(:,:,i));
        T(i,:) = image_vecteur;
    end
    assert_checktrue(size(T,1) == 200); // Nombre d'images
    assert_checktrue(size(T,2) == 2576); // Toute l'image rendu sur une ligne. 46*56 TODO: faire le calcul au lieux de mettre en dur
    
    // Calculs de la moyenne et de l'écart-type nécéssaire pour les normalisations
     moyenne = mean(T, 1);
     ecart_type = stdev(T, 1);
     
     memoriser(moyenne, 'moyenne_T');
     memoriser(ecart_type,'ecart_type_T');
endfunction

function T_normalise = normaliser(T, moyenne, ecart_type)
    nombre_individu = size(T, 1); 
    moyenne = repmat(moyenne, nombre_individu, 1);
    ecart_type = repmat(ecart_type, nombre_individu, 1);
    T_normalise = T - moyenne;
    T_normalise = T_normalise ./ ecart_type;
    
    // Après normalisation on ne doit pas changer la taille de T
    assert_checktrue(size(T_normalise,1) == size(T,1)); // Nombre d'images
    assert_checktrue(size(T_normalise,2) == size(T,2)); 
endfunction

function eigenfaces = analyseComposantesPrincipales(T_normalise)
    matrice_covariance = cov(T_normalise);
    
    // S : valeurs propres sur la diagonale
    // U, V : vecteurs propres. U correspond aux eigenfaces.
    [U,S,V] = svd(matrice_covariance);

    // On tronque les eigenfaces aux 48 premiers vecteurs (colonnes)
    eigenfaces = U(:,[1:1:48]); // 48 fixé ("arbitrairement") pour avoir un bon résultat sans trop d'infos supplémentaires
    assert_checktrue(size(eigenfaces, 1) == 2576); // TODO: le calculer ?
    assert_checktrue(size(eigenfaces, 2) == 48); 
    
    memoriser(eigenfaces, 'eigenfaces_48');
endfunction

function descripteurs = calculDescripteurs(T_normalise, eigenfaces) // projection
    // Les descripteurs sont en quelque sorte un résumé de la base d'image d'apprentissage
    descripteurs = T_normalise * eigenfaces; 
    assert_checktrue(size(descripteurs, 1) == 200); // TODO: calculer ?
    assert_checktrue(size(descripteurs, 2) == 48);
    
    memoriser(descripteurs, 'descripteurs');
endfunction

// On doit retravailler les eigenfaces pour pouvoir les afficher
function afficherEigenfaces(eigenfaces)
    render = [];
    eigenfaces = eigenfaces * 1000 + 128;
    for i = 1 : size(eigenfaces,2)
        image = matrix(eigenfaces(:,i), 56, 46);
        render = [render image];
    end
    afficherImage(render);
endfunction

clc;
stacksize('max'); // Eviter des dépassement de pile mémoire sur Scilab
apprentissage
