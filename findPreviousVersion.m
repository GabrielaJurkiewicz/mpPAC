%    Phase-amplitude coupling detection MATLAB plugin
%
%    Copyright (C) 2019 Gabriela Jurkiewicz
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

%    Gabriela Jurkiewicz <gabriela.j.jurkiewicz@gmail.com>

function [ID,MP_ID] = findPreviousVersion(dirOut,dataHash,chan_fP,nbMPiter)

ID = 1;
MP_ID = 0;
all = dir([dirOut 'v*_mpPAC_config.mat']);

if ~isempty(all)
    all = {all(:).name};
    ID = 0;
    for i = 1:length(all)
        a = all{i};
        a = strsplit(a,'_');
        a = strsplit(a{1},'v');
        a = str2num(a{2});
        if a>ID
           ID = a; 
        end
        load([dirOut 'v' num2str(a) '_mpPAC_config.mat'])
        if (strcmp(config.EEGdataHash,dataHash)&&(config.chan_fP==chan_fP)&&(config.nbMPiter==nbMPiter))
            MP_ID = a;
        end
    end
    ID = ID+1;
end

MP_ID = num2str(MP_ID);
ID = num2str(ID);

end 