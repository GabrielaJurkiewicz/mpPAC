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

function [mMVL, mMVL_boot] = calc_mMVL(Map, MessMap, MeanLowFreq, fA, Nboot, fP, Fs, deltaT, iter, Iter)

    mMVL      = zeros(1,length(fA));
    mMVL_boot = zeros(Nboot,length(fA));
    noZero = (sum(~(Map==0),2)>0);
    idx = find(noZero);
    
    for f = 1:sum(noZero)
        
        amp = Map(idx(f),:);
        num = length(amp);
        phase = angle(hilbert(MeanLowFreq));
        if (sum(amp>0)==0)
            k = zeros(size(amp));
        else
            k = calc_k(amp,fP,Fs,deltaT);
        end
        mMVL(1,idx(f)) = abs(sum(amp.*k.*exp(1i*phase)))/num;
        
        for nb = 1:Nboot
            ampB = reshape(squeeze(MessMap(nb,idx(f),:)),[1,length(phase)]);
            numB = length(ampB);
            if (sum(ampB>0)==0)
                kB = zeros(size(ampB));
            else
                kB = calc_k(ampB,fP,Fs,deltaT);
            end
            mMVL_boot(nb,idx(f)) = abs(sum(ampB.*kB.*exp(1i*phase)))/numB;
        end
        progressbar(( iter/Iter + f/(sum(noZero)*Iter)*1/2 + 1/(2*Iter)) * 100)
        
    end
end