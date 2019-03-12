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

function [MapT, MessMapT] = tresholdMaps(Map,MessMap,Nboot,p,iter,Iter)

    if prod(prod(isnan(Map)))==0
        MessMapT = zeros(size(MessMap));
        perc = zeros(1,size(Map,1));
        for f = 1:size(Map,1)
            tmp = MessMap(1:Nboot-1,f,:);
            perc(1,f) = prctile(tmp(:),p);
        end

        TR = repmat(perc',[1,size(Map,2)]);
        MapT = (Map>=TR);
        MapT = double(MapT).*(Map./(mean(Map,2)*ones(1,size(Map,2))));

        for nb = 1:Nboot
            perc = zeros(1,size(Map,1));
            for f = 1:size(Map,1)
                tmp = MessMap([1:nb-1,nb+1:end],f,:);
                perc(1,f) = prctile(tmp(:),p);
            end
            TR = repmat(perc',[1,size(Map,2)]);
            MessMapT(nb,:,:) = squeeze(MessMap(nb,:,:))>=TR;
            MessMapT(nb,:,:) = squeeze(double(MessMapT(nb,:,:))).*((squeeze(MessMap(nb,:,:))./(mean(squeeze(MessMap(nb,:,:)),2)*ones(1,size(squeeze(MessMap(nb,:,:)),2)))));
            progressbar(( iter/Iter + nb/(Nboot*Iter)*1/2 ) * 100)
        end
    else
        MapT = zeros(size(Map));
        MessMapT = zeros(size(MessMap));
    end
    
end