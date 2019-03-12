%     mpPAC:
%     Calculates the modified Mean Vector Length - measure of
%     phase-amplitude coupling for given data.
% 
%     Usage:
%       >> pop_mpPAC_calc(EEG);          % pop_up window
%       >> mpPAC_calc(EEG,chan_fP,chan_fA,fPstart,fPend,fPstep,fAstart,fAend,fAstep,dirOut,type,nbCycles,w,deltaT,nbMPiter,Athresh,Nboot,p,pmMVL);
% 
%     Input:
%       - Channel number for phase signal (chan_fP): 
%         number of the EEG data channel which contains the low-frequency oscillation (signal for phase)
%         that provides the phase which is the modulator of the amplitude of the high-frequency 
%         oscillation (signal for amplitude)
% 
%       - Channel number for amplitude signal (chan_fA):
%         number of the EEG data channel that contains the high-frequency oscillation (signal for amplitude)
%         which amplitude is modulated by the phase of the low-frequency oscillation (signal for phase)
% 
%       - Directory for output (dirOut):
%         directory where the output images and MAT structures will be saved. This is also the localization 
%         from which the MP algorithm output BOOK structure will be loaded if the MP algorithm was performed 
%         before on the same data and with the same parameters: chan_fP, nbMPiter. If there already are the 
%         results of PAC analysis the new results will be saved with added prefix 'vX_', where 'X-1' is the 
%         number of existing sets of results 
% 
%       - Type of data (type):
%         type of EEG data to be processed. It should be 'continous' when the EEG data is not devided into 
%         epochs or when the existing epochs are supposed to give separate results. It should be 'event_related' 
%         when the epochs are in fact subsequent trials and they are supposed to give one averaged result
% 
%       - Frequency for phase start (fPstart):
%         the beginning of the examinated range of frequencies for phase (frequencies of low-frequency oscillation 
%         with modulating phase) 
% 
%       - Frequency for phase stop (fPend):
%         the end of the examinated range of frequencies for phase (frequencies of low-frequency oscillation  
%         with modulating phase)
% 
%       - Frequency for phase step (fPstep):
%         the step between the beginning and end of examinated range of frequencies for phase. Each frequency 
%         for phase f_P is in fact a bin ranging from f_P-fPstep/2 to f_P+fPstep/2
% 
%       - Frequency for amplitude start (fAstart):
%         the beginning of the examinated range of frequencies for amplitude (frequencies of high-frequency oscillation
%         with modulated amplitude)
% 
%       - Frequency for amplitude stop (fAend):
%         the end of the examinated range of frequencies for amplitude (frequencies of high-frequency oscillation
%         with modulated amplitude). It can not be bigger than sampling frequency/2
% 
%       - Frequency for amplitude step (fAstep):
%         the step between the beginning and end of examinated range of frequencies for amplitude. Each frequency 
%         for amplitude f_A is in fact a bin ranging from f_A-fAstep/2 to f_A+fAstep/2
% 
%       - Number of low-freq cycles (nbCycles):
%         number of cycles of low-frequency oscillation that will fit in sections that will be averaged (indirect 
%         way of specifying the time length of sections). Averaged sections of time-frequency map and signal
%         will be a basis to determine the coupling. nbCycles=2 is the minimum, we suggest 3 
% 
%       - Maximal number of MP iterations (nbMPiter):
%         limit of number of MP iterations if the energy explained by fitted by MP structures is less than 99%. 
%         We set it to be 10 * length of the signal epoch in [s]. But it can be lowered (we use MP to find highly 
%         energetic low-frequency structures that sholud be fitted in the first few iterations)
% 
%       - Number of surrogate data repetition (Nboot):
%         number of repetitions while producing the surrogate data. We set the default value to 200
% 
%       - Wavelet number (number of visible cycles in one burst) (w):
%         number of high-frequency cycles attributable to one transient burst of this frequency. For example, 
%         in the analysis of data related to sequential memory, considering the Lisman model (Lisman, 2005), 
%         it can be set at the level of the number of objects stored in the memory. The default value is set to 5
% 
%       - Fraction of mean low-freq amplitude as threshold for detecting maxima (Athresh):
%         amplitude threshold for low-frequency oscillation maxima to be included in analysis. It is expressed as 
%         the fraction of the mean amplitude of signal for phase (data from channel chan_fP)
% 
%       - Fraction of low-freq cycle as permissible inaccuracy of synchronization (deltaT):
%         permissible inaccuracy of synchronization, meaning the higher limit of deviation from periodicity of 
%         exactly one low-frequency. It is expressed as a fraction of low-freq cycle. Default value equals 0.1
% 
%       - Percentile of surrogate data power distribution (p):
%         threshold (separate for each frequency for amplitude fA) for detecting the regions of averaged 
%         time-frequency map that are significantly augmented in respect to surrogate data TF maps. It is expressed 
%         as the percentile of power distribution of surrogate data TF maps for each fA
% 
%       - Percentile of surrogate data mMVL distribution (pmMVL):
%         threshold for detecting statistically significant values od mMVL. It is expressed as percentile of 
%         distribution of maximal mMVL values from each comodulogram for surrogate data.
% 
% 
%     Output:
% 
%       All output files are saved in directory specified as dirOut, and {X} below is an identifier of results.
% 
%       - v{X}_mpPAC_config.mat
%         matlab structure with values of all parameters of PAC analysis and MP decomposition described above
% 
%       - v{X}_mpPAC_results.mat
%         matlab file containing:
%               * fA - vector of frequencies for amplitude
%               * fP - vector of frequencies for phase
%               * mMVL - comodulogram array without extreme values statistic
%               * mMVL_afterStat - comodulogram array after extreme values statistic
%               * results{fP}Hz - structure with arrays and vectors used to produce the resulting images for each fP:
%                       ** Map - averaged time-frequency map
%                       ** MapT - thresholded and normalized averaged time-frequency map
%                       ** time - vector of time
%                       ** MeanSignal - averaged signal for amplitude
%                       ** MeanLowFreg - averaged MP decomposition
% 
%       - series of images v{X}_mpPAC_results{fP}Hz.png (where fP is a frequency from range of frequencies for phase)
%         images containing results of intermediate steps for each fP. The upper plot depicts the averaged 
%         time-frequency map, the middle one presents the thresholded and normalized averaged
%         time-frequency map. Below you can observe the timecourse of averaged signal for amplitude (blue) 
%         and averaged MP decomposition (black)
% 
%       - v{X}_mpPAC_comodulogram.png
%         image of comodulogram without the extreme values statistic
% 
%       - v{x}_mpPAC_comodulogram_statistic.png
%         image of comodulogram after the extreme values statistic
% 
% 
%     Example:
%     There is an examplary program (Test.m) and data set (TestData.set) that show the results for simulated signal 
%     that consists of 6 Hz sinus with superimposed bursts of 77 Hz oscillation located just before the top of each 
%     sinus cycle with added white noise. This synthetic signal represents the PAC where phase of 6 Hz oscillation 
%     modulates the amplitude of 77 Hz osillation. After running the program the output images and files will be produced. 
%     In the picture v1_mpPAC_comodulogram_statistic.png you can see that the algorithm correctly detects significant 
%     coupling for frequency for phase = 6 Hz and for the range of frequencies for amplitude around 77 Hz. In the picture 
%     v1_mpPAC_results6Hz.png we present the intermediate results for fP=6 Hz specifically and you can observe that the 
%     augmented regions in the middle time-frequency map indicate the phase of low-frequency oscillation (bottom plot, 
%     black line) which is just before the top. That is exactly the PAC that was simulated.


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


