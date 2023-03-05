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

%C_sp(C_sp==0)=1e-20;

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
target_1=log(target);

%{
gprMdl_Qua_std_nB = fitrgp(learn_property,target_1,...
"BasisFunction",@Fun_newbasis2,...
"Beta",Fun_newbeta2(learn_property),...
'KernelFunction',Kernel,...
"Standardize",true);
%}
%{
gprMdl_opt_nB = fitrgp(learn_property,target_1,...
"BasisFunction",@Fun_newbasis2,...
"Beta",Fun_newbeta2(learn_property),...
'OptimizeHyperparameters',{'KernelFunction'},...
'HyperparameterOptimizationOptions',struct('Repartition',true,'Holdout',0.2));
%}

%set up hyperparameters
param = hyperparameters('fitrgp',learn_property,target_1);
for ni = 1:5
    param(ni).Optimize=false;
end
param(2)=[];
%param(2).Range([1:5])=[];
param(2).Optimize=true;
%param(3)=[];

cell_gprMdl_opt_nB=cell(length(param(2).Range),3);
%cell_gprMdl_opt_nB_CV=cell(length(param(2).Range),2);

for ni = 1:length(param(2).Range)
    Kernel=param(2).Range{ni};
    cell_gprMdl_opt_nB{ni,1} = fitrgp(learn_property,target_1,...
    "BasisFunction",@Fun_newbasis2,...
    "Beta",Fun_newbeta2(learn_property),...
    'KernelFunction',Kernel,...
    "Standardize",true);
    
    cell_gprMdl_opt_nB{ni,2} = fitrgp(learn_property,target_1,...
    "BasisFunction",@Fun_newbasis2,...
    "Beta",Fun_newbeta2(learn_property),...
    'KernelFunction',Kernel,...
    'OptimizeHyperparameters',{'Sigma','Standardize'},...
    'HyperparameterOptimizationOptions',struct('MaxObjectiveEvaluations', 300,'Repartition',true,'Holdout', 0.3));
    if ni>5
        cell_gprMdl_opt_nB{ni,4} = fitrgp(learn_property,target_1,...
        "BasisFunction",@Fun_newbasis2,...
        "Beta",Fun_newbeta2(learn_property),...
        'KernelFunction',Kernel,...
        'OptimizeHyperparameters',{'KernelScale','Sigma','Standardize'},...
        'HyperparameterOptimizationOptions',struct('MaxObjectiveEvaluations', 300,'Repartition',true,'Holdout', 0.3));
    %else
    end

    cell_gprMdl_opt_nB{ni,3} = fitrgp(learn_property,target_1,...
    "BasisFunction",@Fun_newbasis2,...
    "Beta",Fun_newbeta2(learn_property),...
    'KernelFunction',Kernel,...
    "Standardize",true,'Holdout', 0.3);
    %end
    %}
    %opt_result=gprMdl_opt_nB.HyperparameterOptimizationResults.XAtMinObjective;
    %Kernel = gprMdl_opt_nB.KernelFunction;
    close all;
end


    %{
    %opt model
    gprMdl_now=gprMdl_opt_Qua_std_nB;
    name="gprMdl_opt_NB";
    name1="Gaussian process regression,NB,log, Kfold=5";
    ypred_gpr_CV =exp(kfoldPredict(gprMdl_now));
    ypred_gpr=exp(predict(gprMdl_now.Trained{1},learn_property));
    loss_t= mean((ypred_gpr-target).^2,'omitnan');
    CV_loss=mean((ypred_gpr_CV-target).^2,'omitnan');
    plot(target(isnan(ypred_gpr_CV)),ypred_gpr(isnan(ypred_gpr_CV)),"o");
    hold on;
    plot(target,ypred_gpr_CV,"r+");
    plot(target,target,"b");
    legend('Predicted vs target',"CV samples",'y=x','Location','northwest');
    title(name1+ newline+" CVloss="+CV_loss+", Tloss="+loss_t);
    disp(name+"  "+kfoldLoss(gprMdl_now)+"  "+loss_t)
    disp(corrcoef(target, ypred_gpr_CV,'Rows','pairwise'))
    disp(corrcoef(target, ypred_gpr,'Rows','pairwise'))
    hold off;
    saveas(gcf,name+"kfoldLoss.fig");
    saveas(gcf,name+"kfoldLoss.jpg");
    %}

    %run("GPR_newbasis2_Cnu.m")
    %run("GPR_opt_newbasis2_fieldpred.m")
    save("cell_gprMdl_opt_nB.mat","cell_gprMdl_opt_nB")
