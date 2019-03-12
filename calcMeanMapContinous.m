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

function [Maps, MeanSignal, MessMaps, MeanFPsignal] = calcMeanMapContinous(signal, mx, fPsignal, Fs, cut, w, fAstart, fAend, fAstep, fA, fP_b, Nboot)

    %% ---------------- PREPARE STRUCTURES ---------------------
    num = 0;
    Maps         = zeros(size(fA,2),floor(cut*Fs)*2+1);
    MessMaps     = zeros(Nboot,size(fA,2),floor(cut*Fs)*2+1);
    MeanSignal   = zeros(1,floor(cut*Fs)*2+1);
    MeanFPsignal = zeros(1,floor(cut*Fs)*2+1);

    %% ---------------- CALC MORLET WAVELET TF MAP ---------------------
    [map,~,~] = tf_cwt(hilbert(signal),fAstart,fAend+fAstep,Fs,w,fAstep,0);

    %% ------------- ADDING MAPS ALIGNED TO MAXIMA -------------- 
    Steps = 0;
    mx_tmp = mx;
    while ~isempty(mx_tmp)
        idx  = mx_tmp(1,1);
        Steps = Steps + 1;
        mx_tmp(mx_tmp<(idx+floor(2*cut*Fs))) = [];
    end
    
    while ~isempty(mx)
        
        idx  = mx(1,1);
        num = num + 1;
        mx(mx<(idx+floor(2*cut*Fs))) = [];
        
        Maps = Maps + map(:,idx-floor(cut*Fs):idx+floor(cut*Fs));
        MeanSignal = MeanSignal + signal(idx-floor(cut*Fs):idx+floor(cut*Fs));
        MeanFPsignal  = MeanFPsignal + fPsignal(idx-floor(cut*Fs):idx+floor(cut*Fs));

        for nb = 1:Nboot
            idxBoot = idx + floor((rand()*2-1.0)*Fs/mean(fP_b));
            while (idxBoot-floor(cut*Fs)<=0 || idxBoot+floor(cut*Fs) > size(map,2))
                idxBoot = idx + floor((rand()*2-1.0)*Fs/mean(fP_b));
            end
            MessMaps(nb,:,:) = squeeze(MessMaps(nb,:,:)) + map(:,idxBoot-floor(cut*Fs):idxBoot+floor(cut*Fs));
        end
    end

    %% ------------- NORMALIZATION -------------------
    if (num > 0)
        MeanSignal   = MeanSignal/num;
        MeanFPsignal = MeanFPsignal/num;
        MessMaps     = MessMaps/num;
        Maps         = Maps/num;
    end
    
end