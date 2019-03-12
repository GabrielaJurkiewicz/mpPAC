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

function plotFigure(x,y,z,clabel,directoryOut,savename)

    f = figure('visible','off');
    set(f,'DefaultAxesFontName', 'FreeSerif')
    set(f,'DefaultAxesFontSize', 10)
    
    imagesc(x,y,z)
    set(gca, 'Ydir', 'normal')
    set(gca,'TickDir','out')
    box off
    c = colorbar();
    ylabel(c,clabel)
    set(c,'TickDir','out')
    box off
    xlabel('Frequency for phase [Hz]')
    ylabel('Frequency for amplitude [Hz]')
    
    print(f, '-dpng', '-r300', [directoryOut savename '.png']);
    close(f);
    
end