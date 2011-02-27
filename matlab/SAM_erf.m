function SAM_erf(pat,source,groups,filt,trigVals,startt,endt)
% lists folders with data at the given path (linux), fixes visual trigger for SAM
% analysis.
% groups is a matrix of sbjects in the first row. zeros on the second row
% mean- do not analyse.
% load groups;
% pat='/media/disk/Sharon/MEG/Experiment3/Source_localization';
% filt is text for bandpass: filt='0.1 50';
%% 
cd(pat)
!ls > ls.txt
subjects=importdata('ls.txt')';
!rm ls.txt
if isempty(groups)
    groups=subjects;
    groups(2,:)=1;
end
filtstr=str2num(filt);
%% 
folder='';
for sub=1:size(subjects,2)
    group=groups(2,find(groups(1,:)==(subjects(sub))));
    if group>0;
        folder=num2str(subjects(sub));
        %eval(['!SAMcov -r ',folder,' -d ',source,' -m Global -f "',filt,'" -v'])
        %eval(['!SAMwts -r ',folder,' -d ',source,' -c Global,',num2str(filt(1,1)),'-',num2str(filt(1,2)),'Hz -C -Z -x "-10 10" -y "-9 9" -z "0 14" -s 0.5 -v'])
        for con=1:(size(trigVals,2))
            eval(['!SAMerf -r ',folder,' -d ',source,' -w Global,',...
                num2str(filtstr(1,1)),'-',num2str(filtstr(1,2)),'Hz,Global,ECD -m ',...
                num2str(trigVals(1,con)),' -f "',filt,'" -v -t "',num2str(startt),' ', num2str(endt),...
                '" -b "',num2str(startt-endt),' 0" -z 3']);
        end
        display(num2str(sub))
    end
end
