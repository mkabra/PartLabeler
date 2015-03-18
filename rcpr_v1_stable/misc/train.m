% Train function
%       + phisTr: training labels.
%       + bboxesTr: bounding boxes.
%       + IsTr: training images
%       + cpr_type: 1 for Cao et al 2013, 2 for Burgos-Artizzu et al 2013
%       (without occlusion) and 2 for Burgos-Artizzu et al 2013
%       (occlusion).
%       + model_type: 'larva' (Marta's larvae with two muscles and two
%       landmarks for muscle), 'mouse_paw' (Adam's mice with one landmarks in one
%       view), 'mouse_paw2' (Adam's mice with two landmarks, one in each
%       view), 'mouse_paw3D' (Adam's mice, one landmarks in the 3D
%       reconstruction), fly_RF2 (Romain's flies, six landmarks)
%       + feature type: for 1-4 see FULL_demoRCPR.m, 5 for points in an
%       elipse with focus in any pair of landmarks, and 6 for points in a
%       circunference around each landmark.
%       + radius: dimensions of the area where features are computed, for
%       feature_type=5 (recomended 1.5) is the semi-major axis, for
%       feature_type=6 is the radius of the circumference (recomended 25). 
%       + Prm3D: parameters for 3D rexontruction (empty if 2D).
%       + pStar: initial position of the the labels (optional)
%       + regModel: regression model
%       + regPrm: regression parameters (using the paramters recomended in
%       Burgos-Artizzu et al 2013).
%       + prunePrm: prune parameters using the paramters recomended in
%       Burgos-Artizzu et al 2013). 

function [regModel,regPrm,prunePrm]=train(phisTr,bboxesTr,IsTr,cpr_type,model_type,ftr_type,radius,Prm3D,pStar)
if nargin<9
    pStar=[];
elseif (nargin<8 && strcmp(model_type,'mouse_paw3D')) || nargin<7
    error('Not enough input arguments')    
end

% Setup parameters
%Create model
model = shapeGt('createModel',model_type);
%RCPR(features+restarts) PARAMETERS
T=100;K=50;L=5;
prunePrm=struct('prune',1,'maxIter',2,'th',10,'tIni',10,'numInit',5);

if cpr_type==1
    ftrPrm = struct('type',2,'F',400,'nChn',1,'radius',1);
    occlPrm=struct('nrows',3,'ncols',3,'nzones',1,'Stot',1,'th',.5);
    prunePrm.prune = 0;
elseif cpr_type==2
    ftrPrm = struct('type',ftr_type,'F',400,'nChn',1,'radius',radius);
    occlPrm=struct('nrows',3,'ncols',3,'nzones',1,'Stot',1,'th',.5);
    %smart restarts are enabled
elseif cpr_type==3
    ftrPrm = struct('type',ftr_type,'F',400,'nChn',1,'radius',radius);
    occlPrm=struct('nrows',3,'ncols',3,'nzones',1,'Stot',3,'th',.5);
end
prm=struct('thrr',[-1 1]/5,'reg',.01);
regPrm = struct('type',1,'K',K,'occlPrm',occlPrm,...
    'loss','L2','R',0,'M',5,'model',model,'prm',prm,'ftrPrm',ftrPrm);

%% TRAIN
%Initialize randomly L shapes per training image
[pCur,pGt,pGtN,pStar,imgIds,N,N1]=shapeGt('initTr',...
    IsTr,phisTr,model,pStar,bboxesTr,L,10);

% pStar=repmat(phisTr,[1,1,5])+20*randn([size(phisTr),5]); %temp
% lims=[bboxesTr(:,1:2),bboxesTr(:,1:2)+bboxesTr(:,3:4)];
% for i=1:5
%     pStar(:,1,i)=min(max(pStar(:,1,i),lims(:,1)),lims(:,3));
%     pStar(:,2,i)=min(max(pStar(:,2,i),lims(:,2)),lims(:,4));
% end
    

initData=struct('pCur',pCur,'pGt',pGt,'pGtN',pGtN,'pStar',pStar,...
    'imgIds',imgIds,'N',N,'N1',N1);
%Create training structure
trPrm=struct('model',model,'pStar',[],'posInit',bboxesTr,...
    'T',T,'L',L,'regPrm',regPrm,'ftrPrm',ftrPrm,...
    'pad',10,'verbose',1,'initData',initData);
if strcmp(model_type,'mouse_paw3D')
    trPrm.Prm3D=Prm3D;
end
%Train model
[regModel,~] = rcprTrain(IsTr,phisTr,trPrm);
if strcmp(model_type,'mouse_paw3D')
    regPrm.Prm3D=Prm3D;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
