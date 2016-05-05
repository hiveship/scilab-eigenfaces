// TODO: Travail en cours !
function image = photoWebcam()
    webcam = camopen();
    image = avireadframe(webcam); // Prends un instantannée de l'image webcam
    afficherImage(image);
    aviclose(webcam);
endfunction

clc;
photoWebcam;
