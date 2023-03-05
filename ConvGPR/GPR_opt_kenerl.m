%% read data of AC
load("../AC.mat")
C_sp = raw(:,1);
BET = raw(:,2);
S_micro = raw(:,3);
S_meso = raw(:,4);
pore_volume = raw(:,5);
V_micro = raw(:,6);
V_meso = raw(:,7);
scan_rate = raw(:,8);

%Kernel='matern32';
space = 20;
a = 0:space:3500;
b = 0:space:1500;

learn_property=zeros(length(C_sp),3);
target= C_sp;
jj = 0;
for ii = 1:length(C_sp)
%     if (current_density(ni) <= 5)
        jj = jj + 1;
        learn_property(jj,:) = [scan_rate(ii) S_micro(ii) S_meso(ii) ];
        target(jj,1) = C_sp(ii);
%     end
end

rng('default');
index = randperm(length(target));
target = target(index,:);
learn_property = learn_property(index,:);

rng(2);

%making models
n_input= size(learn_property,2);
n_material=n_input-1;
n_beta_i=(n_material+1)*(n_material+2)/2;

beta_0=rand(n_beta_i+1,1)/100;
target_1=target;
%target_1=log(target);

%set up hyperparameters
param = hyperparameters('fitrgp',learn_property,target_1);
for ni = 1:5
    param(ni).Optimize=false;
end
param(2)=[];
%param(2).Range([1:5])=[];
param(2).Optimize=true;
%param(3)=[];

cell_gprMdl_opt=cell(length(param(2).Range),4);
%cell_gprMdl_opt_nB_CV=cell(length(param(2).Range),2);

for ni = 1:length(param(2).Range)
    Kernel=param(2).Range{ni};
    cell_gprMdl_opt{ni,1} = fitrgp(learn_property,target_1,...
    "BasisFunction","pureQuadratic",...
    ...%,"Beta",Fun_newbeta2(learn_property),...
    'KernelFunction',Kernel,...
    "Standardize",true);
    
    cell_gprMdl_opt{ni,2} = fitrgp(learn_property,target_1,...
    "BasisFunction","pureQuadratic",...
    ...%"Beta",Fun_newbeta2(learn_property),...
    'KernelFunction',Kernel,...
    'OptimizeHyperparameters',{'Sigma','Standardize'},...
    'HyperparameterOptimizationOptions',struct('MaxObjectiveEvaluations', 300,'Repartition',true,'Kfold', 5));
    

    cell_gprMdl_opt{ni,3} = fitrgp(learn_property,target_1,...
    "BasisFunction","pureQuadratic",...
    ...%,"Beta",Fun_newbeta2(learn_property),...
    'KernelFunction',Kernel,...
    "Standardize",true,...
    'Kfold', 5);
    %opt_result=gprMdl_opt_nB.HyperparameterOptimizationResults.XAtMinObjective;
    %Kernel = gprMdl_opt_nB.KernelFunction;
    close all;
end

save("cell_gprMdl_opt.mat","cell_gprMdl_opt")
