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

function [k] = calc_k(amp,theta,Fs,deltaT)
    
    mask = (amp>0);
    k = zeros(size(amp));
    T  = floor(Fs/theta);
    TT = floor(deltaT/2*T);
    IDX = 1:1:size(amp,2);
    
    for t = 1:size(amp,2)
        back = (t:-T:0);
        forward = (t:T:size(amp,2));
        all = unique([back forward]);
        all_delta = zeros(size(all));
        for a = 1:length(all)
            idx = (IDX>=(all(a)-TT))&(IDX<=(all(a)+TT));
            all_delta(a) = (sum(mask(idx)))>0;
        end
        k(1,t) = ((sum(all_delta))>=2);
    end

end