% Test function 
%       + phisT: labels to compute the loss (empty if there are no labels) 
%       + bboxesT: bounding boxes
%       + IsT: images
%       + regModel: regressor model (obtained from training)
%       + regParam: regression parameters
%       + prunePrm: prune parameters
%       + piT: inital label position (optional)

function [pT,pRTT,lossT,fail,p_t]=test_rcpr(phisT,bboxesT,IsT,regModel,regPrm,prunePrm,piT)
if nargin==6
    % Setup parameters
    RT1=prunePrm.numInit;
    %Initialize randomly using RT1 shapes drawn from training
    piT=shapeGt('initTest',IsT,bboxesT,regModel.model,regModel.pStar,regModel.pGtN,RT1);
else
    RT1=size(piT,3);
end


%% TEST on TRAINING data
%Create test struct
testPrmT = struct('RT1',RT1,'pInit',bboxesT,...
    'regPrm',regPrm,'initData',piT,'prunePrm',prunePrm,...
    'verbose',0);
%Test
t=clock;[pT,pRTT,p_t,fail] = rcprTest(IsT,regModel,testPrmT);t=etime(clock,t);
%Round up the pixel positions
pT=round(pT);
%Compute loss
if ~isempty(phisT)
    lossT = shapeGt('dist',regModel.model,pT,phisT);
    fprintf('--------------DONE\n');
else
    lossT = [];
end
