function [ok] = Trig2mark(varargin)
% Input - pairs of MarkerName, and Markervector.
% the function create a mrk file in the correct format.

% O.F September 2011

    % input Check
    if mod (nargin,2) == 1
        ok = 0;
        error ('Input Error- ')
    end
    
    % Open file
    fileID = fopen('MarkerFile.mrk','w');
    Markers=nargin/2;
    fprintf(fileID ,'NUMBER OF MARKERS:\n%d\n',Markers);
    
    i=1;
    while i <= nargin
        % Marker's name
        fprintf(fileID ,'\nNAME:\n');
        name = varargin{i};
        fprintf(fileID ,'%s\n',name);
        
        % Marker's data
        i = i+1;
        vec = varargin{i};
        
        fprintf(fileID ,'NUMBER OF SAMPLES:\n');
        fprintf(fileID ,'%d\n',size(vec,2));
        fprintf(fileID ,'TRIAL NUMBER	TIME FROM SYNCH POINT (in sec.)\n');
        
        % Print trigers in format
        for j = 1:size(vec,2)
            fprintf(fileID ,'+0\t+%f\n',vec(j));
        end
        i = i+1;
    end

    fclose(fileID);
    ok = 1;
end
