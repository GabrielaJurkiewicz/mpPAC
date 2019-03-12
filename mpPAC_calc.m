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

function [] = mpPAC_calc(EEG,chan_fP,chan_fA,fPstart,fPend,fPstep,fAstart,fAend,fAstep,dirOut,type,nbCycles,w,deltaT,nbMPiter,Athresh,Nboot,p,pmMVL)

    if ((length(size(EEG.data))<3)&&(strcmp(type,'event_related')))
        disp('Compulsory change of "type" to continous')
        type = 'continous';
    end
    
    if (fAend>EEG.srate/2)
        disp('Compulsory change of "Frequency for amplitude stop" to Nyquista frequency')
        fAend = EEG.srate/2;
    end
    
    %% -------------------------- PREPARE VARIABLES -------------------------
    margines = w/fAstart;
    fP = fPstart:fPstep:fPend;
    fP_bins = zeros(2,length(fP));
    fP_bins(1,:) = fP-fPstep/2;
    fP_bins(2,:) = fP+fPstep/2;
    [status,message,~] = mkdir(dirOut);
    [ID,MP_ID] = findPreviousVersion(dirOut,DataHash(EEG.data,struct('Input','array')),chan_fP,nbMPiter);

    %% ------------------------- MP CALCULATE/LOAD --------------------------
    if (str2num(MP_ID) > 0)
        load([dirOut 'v' MP_ID '_mpPAC_MPbook.mat'])
        save([dirOut 'v' ID '_mpPAC_MPbook.mat'],'BOOK','-v7.3');
    else    
        disp('-----------------------MP algorithm calculations----------------------')
        minS    = 3;        
        dE      = 0.01;     
        Energy  = 0.99;        
        iterNb  = nbMPiter;    
        maxS    = size(EEG.data,2);
        nfft    = calcNFFT(EEG.srate);
        epochNb = (1:size(EEG.data,3));  
        [BOOK,~] = pop_mp_calc(EEG, chan_fP, epochNb, minS, maxS, dE, Energy, iterNb, nfft, 0, 0);
        save([dirOut 'v' ID '_mpPAC_MPbook.mat'],'BOOK','-v7.3');
    end

    %% ------------ FIND LOW-FREQ OSCILLATION AND IT'S MAXIMA ---------------
    LimitAmp         = Athresh*mean(std(EEG.data(chan_fP,:,:),0,2));
    [Maxes, LowFreq] = FindMaxes(BOOK,1,EEG.srate,fP_bins,LimitAmp);
    HighFreqSignal   = EEG.data(chan_fA,:,:);
    
    %% ---------------------------- MAIN PART -------------------------------
    disp('-----------------------PAC algorithm calculations----------------------')
    if strcmp(type,'continous')
        run_continous_pac(EEG,HighFreqSignal,Maxes,LowFreq,fP_bins,fP,fAstart,fAend,fAstep,margines,dirOut,nbCycles,w,deltaT,Nboot,p,pmMVL,ID)
    elseif strcmp(type,'event_related')
        run_event_related_pac(EEG,HighFreqSignal,Maxes,LowFreq,fP_bins,fP,fAstart,fAend,fAstep,margines,dirOut,nbCycles,w,deltaT,Nboot,p,pmMVL,ID)
    end
    
    %% -------------------- SAVE CONFIGURATION FILE -------------------------
    config.EEGname     = EEG.filename;
    config.EEGpath     = EEG.filepath;
    config.EEGdataHash = DataHash(EEG.data,struct('Input','array'));
    config.chan_fP     = chan_fP;
    config.chan_fA     = chan_fA;
    config.fPstart     = fPstart;
    config.fPend       = fPend;
    config.fPstep      = fPstep;
    config.fAstart     = fAstart;
    config.fAend       = fAend;
    config.fAstep      = fAstep;
    config.dirOut      = dirOut;
    config.type        = type;
    config.nbCycles    = nbCycles;
    config.w           = w;
    config.deltaT      = deltaT;
    config.nbMPiter    = nbMPiter;
    config.Athresh     = Athresh;
    config.Nboot       = Nboot;
    config.p           = p;
    config.pmMVL       = pmMVL;
    
    save([dirOut 'v' ID '_mpPAC_config.mat'],'config')
end