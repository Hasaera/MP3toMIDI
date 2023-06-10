function note = convertirPitchEnNote(input)
    % Correspondance des fréquences aux notes
    A4 = 440;   % Fréquence du LA4
    AS4 = 466.16;  % Fréquence du LA#4
    BF3 = 233.08;  % Fréquence du SIb3
    B3 = 246.94;   % Fréquence du SI3
    
    % Conversion du input en note MIDI
    note = round(69 + 12*log2(input/A4));
    
    % Ajustement des notes spécifiques
    if input >= AS4
        note = note + 1;
    elseif input >= BF3 && input < B3
        note = note - 1;
    end
end
