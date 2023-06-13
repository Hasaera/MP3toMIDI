%Pour établir le temps de calcul : 
tic
% Lire le fichier audio
[y0, Fs] = audioread("./harry.wav");
Duration=1/Fs;
y = y0(:,1);%Suppression de la voie de droite qui comporte du bruit très faible.

%% Normalisation du signal audio
%y = y / max(abs(y));
Fc = 300; % 

% Créer un filtre passe-bas avec la fonction butter
[b, a] = butter(6, Fc/(Fs/2));

% Appliquer le filtre à votre signal avec la fonction filter
y = filter(b, a, y);
plot(y)

%% On restera dans le domaine temporel 
%% Ré-échantillonage : 
% Appliquer un filtre anti-repliement de fréquence
%facteur_decim = 4;
%fc = Fs/facteur_decim;
%[b, a] = butter(8, fc / (Fs / 2), 'low');
%yFiltered = filter(b, a, y);

% Décimation par un facteur
%yDownsampled = downsample(yFiltered, facteur_decim);
%TailleY = length(yDownsampled)
% Diviser le signal en trames de durée frameDuration.
%frameSize = round(frameDuration * Fs / facteur_decim)
% = Nombre de points d'une frame
numFrames = length(y);
% = Nombre de frames
%frames = reshape(yDownsampled(1:numFrames*frameSize), frameSize, numFrames);

% = Tableau de frames : Division du signal window en fenêtres

frameDuration = length(y)/(Fs); %Durée d'une trame en s.


%% Tableaux à remplir 
notes = zeros(numFrames, 1);%matrice colone de taille frames de zéros
volumes = zeros(numFrames, 1);%matrice colone de taille frames de zéros
durations = frameDuration*ones(numFrames, 1);%matrice colone de taille frames de frameDuration*ones 
bufferSize = 2; %Taille d'un tampon

%for i=1:numFrames-bufferSize
    
  % Extraire 4 trames à partir de la i-ème trame
  % buffer = frames(:, i:i+bufferSize-1); 
  % = Tableau de frames de taille controlée.
  %buffer = buffer(:); % Vecteur colones de frames.
  %TailleBuffer = length(buffer);
    
    %volumes(i) = round(mean(abs(buffer))*1000);
    %volumes(i) = uint8(max(min(volumes(i), 99), 1)); % Ajuste les valeurs entre 1 et 99.

    
    % Zero-padding : le zero padding permet d'améliorer a résolution de la
    % FFT, il ne sera donc pas utile dans notre cas 
    %paddingFactor = 10; % Proportionnel au nombre de zéros à ajouter
    % bufferPadded = [buffer; zeros(length(buffer)* paddingFactor, 1)];

 %% Cette partie du code n'a pas de raison d'être car l'AMDF se calcule sur
 %le signal lui même et pas sur son spectre en fréquence

    % Calculer le spectre des trames avec padding
    %nfft = length(bufferPadded); %Nombre de points de la FFT
    %spec = fft(bufferPadded, nfft);

  %%Ici également le fenêtrage s'applique après le zero padding 
    %spec_filtre = spec.*blackman(length(spec));
    %spec_filtre = spec.*blackman(length(spec));
    %TailleSpecFilt = length(spec_filtre);

%% Pas de seuil à appliquer

   %Application d'un seuil pour enlever le bruit à threshold
   % threshold = 0.000;
   % buffer_thresholded = spec_filtre;
   % buffer_thresholded(buffer_thresholded < threshold) = threshold;
   % taille_buff_pad = round(length(bufferPadded)/2);
   %f = (-taille_buff_pad:taille_buff_pad) / nfft * Fs / paddingFactor;
   %f = 0:length()
   % bufferPaddedTrimmed = spec(length(spec)/2+1:end);
   %f = 0:fc/nfft:fc-1;

    %% Partie AMDF :

    % Paramètres : Ces informations sont laissée en guise d'informations
    T0_max = 0.004; %periode du signal maximal
    T0_min = 0.0005; %periode du dignal minimale

    %f0_min = 247; % fréquence minimale pour la recherche de pitch = Si 2
    %f0_max = 1760; % fréquence maximale pour la recherche de pitch = La 5

    %découper en trame
    taille = length(y);
   hopLenght = taille;%chevauchement
   amdf = zeros(1, taille); 
   Window = round(T0_max * Fs); 

    for j = Window+1:length(y)-Window
        Windowedsignal =y(j-Window+1:j).*hamming(Window);
        for i = 1:Window
            amdf(j) = amdf(j) + abs(Windowedsignal(i) - y(j));
        end
        amdf(j) = amdf(j)/Window;
    end

    %% Recherche de la valeur minimale de l'amdf
    [minima, indices,width,hauteur] = findpeaks(-amdf);%minima contient la valeur des minima trouvés

    %on calcule les différentes fréquences
   % minima = -minima;
   for n = 1:length(width)
       if( width(n)> 22) && (width(n)<200 )
         period = width(n) / Fs;
         notes(n) = 1 / period;
       end
   end 
    
% Enregistrement des résultats dans un fichier texte
fid = fopen('resultat.txt', 'w');
for i = 1:length(indices)
    start = max(1,indices(i)- Window);
    volumes(i) = hauteur(i) ;
    
    if(notes(i)>0)
    pitch = convertirPitchEnNote(notes(i)); 
    durations(i)=width(i)/(Fs);
    fprintf(fid, '%d\t%d\t%f\n', round(pitch), volumes(i)*100000, durations(i));
    end

end
fclose(fid);
detect_new_notes('./resultat.txt');
open("./resultat.txt")
%fin du calcul :
toc