function [LASTCOM] = pop_mpPAC_calc(EEG , varargin)
    
    

    LASTCOM = [];
        
    if nargin < 1
        help pop_mpPAC_calc;
        return;
    end
    
    if isempty(EEG.data)
        error('Cannot process empty dataset');
    end
    
    
    defaults.chan_fP  = 1;
    defaults.chan_fA  = 1;
    defaults.dirOut   = EEG.filepath;
    defaults.type     = 'continous';
    defaults.fPstart  = 4;
    defaults.fPend    = 8;
    defaults.fPstep   = 1;
    defaults.fAstart  = 20;
    defaults.fAend    = EEG.srate/2;
    defaults.fAstep   = 5;

    defaults.nbCycles = 3;
    defaults.nbMPiter = floor(size(EEG.data,2)/EEG.srate*10);
    defaults.Athresh  = 0.01;
    defaults.Nboot    = 200;
    defaults.w        = 5;
    defaults.deltaT   = 0.1; 
    defaults.p        = 95;
    defaults.pmMVL    = 95;
    
    if nargin < 11

        if (sum(cellfun('isempty',varargin))>0)
            disp 'There can not be empty parameters -- aborting';
            return;
        end
        
        title_string = 'Detects phase-amplitude coupling by calculating modified Mean Vector Length -- pop_mpPAC_calc()';
        geometry = { 1 [1 1] [1 1] [1 1] [1 1] 1 1 [1 1] [1 1] [1 1] [1 1] [1 1] [1 1] 1 1 [1 1] [1 1] [1 1] [1 1] [1 1] [1 1] [1 1] [1 1]};
        geomvert = [1 1 1 1 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];

        uilist = { ...
         { 'style', 'text', 'string', 'Data info: ', 'fontweight', 'bold'}, ...
         { 'style', 'text', 'string', 'Channel number for phase signal: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.chan_fP), 'tag', 'chan_fP'}, ...
         { 'style', 'text', 'string', 'Channel number for amplitude signal: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.chan_fA), 'tag', 'chan_fA'}, ...
         { 'style', 'text', 'string', 'Directory for output: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.dirOut), 'tag', 'dirOut'}, ...
         { 'style', 'text', 'string', 'Type of data: ' }, ...
         { 'style', 'listbox', 'string', 'continous|event related' 'tag' 'type' }, ...
         { }, ...
         { 'style', 'text', 'string', 'Analysis parameters: ', 'fontweight', 'bold'}, ...
         { 'style', 'text', 'string', 'Frequency for phase start: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.fPstart), 'tag', 'fPstart'}, ...
         { 'style', 'text', 'string', 'Frequency for phase stop: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.fPend), 'tag', 'fPend'}, ...
         { 'style', 'text', 'string', 'Frequency for phase step: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.fPstep), 'tag', 'fPstep'}, ...
         { 'style', 'text', 'string', 'Frequency for amplitude start: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.fAstart), 'tag', 'fAstart'}, ...
         { 'style', 'text', 'string', 'Frequency for amplitude stop: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.fAend), 'tag', 'fAend'}, ...
         { 'style', 'text', 'string', 'Frequency for amplitude step: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.fAstep), 'tag', 'fAstep'}, ...
         { }, ...
         { 'style', 'text', 'string', 'Optional parameters: ', 'fontweight', 'bold'}, ...
         { 'style', 'text', 'string', 'Number of low-freq cycles: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.nbCycles), 'tag', 'nbCycles'}, ...
         { 'style', 'text', 'string', 'Maximal number of MP iterations: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.nbMPiter), 'tag', 'nbMPiter'}, ...
         { 'style', 'text', 'string', 'Number of surrogate data repetition: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.Nboot), 'tag', 'Nboot'}, ...
         { 'style', 'text', 'string', 'Wavelet number (number of visible cycles in one burst): ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.w), 'tag', 'w'}, ...
         { 'style', 'text', 'string', 'Fraction of mean low-freq amplitude as threshold for detecting maxima: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.Athresh), 'tag', 'Athresh'}, ...
         { 'style', 'text', 'string', 'Fraction of low-freq cycle as permissible inaccuracy of synchronization: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.deltaT), 'tag', 'deltaT'}, ...
         { 'style', 'text', 'string', 'Percentile of surrogate data power distribution: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.p), 'tag', 'p'}, ...
         { 'style', 'text', 'string', 'Percentile of surrogate data mMVL distribution: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.pmMVL), 'tag', 'pmMVL'}, ...
         };
     
        [~, ~, err params] = inputgui( 'geometry', geometry, 'geomvert', geomvert, 'uilist', uilist, 'helpcom', 'pophelp(''pop_pac_calc'');', 'title' , title_string);
        
        if isempty(params) == 1
            return;
        end
        
        try
            params.chan_fP  = str2num(params.chan_fP);
            params.chan_fA  = str2num(params.chan_fA);
            params.dirOut   = params.dirOut;
            switch params.type
                case 1
                	params.type = 'continous';
                case 2
                    params.type = 'event_related';
            end
            params.fPstart  = str2num(params.fPstart);
            params.fPend    = str2num(params.fPend);
            params.fPstep   = str2num(params.fPstep);
            params.fAstart  = str2num(params.fAstart);
            params.fAend    = str2num(params.fAend);
            params.fAstep   = str2num(params.fAstep);

            params.nbCycles = str2num(params.nbCycles);
            params.nbMPiter = str2num(params.nbMPiter);
            params.Athresh  = str2num(params.Athresh);
            params.Nboot    = str2num(params.Nboot);
            params.w        = str2num(params.w) ;
            params.deltaT   = str2num(params.deltaT); 
            params.p        = str2num(params.p);
            params.pmMVL    = str2num(params.pmMVL);

        catch ME1
            throw(ME1);
        end
        
    elseif nargin == 11
        % mpPAC_calc(EEG,chan_fP,chan_fA,fPstart,fPend,fPstep,fAstart,fAend,fAstep,dirOut,type);
        
        if (sum(cellfun('isempty',varargin))>0)
            disp 'There can not be empty parameters -- aborting';
            return;
        end
        
        try
            params.chan_fP  = varargin{1};
            params.chan_fA  = varargin{2};
            params.fPstart  = varargin{3};
            params.fPend    = varargin{4};
            params.fPstep   = varargin{5};
            params.fAstart  = varargin{6};
            params.fAend    = varargin{7};
            params.fAstep   = varargin{8};
            params.dirOut   = varargin{9};
            params.type     = varargin{10};
            
            params.nbCycles = defaults.nbCycles;
            params.w        = defaults.w;
            params.deltaT   = defaults.deltaT;
            params.nbMPiter = defaults.nbMPiter;
            params.Athresh  = defaults.Athresh;
            params.Nboot    = defaults.Nboot;
            params.p        = defaults.p;
            params.pmMVL    = defaults.pmMVL;
            
        catch ME1
            throw(ME1);
        end
        
    elseif nargin == 12
        % mpPAC_calc(EEG,chan_fP,chan_fA,fPstart,fPend,fPstep,fAstart,fAend,fAstep,dirOut,type,nbCycles);
        
        if (sum(cellfun('isempty',varargin))>0)
            disp 'There can not be empty parameters -- aborting';
            return;
        end
        
        try
            params.chan_fP  = varargin{1};
            params.chan_fA  = varargin{2};
            params.fPstart  = varargin{3};
            params.fPend    = varargin{4};
            params.fPstep   = varargin{5};
            params.fAstart  = varargin{6};
            params.fAend    = varargin{7};
            params.fAstep   = varargin{8};
            params.dirOut   = varargin{9};
            params.type     = varargin{10};
            params.nbCycles = varargin{11};
            
            params.w        = defaults.w;
            params.deltaT   = defaults.deltaT; 
            params.nbMPiter = defaults.nbMPiter;
            params.Athresh  = defaults.Athresh;
            params.Nboot    = defaults.Nboot;
            params.p        = defaults.p;
            params.pmMVL    = defaults.pmMVL;
        catch ME1
            throw(ME1);
        end
    
    elseif nargin == 13
        % mpPAC_calc(EEG,chan_fP,chan_fA,fPstart,fPend,fPstep,fAstart,fAend,fAstep,dirOut,type,nbCycles,w);

        if (sum(cellfun('isempty',varargin))>0)
            disp 'There can not be empty parameters -- aborting';
            return;
        end
        
        try
            params.chan_fP  = varargin{1};
            params.chan_fA  = varargin{2};
            params.fPstart  = varargin{3};
            params.fPend    = varargin{4};
            params.fPstep   = varargin{5};
            params.fAstart  = varargin{6};
            params.fAend    = varargin{7};
            params.fAstep   = varargin{8};
            params.dirOut   = varargin{9};
            params.type     = varargin{10};
            params.nbCycles = varargin{11};
            params.w        = varargin{12};
            
            params.deltaT   = defaults.deltaT; 
            params.nbMPiter = defaults.nbMPiter; 
            params.Athresh  = defaults.Athresh;
            params.Nboot    = defaults.Nboot;
            params.p        = defaults.p;
            params.pmMVL    = defaults.pmMVL;
        catch ME1
            throw(ME1);
        end
    
    elseif nargin == 14
        % mpPAC_calc(EEG,chan_fP,chan_fA,fPstart,fPend,fPstep,fAstart,fAend,fAstep,dirOut,type,nbCycles,w,deltaT);

        if (sum(cellfun('isempty',varargin))>0)
            disp 'There can not be empty parameters -- aborting';
            return;
        end
        
        try
            params.chan_fP  = varargin{1};
            params.chan_fA  = varargin{2};
            params.fPstart  = varargin{3};
            params.fPend    = varargin{4};
            params.fPstep   = varargin{5};
            params.fAstart  = varargin{6};
            params.fAend    = varargin{7};
            params.fAstep   = varargin{8};
            params.dirOut   = varargin{9};
            params.type     = varargin{10};
            params.nbCycles = varargin{11};
            params.w        = varargin{12};
            params.deltaT   = varargin{13};

            params.nbMPiter = defaults.nbMPiter;
            params.Athresh  = defaults.Athresh;
            params.Nboot    = defaults.Nboot;
            params.p        = defaults.p;
            params.pmMVL    = defaults.pmMVL;
        catch ME1
            throw(ME1);
        end
        
    elseif nargin == 15
        % mpPAC_calc(EEG,chan_fP,chan_fA,fPstart,fPend,fPstep,fAstart,fAend,fAstep,dirOut,type,nbCycles,w,deltaT,nbMPiter);

        if (sum(cellfun('isempty',varargin))>0)
            disp 'There can not be empty parameters -- aborting';
            return;
        end
        
        try
            params.chan_fP  = varargin{1};
            params.chan_fA  = varargin{2};
            params.fPstart  = varargin{3};
            params.fPend    = varargin{4};
            params.fPstep   = varargin{5};
            params.fAstart  = varargin{6};
            params.fAend    = varargin{7};
            params.fAstep   = varargin{8};
            params.dirOut   = varargin{9};
            params.type     = varargin{10};
            params.nbCycles = varargin{11};
            params.w        = varargin{12};
            params.deltaT   = varargin{13};
            params.nbMPiter = varargin{14};
            
            params.Athresh  = defaults.Athresh;
            params.Nboot    = defaults.Nboot;
            params.p        = defaults.p;
            params.pmMVL    = defaults.pmMVL;
        catch ME1
            throw(ME1);
        end
    
    elseif nargin == 16
        % mpPAC_calc(EEG,chan_fP,chan_fA,fPstart,fPend,fPstep,fAstart,fAend,fAstep,dirOut,type,nbCycles,w,deltaT,nbMPiter,Athresh);

        if (sum(cellfun('isempty',varargin))>0)
            disp 'There can not be empty parameters -- aborting';
            return;
        end
        
        try
            params.chan_fP  = varargin{1};
            params.chan_fA  = varargin{2};
            params.fPstart  = varargin{3};
            params.fPend    = varargin{4};
            params.fPstep   = varargin{5};
            params.fAstart  = varargin{6};
            params.fAend    = varargin{7};
            params.fAstep   = varargin{8};
            params.dirOut   = varargin{9};
            params.type     = varargin{10};
            params.nbCycles = varargin{11};
            params.w        = varargin{12};
            params.deltaT   = varargin{13};
            params.nbMPiter = varargin{14};
            params.Athresh  = varargin{15};
            
            params.Nboot    = defaults.Nboot;
            params.p        = defaults.p;
            params.pmMVL    = defaults.pmMVL;
        catch ME1
            throw(ME1);
        end
        
    elseif nargin == 17
        % mpPAC_calc(EEG,chan_fP,chan_fA,fPstart,fPend,fPstep,fAstart,fAend,fAstep,dirOut,type,nbCycles,w,deltaT,nbMPiter,Athresh,Nboot);

        if (sum(cellfun('isempty',varargin))>0)
            disp 'There can not be empty parameters -- aborting';
            return;
        end
        
        try
            params.chan_fP  = varargin{1};
            params.chan_fA  = varargin{2};
            params.fPstart  = varargin{3};
            params.fPend    = varargin{4};
            params.fPstep   = varargin{5};
            params.fAstart  = varargin{6};
            params.fAend    = varargin{7};
            params.fAstep   = varargin{8};
            params.dirOut   = varargin{9};
            params.type     = varargin{10};
            params.nbCycles = varargin{11};
            params.w        = varargin{12};
            params.deltaT   = varargin{13};
            params.nbMPiter = varargin{14};
            params.Athresh  = varargin{15};
            params.Nboot    = varargin{16};
            
            params.p        = defaults.p;
            params.pmMVL    = defaults.pmMVL;
        catch ME1
            throw(ME1);
        end
        
    elseif nargin == 18
        % mpPAC_calc(EEG,chan_fP,chan_fA,fPstart,fPend,fPstep,fAstart,fAend,fAstep,dirOut,type,nbCycles,w,deltaT,nbMPiter,Athresh,Nboot,p);

        if (sum(cellfun('isempty',varargin))>0)
            disp 'There can not be empty parameters -- aborting';
            return;
        end
        
        try
            params.chan_fP  = varargin{1};
            params.chan_fA  = varargin{2};
            params.fPstart  = varargin{3};
            params.fPend    = varargin{4};
            params.fPstep   = varargin{5};
            params.fAstart  = varargin{6};
            params.fAend    = varargin{7};
            params.fAstep   = varargin{8};
            params.dirOut   = varargin{9};
            params.type     = varargin{10};
            params.nbCycles = varargin{11};
            params.w        = varargin{12};
            params.deltaT   = varargin{13};
            params.nbMPiter = varargin{14};
            params.Athresh  = varargin{15};
            params.Nboot    = varargin{16};
            params.p        = varargin{17};
            
            params.pmMVL    = defaults.pmMVL;
        catch ME1
            throw(ME1);
        end
    
    elseif nargin == 19
        % mpPAC_calc(EEG,chan_fP,chan_fA,fPstart,fPend,fPstep,fAstart,fAend,fAstep,dirOut,type,nbCycles,w,deltaT,nbMPiter,Athresh,Nboot,p,pmMVL);

        if (sum(cellfun('isempty',varargin))>0)
            disp 'There can not be empty parameters -- aborting';
            return;
        end
        
        try
            params.chan_fP  = varargin{1};
            params.chan_fA  = varargin{2};
            params.fPstart  = varargin{3};
            params.fPend    = varargin{4};
            params.fPstep   = varargin{5};
            params.fAstart  = varargin{6};
            params.fAend    = varargin{7};
            params.fAstep   = varargin{8};
            params.dirOut   = varargin{9};
            params.type     = varargin{10};
            params.nbCycles = varargin{11};
            params.w        = varargin{12};
            params.deltaT   = varargin{13};
            params.nbMPiter = varargin{14};
            params.Athresh  = varargin{15};
            params.Nboot    = varargin{16};
            params.p        = varargin{17};
            params.pmMVL    = varargin{18};
            
        catch ME1
            throw(ME1);
        end
        
    else
        disp 'Not enough input parameters -- aborting';
        return;
    end
    
    if ((length(size(EEG.data))<3)&&(strcmp(params.type,'event_related')))
        disp('Compulsory change of "type" to continous')
        params.type = defaults.type;
    end
    
    if (params.fAend>EEG.srate/2)
        disp('Compulsory change of "Frequency for amplitude stop" to Nyquista frequency')
        params.fAend = defaults.fAend;
    end
    
    try
        
        mpPAC_calc(EEG,params.chan_fP,params.chan_fA,params.fPstart,params.fPend,params.fPstep,params.fAstart,params.fAend,params.fAstep, ...
                 params.dirOut,params.type,params.nbCycles,params.w,params.deltaT,params.nbMPiter,params.Athresh,params.Nboot,params.p,params.pmMVL);

             
        tmpstring = '[LASTCOM] = pop_mpPAC_calc(EEG';
        
        fields = fieldnames(params);
        for ind1 = 1:numel(fields)
            tmpstring = [tmpstring , ' , ' , num2str(params.(fields{ind1}))]; 
        end
        LASTCOM = [tmpstring , ');'];
        
    catch ME1
        throw(ME1);
    end
    
    disp 'Done!'
end
