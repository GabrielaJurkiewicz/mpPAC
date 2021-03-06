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

function [] = run_continous_pac(EEG,HighFreqSignal,Maxes,LowFreq,fP_bins,fP,fAstart,fAend,fAstep,margines,dirOut,nbCycles,w,deltaT,Nboot,p,pmMVL,ID)

    Epochs = 1:EEG.trials;
    fA = fAstart:fAstep:fAend;
    
    for epoch = 1:length(Epochs)
 
        disp(['Epoch ' num2str(epoch) ' / ' num2str(length(Epochs))])
        progressbar('on')
        mMVL      = zeros(length(fA),size(fP_bins,2));
        mMVL_boot = zeros(Nboot,length(fA),size(fP_bins,2));

        results = matfile([dirOut 'v' ID '_mpPAC_epoch' num2str(epoch) '_results.mat'],'Writable',true);
        results.fA = fA;
        results.fP = fP;

        for i = 1:size(fP_bins,2)

            %% ---------------- ADJUST DATA TO SPECIFIC fP  ---------------------
            fP_b  = fP_bins(:,i)';
            cut   = nbCycles/(2*fP(1,i));
            time  = linspace(-cut,cut,floor(cut*EEG.srate)*2+1);

            signal   = squeeze(HighFreqSignal(1,:,epoch));
            fPsignal = LowFreq{i}{1,epoch};
            mxs      = Maxes{i}{1,epoch};
            mx       = mxs((mxs>(floor((cut+margines)*EEG.srate)))&(mxs<(floor(size(signal,2))-floor((cut+margines)*EEG.srate))));

            %% ---------------- CALCULATE TF MAPS + THRESHOLD -------------------
            [Map, MeanSignal, MessMap, MeanLowFreq] = calcMeanMapContinous(signal, mx, fPsignal, EEG.srate, cut, w, fAstart, fAend, fAstep, fA, fP_b, Nboot);
            [MapT, MessMapT] = tresholdMaps(Map,MessMap,Nboot,p,(i-1),size(fP_bins,2));

            %% ---------------- CALCULATE MI --------------------------------------
            [mmvl, mmvl_boot] = calc_mMVL(MapT, MessMapT, MeanLowFreq, fA, Nboot, fP(1,i), EEG.srate, deltaT, (i-1), size(fP_bins,2));
            mMVL(:,i) = mmvl';
            mMVL_boot(:,:,i) = mmvl_boot;

            %% -------------------- SAVE AND PLOT RESULTS + CLEAN -----------------------------
            eval(['results' num2str(fP(1,i)) 'Hz.time = time;'])
            eval(['results' num2str(fP(1,i)) 'Hz.MapT = MapT;'])
            eval(['results' num2str(fP(1,i)) 'Hz.Map = Map;'])
            eval(['results' num2str(fP(1,i)) 'Hz.MeanSignal = MeanSignal;'])
            eval(['results' num2str(fP(1,i)) 'Hz.MeanLowFreq = MeanLowFreq;'])
            eval(['results.results' num2str(fP(1,i)) 'Hz = results' num2str(fP(1,i)) 'Hz;'])
            
            plot_maps_together(time,fA,Map,MapT,MeanSignal,MeanLowFreq,[dirOut 'v' ID '_mpPAC_epoch' num2str(epoch) '_results' num2str(fP(1,i)) 'Hz'],cut)
            clear Map MapT MeanSignal MeanLowFreq MessMap MessMapT mmvl mmvl_boot

            progressbar(i/size(fP_bins,2)*100)
        end

        %% ---------------- MI STATISTIC --------------------------------------
        MX  = max(max(mMVL_boot,[],2),[],3);
        tresh = prctile(MX,pmMVL);
        iid = (mMVL>=tresh);
        mMVL_afterStat = zeros(size(mMVL));
        mMVL_afterStat(iid) = mMVL(iid);

        %% ---------------- SAVE AND PLOT RESULTS + CLEAN --------------------------------------
        results.mMVL = mMVL;
        results.mMVL_afterStat = mMVL_afterStat;
        matfile([dirOut 'v' ID '_mpPAC_epoch' num2str(epoch) '_results.mat'],'Writable',false);
        
        plotFigure(fP,fA,mMVL,'mMVL',dirOut,['v' ID '_mpPAC_epoch' num2str(epoch) '_comodulogram'])
        plotFigure(fP,fA,mMVL_afterStat,'mMVL',dirOut,['v' ID '_mpPAC_epoch' num2str(epoch) '_comodulogram_statistic']) 
        
        clear mMVL mMVL_boot MX iid mMVL_afterStat results
        
        progressbar('off')
    end

end