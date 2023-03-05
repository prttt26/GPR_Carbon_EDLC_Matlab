


%{
 array_loss=zeros(length(param(2).Range),1);
array_loss2=zeros(length(param(2).Range),1);
array_loss3=zeros(length(param(2).Range),1);
array_loss4=zeros(length(param(2).Range),1);
sigma1=zeros(length(param(2).Range),1);
sigma2=zeros(length(param(2).Range),1);
sigma3=zeros(length(param(2).Range),1);
sigma4=zeros(length(param(2).Range),1); 
%}


linewidth=1;
labelFontSize=22;
legendFontSize=18;
titleFontSize=18;
axisFontSize=20;
axislinewidth=1.5;

for ni = 1:length(param(2).Range)
    %in model resubloss
    for iii=1:4
        gprMdl_now=cell_gprMdl_opt_nB{ni,iii};
        
        if iii==1
            Kernel = gprMdl_now.KernelFunction;
            betatemp=gprMdl_now.Beta;
            name="gprMdl_opt_NB"+Kernel;
        elseif iii==2
            Kernel = gprMdl_now.KernelFunction;
            betatemp=gprMdl_now.Beta;
            opt_result=gprMdl_now.HyperparameterOptimizationResults.XAtMinObjective;
            name="gprMdl_opt_NB_opt1";
        elseif iii==3
            Kernel = gprMdl_now.Trained{1}.KernelFunction;
            betatemp=gprMdl_now.Trained{1}.Beta;
            %opt_result=gprMdl_now.HyperparameterOptimizationResults.XAtMinObjective;
            name="gprMdl_opt_NB_CV";
        elseif ni>5
            Kernel = gprMdl_now.KernelFunction;
            betatemp=gprMdl_now.Beta;
            opt_result=gprMdl_now.HyperparameterOptimizationResults.XAtMinObjective;
            name="gprMdl_opt_NB_opt2";
        else
            continue
        end
        
        [~,~]=mkdir("figures/");
        [~,~]=mkdir("figures/"+Kernel);
        [~,~]=mkdir("figures/"+Kernel+"/"+name);
        save("figures/"+Kernel+"/"+name+"/beta.txt","betatemp",'-ascii')
        %name="gprMdl_opt_NB"+Kernel;
        %if or(iii==2,iii==4)
        %    writetable(table(opt_result),"figures/"+Kernel+"/"+name+"/opt_result.txt")
        %end
        %[ypred_gpr, predict_sd]=predict(gprMdl_now,learn_property);
        [ypred_gpr, predict_Asd,  predict_rsd]=Fun_predict_NB2(gprMdl_now,learn_property);
        target2=target;
        %target2(target==0)=nan;
        loss=mean((target2-ypred_gpr).^2,"omitnan");
        RMSE=sqrt(loss);

        for type_fig=1
            %plot(target,target,"k--",'LineWidth',linewidth);
            plot([0;300],[0;300],"k--",'LineWidth',linewidth);
            hold on;

            %ypred_gpr=ypred_gpr;
            if type_fig==2
                errorbar(target,ypred_gpr,predict_Asd,'-s','MarkerSize',8,...
                    'MarkerEdgeColor','black','MarkerFaceColor','black');
            else
                plot(target,ypred_gpr,"ko",...
                    'MarkerSize',8,"Linewidth",2);
            end
            hold on;
            %figure('Position',[100 100 600 450]);
            
            %legend('Prediction, RMSE='+string(round(RMSE,2)),'y=x','Location','northwest','FontSize',legendFontSize);
            legend('y=x',"PhysGPR",...
                'Location','southeast','FontSize',legendFontSize);
            legend('boxoff')
            xlabel("Experimental C_s_p (F/g)",'FontSize',labelFontSize)
            ylabel("Fitted C_s_p (F/g)",'FontSize',labelFontSize)
            %ylabel("Phys GPR,"+newline+Kernel+newline+"Predicted C_s_p (F/g)",'FontSize',labelFontSize)
            
            name1="Gaussian process regression,NB";
            
            
            %{
            title(name1+Kernel+newline+"loss,"+...
                            " Tloss="+loss+",score=",...
                            'FontSize',titleFontSize);
            title(" "); 
            %}
            %title('RMSE='+string(round(RMSE,2))); 
            %title(Kernel);
            %title("ARDRationalQuadratic")
            %disp(name+"  "+resubLoss(gprMdl_now));
            disp(name+"  "+loss);
            disp(corrcoef(target, ypred_gpr,'Rows','pairwise'))
            hold off;
            ax=gca;
            Fun_Axislinefontsize(ax,axisFontSize,axislinewidth)
            x_all_ticks=0:50:350;
            y_all_ticks=0:50:350;
            Fun_AxisTicksformat(ax,x_all_ticks,y_all_ticks);
            fig1=gcf;
            set(fig1,'Position',[100 100 600 500]);
            newpos=fig1.Position/100;
            set(fig1,'Paperunits',"inches","Paperposition",newpos);
            if type_fig==1
                saveas(gcf,"figures/"+Kernel+"/"+name+"/resubLoss.fig");
                %saveas(gcf,"figures/"+Kernel+"/"+name+"/resubLoss.jpg");
                print(fig1,"figures/"+Kernel+"/"+name+"/resubLoss.jpg","-djpeg",'-r100');
            else
                saveas(gcf,"figures/"+Kernel+"/"+name+"/errorbar.fig");
                saveas(gcf,"figures/"+Kernel+"/"+name+"/errorbar.jpg");
                
            end
            close all;
        end
        

        if iii==3
            sigma3(ni)=gprMdl_now.Trained{1}.Sigma;
            KernelInformation=gprMdl_now.Trained{1}.KernelInformation;
            
        else 
            sigma4(ni)=gprMdl_now.Sigma;
            KernelInformation=gprMdl_now.KernelInformation;
        end
        KernelParameters=KernelInformation.KernelParameters;
        save("figures/"+Kernel+"/"+name+"/KernelInformation.mat","KernelInformation")
        save("figures/"+Kernel+"/"+name+"/KernelParameters.txt","KernelParameters",'-ascii')
    end
   
end
