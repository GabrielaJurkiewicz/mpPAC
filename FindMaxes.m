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

function [Maxes,LowFreq] = FindMaxes(BOOK, chan_fP, Fs, fP_bins, LimitAmp)

    trialNb    = size(BOOK.reconstruction,1);
    parameters = BOOK.parameters(:,chan_fP);
    Maxes = {};
    LowFreq = {};
    
    for Idx = 1:size(fP_bins,2)
        
        fP_b = fP_bins(:,Idx)';
        Mx = {};
        LF = {};
        
        for trial = 1:trialNb
            
            IdxF = (parameters(trial).frequencies(:,1) > fP_b(1)) & (parameters(trial).frequencies(:,1) < fP_b(2));
            IdxW = parameters(trial).widths(:,1) > 1/fP_b(2);
            IdxA = parameters(trial).atomAmplitudes(:,1) > LimitAmp;
            idx  = find((IdxF & IdxW) & IdxA)' ;
            
            env = [];
            IdxMax = [];
            if ~isempty(idx)
                env = squeeze(sum(real(BOOK.reconstruction(trial,chan_fP,idx,:)),3))';
                [~,IdxMax] = findpeaks(double(env),'MINPEAKDISTANCE',floor((0.5/mean(fP_b))*Fs),'MINPEAKHEIGHT', LimitAmp/2.);
            end
            
            Mx{trial} = IdxMax;
            LF{trial} = env;
            
        end
        
        Maxes{Idx}   = Mx;
        LowFreq{Idx} = LF;
        
    end
    
end