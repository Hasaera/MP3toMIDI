function detect_new_notes(file)

% Charger les données du fichier resultat.txt
data = dlmread(file);

% Extraire les colonnes du fichier
notes = data(:, 1);
intensites = round(data(:, 2));
durees = data(:, 3);

taille = 5; % Taille du groupe de trames
threshold = 0.5; % Seuil de différence pour détecter une nouvelle note

% Tableau final pour stocker les indices de début et de fin de notes, les intensités moyennes et les durées
note_starts = [];
note_ends = [];
intensites_moyennes = [];
durees_notes = [];

% Parcourir les trames à partir de la deuxième
for i = 2:length(notes)
    
    % Vérifier si la trame actuelle a une intensité supérieure à 1
    if intensites(i) > 1
        
        % Si la trame précédente avait une intensité de 1 ou si c'est la première trame, alors c'est le début d'une nouvelle note
        if intensites(i-1) == 1 || i == 2
            note_starts = [note_starts; notes(i)];
            intensites_moyennes = [intensites_moyennes; round(mean(intensites(max(i-taille, 1):i-1)))];
        end
        
    % Vérifier si la trame actuelle a une intensité de 1
    elseif intensites(i) == 1
        
        % Si la trame précédente avait une intensité supérieure à 1, alors c'est la fin d'une note
        if intensites(i-1) > 1
            note_ends = [note_ends; notes(i-1)];
        end
        
    end
end

% Vérifier si la dernière trame est une fin de note
if intensites(end) > 1
    note_ends = [note_ends; notes(end)];
end

% Calculer les durées des notes
for i = 1:length(note_starts)
    indice_debut = find(notes == note_starts(i), 1);
    indice_fin = find(notes == note_ends(i), 1);
    duree_note = sum(durees(indice_debut:indice_fin));
    durees_notes = [durees_notes; duree_note];
    durees_notes = max(durees_notes, 0.1 * (indice_fin - indice_debut + 1));
end

% Écrire les résultats dans le fichier resultatLisse.txt
resultat_lisse = [note_starts, intensites_moyennes, durees_notes];
dlmwrite('resultatLisse.txt', resultat_lisse, 'delimiter', '\t');

end
