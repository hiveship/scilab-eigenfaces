clc;

// ======================
// VARIABLES / CONSTANTES
// ======================

identifiant_individu_requete = 's40';
id_image_requete = 6; 
assert_checktrue(id_image_requete > 5 & id_image_requete <= 10); // Prendre une image n'ayant pas été utilisée dans la base de test ! // TODO: Test uniquement valable pour la base d'image fournie
photo_requete = string(id_image_requete); // Pour permettre la concaténation de strings

affichage = %f; // Indique si il faut afficher le résultat de chaque reconaissance (prends plus de temps si active)

// ======================
// PHASE DE RECONAISSANCE
// ======================

function succes = reconaissance(identifiant_individu_requete, photo_requete)
    [image_requete, image_requete_redim, descripteur_requete] = preparerRequete();

    index_meilleur_descripteur = comparaisonDescripteurs(descripteur_requete);
    identifiant_individu_reconnu = retrouverIndividu(index_meilleur_descripteur); // Reconaissance terminée après cette fonction

    succes = isequal(identifiant_individu_reconnu, identifiant_individu_requete);

    // AFFICHAGE
    // ---------

    // Récupérer l'image de l'individu reconnu. On récupère arbitrairement sa première image 1.pgm (ATTENTION : peut évoluer si on change de base d'images)
    if (affichage) then
        disp(strcat(['Reconnu -> ' identifiant_individu_reconnu ' . La requête était -> ' identifiant_individu_requete]));
        path_image_individu_reconnu = strcat([path_images slash_c identifiant_individu_reconnu slash_c '1' image_extension])
        individu_reconnu = chargerImage(path_image_individu_reconnu);
        render = cat(2, image_requete, individu_reconnu);
        afficherImage(render);
    end
endfunction

function [image_requete, image_requete_redim, descripteur_requete] = preparerRequete(identifiant_individu_requete, photo_requete)
    path_image_requete = strcat([path_images slash_c identifiant_individu_requete slash_c photo_requete image_extension]);
    image_requete = chargerImage(path_image_requete);  

    // Il faut appliquer exactement les mêmes transformations que dans la phase d'apprentissage pour calculer le descripteur
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
    descripteurs_tous_individus = recupererInformation('descripteurs', %f);
    descripteur_requete = repmat(descripteur_requete, size(descripteurs_tous_individus, 1), 1); // Repète le descripteur de l'image requête pour obtenir une matrice de la même taille que l'enssemble des descripteurs

    delta = descripteurs_tous_individus - descripteur_requete;

    // On veut le descripteur ayant le plus de ressemblance :  dont la distance avec le descripteur de la requête est le plus faible
    distances = delta * delta'; // Calcul des normes pour pouvoir comparer les deux descripteurs (ce sont des vecteurs)

    // La diagonale contient la distance entre le descripteur de la requête et chacun des autres descripteurs. (On a fait des calculs "pour rien" (les autres termes) mais c'est plus rapide que de faire des boucles)
    // Règle de décision fixée : prendre le plus proche voisin. Il existe d'autres méthodes ayant donc un impact sur la qualité de la reconaissance...
    [dsitance_min, index_meilleur_descripteur] = min(diag(distances)); 
endfunction

// Retrouver à quel individu appartient un descripteur
function identifiant_individu_reconnu = retrouverIndividu(index_descripteur)
    identifiants_individus = recupererInformation('identifiants', %t);
    identifiant_individu_reconnu = identifiants_individus(index_descripteur);
endfunction

// ==================
// TESTS AUTOMATIQUES
// ==================

// Test toutes les images non utilisées dans la base d'apprentissage pour déterminer le taux de réussite
function tests()
    check = chdir(path_images); // Nécéssaire pour faire le ls
    assert_checktrue(check);

    resultat_ls = ls(path_images); 
    // Supprimer ce qui n'est pas répertoire, par exemple de fichiers cachés, README...
    for i = 1 : size(resultat_ls, 1)
        if isdir(resultat_ls(i)) == %t then 
            individus($ + 1) = string(resultat_ls(i));
        end
    end
    assert_checktrue(size(individus, 1) == nombre_individus); 

    nombre_erreurs = 0;
    nombre_tests = 0;
    for indice_individu = 1 : nombre_individus 
        path_temp = strcat([path_images slash_c individus(indice_individu)]);
        check = chdir(path_temp); 
        assert_checktrue(check);

        // Dépendant du choix effectué pour l'apprentissage. 
        for indice_image = nombre_image_apprentissage + 1 : images_total_par_individu
            nombre_tests = nombre_tests + 1;
            resultat_reconaissance = reconaissance(individus(indice_individu), string(indice_image));
            if (resultat_reconaissance == %f) then
                nombre_erreurs = nombre_erreurs + 1;
            end
        end
        check = chdir('..');
        assert_checktrue(check);
    end
    taux_reussite = ((nombre_tests - nombre_erreurs) / nombre_tests ) * 100;
    disp(strcat(['Le taux de réussite pour des descripteurs de taille ' string(taille_descripteurs) ' et ' string(nombre_image_apprentissage) ' images par individus pour l apprentissage est de ' string(taux_reussite) '%' ]));
endfunction

clc;
//reconaissance(identifiant_individu_requete, photo_requete); // Faire un test unique
tests();
