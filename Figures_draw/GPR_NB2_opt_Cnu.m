cell_input_folder="../Cnu_input/";
%run(cell_input_folder+"cell_input_produce.m")
load(cell_input_folder+"Cnu_input.mat");
load(cell_input_folder+"Cnu_sample.mat");

scanrate_1=0:500;
scanrate_Cnu=scanrate_1';

linewidth=4;
labelFontSize=22;
legendFontSize=18;
titleFontSize=22;
axisFontSize=20;
axislinewidth=1.5;


for ni=1:length(param(2).Range)
%for ni=9:length(param(2).Range)
    for iii=1:4
        gprMdl_now=cell_gprMdl_opt_nB{ni,iii};
        if iii==1
            Kernel = gprMdl_now.KernelFunction;
            name="gprMdl_opt_NB"+Kernel;
        elseif iii==2
            Kernel = gprMdl_now.KernelFunction;
            opt_result=gprMdl_now.HyperparameterOptimizationResults.XAtMinObjective;
            name="gprMdl_opt_NB_opt1";
        elseif iii==3
            Kernel = gprMdl_now.Trained{1}.KernelFunction;
            %opt_result=gprMdl_now.HyperparameterOptimizationResults.XAtMinObjective;
            name="gprMdl_opt_NB_CV";
        elseif ni>5
            Kernel = gprMdl_now.KernelFunction;
            opt_result=gprMdl_now.HyperparameterOptimizationResults.XAtMinObjective;
            name="gprMdl_opt_NB_opt2";
        else
            continue
        end
        %Kernel = gprMdl_now.KernelFunction;
        for nj=1:n_samples
            input=cell_input{nj};
            %{
            [target_predict_gpr, predict_sd, predict_inv]=predict(gprMdl_now,input);
            target_predict_gpr=exp(target_predict_gpr+predict_sd.^2);
            target_predict_sd_1=sqrt((exp(predict_sd.^2)-1).*exp(predict_sd.^2));
            %}
            [target_predict_gpr, predict_Asd, predict_rsd] = Fun_predict_NB2(gprMdl_now,input);
            
            %figure('Position',[100 100 600 450]);
            figmain=plot(scanrate_Cnu,target_predict_gpr,'LineWidth',4,...
                'DisplayName','Mean Prediction');

            cl=figmain.Color;
            hold on;
            %{
            figup=plot(scanrate_Cnu,target_predict_gpr+predict_Asd,...
                "r--",...
                'DisplayName','Standard error bar','LineWidth',linewidth);
            figdown=plot(scanrate_Cnu,target_predict_gpr-predict_Asd,...
                "r--",...
                'DisplayName',' ',...
                'LineWidth',linewidth);
            figdown.Annotation.LegendInformation.IconDisplayStyle = 'off';
            %}
            
            patch_error=fill([scanrate_Cnu;flipud(scanrate_Cnu)],...
                [target_predict_gpr-predict_Asd;flipud(target_predict_gpr+predict_Asd)],...
                cl,'linestyle', 'none','FaceAlpha',0.25,'DisplayName','Standard error bar');
            figdata=plot(cell_sampledata{nj}(:,2),cell_sampledata{nj}(:,1),...
                'LineStyle','none','Marker',"+",'MarkerSize',10,"Color",cl,...
                'DisplayName','Experimental data');
            patch_error.Annotation.LegendInformation.IconDisplayStyle = 'off';
            hold off;
            patch_error.Annotation.LegendInformation.IconDisplayStyle = 'on';
            name1="CV curve "+Kernel+" opttype"+ iii+...
                newline+"input"+nj+" "+cell_inputtype{nj};
            title(name1);
            title(" ");
            xlabel("\nu (mV/s)",'FontSize',labelFontSize)
            ylabel("C_s_p (F/g)",'FontSize',labelFontSize)
            legend('FontSize',legendFontSize,'Location','northoutside');
            ax=gca;
            Fun_Axislinefontsize(ax,axisFontSize,axislinewidth)
            ylim([0,500]);
            xlim([0,500]);
            x_all_ticks=0:50:500;
            y_all_ticks=0:50:500;
            Fun_AxisTicksformat(ax,x_all_ticks,y_all_ticks);
            [~,~]=mkdir("figures/");
            [~,~]=mkdir("figures/"+Kernel);
            [~,~]=mkdir("figures/"+Kernel+"/"+name);
            [~,~]=mkdir("figures/"+Kernel+"/"+name+"/Cnu");
            [~,~]=mkdir("figures/"+Kernel+"/"+name+"/Cnu/singles");
            saveas(gcf,"figures/"+Kernel+"/"+name+"/Cnu/singles/scanrate-C prediction NB "+nj+".fig")
            saveas(gcf,"figures/"+Kernel+"/"+name+"/Cnu/singles/scanrate-C prediction NB "+nj+".jpg")
            close all;
        end

        %figure('Position',[100 100 600 450]);
        for nj=1:n_samples
            material_1=cell_material{nj};
            DispName="Smicro="+material_1(1)+"Smeso="+material_1(2);
            input=cell_input{nj};
            [target_predict_gpr, predict_Asd, predict_rsd] = Fun_predict_NB2(gprMdl_now,input);
            
            figmain=plot(scanrate_Cnu,target_predict_gpr,'LineWidth',linewidth,...
                'DisplayName',DispName);
            figmain.Color=cell_color{nj};
            cl=figmain.Color;

            hold on;
            patch_error=fill([scanrate_Cnu;flipud(scanrate_Cnu)],...
                [target_predict_gpr-predict_Asd;flipud(target_predict_gpr+predict_Asd)],...
                cl,'linestyle', 'none','FaceAlpha',0.5,'DisplayName','Standard error bar');
            patch_error.Annotation.LegendInformation.IconDisplayStyle = 'off';
            if ~ismember(nj,[4:6])
                figdata=plot(cell_sampledata{nj}(:,2),cell_sampledata{nj}(:,1),...
                    'LineStyle','none','Marker',"+",'MarkerSize',10,"Color",cl,...
                    'DisplayName','Experimental data');
                figdata.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
        end
        if ~ismember(nj,[4:6])
            figdata.Annotation.LegendInformation.IconDisplayStyle = 'on';
        end
        patch_error.Annotation.LegendInformation.IconDisplayStyle = 'on';
        hold off;
        name1="CV curve "+Kernel+" opttype"+ iii+...
            newline+"input all";
        title(name1);
        title(" ");
        xlabel("\nu (mV/s)",'FontSize',labelFontSize)
        ylabel("C_s_p (F/g)",'FontSize',labelFontSize)
        
        legend('FontSize',legendFontSize,'Location','northoutside');
        ax=gca;
        Fun_Axislinefontsize(ax,axisFontSize,axislinewidth)
        ylim([0,500]);
        xlim([0,500]);
        x_all_ticks=0:50:500;
        y_all_ticks=0:50:500;
        Fun_AxisTicksformat(ax,x_all_ticks,y_all_ticks);
        [~,~]=mkdir("figures/"+Kernel+"/"+name);
        [~,~]=mkdir("figures/"+Kernel+"/"+name+"/Cnu");
        [~,~]=mkdir("figures/"+Kernel+"/"+name+"/Cnu/all");
        set(gcf,'Position',[100 100 600 450]);
        saveas(gcf,"figures/"+Kernel+"/"+name+"/Cnu/all/scanrate-C prediction NB all"+".fig")
        saveas(gcf,"figures/"+Kernel+"/"+name+"/Cnu/all/scanrate-C prediction NB all"+".jpg")
        close all;
        for nfig=1:7
            if nfig<6
                idfigs=(nfig*3-2):(nfig*3);
            elseif nfig==6
                idfigs=16:19;
            elseif nfig==7
                idfigs=20:23;
            end
            %figure('Position',[100 100 600 450]);
            for nj=idfigs
                material_1=cell_material{nj};
                %DispName="Smicro="+material_1(1)+"Smeso="+material_1(2);
                DispName=cell_inputtype{nj};
                input=cell_input{nj};
                [target_predict_gpr, predict_Asd, predict_rsd] = Fun_predict_NB2(gprMdl_now,input);
                
                if ~ismember(nj,[4:6])
                    figdata=plot(cell_sampledata{nj}(:,2),cell_sampledata{nj}(:,1),...
                        'LineStyle','none',"Color",cell_color{nj},...
                        "Marker",cell_Marker{nj},'MarkerFaceColor',cell_color{nj},'MarkerSize',12,...
                        'DisplayName','Experiment '+DispName);
                    figdata.Annotation.LegendInformation.IconDisplayStyle = 'on';
                elseif nj==4
                    close;
                end
                hold on;
                figmain=plot(scanrate_Cnu,target_predict_gpr,...
                    'LineStyle',cell_Line{nj},'LineWidth',linewidth,...
                    "Color",cell_color{nj},'DisplayName','Prediction '+DispName);
                figmain.Color=cell_color{nj};
                cl=figmain.Color;
                if ~ismember(nj,[4:6])
                    %figmain.Annotation.LegendInformation.IconDisplayStyle = 'off';
                else
                    figmain.DisplayName=DispName;
                end
                hold on;
                
                patch_error=fill([scanrate_Cnu;flipud(scanrate_Cnu)],...
                    [target_predict_gpr-predict_Asd;flipud(target_predict_gpr+predict_Asd)],...
                    cl,'linestyle', 'none','FaceAlpha',0.5,'DisplayName','Standard error bar');
                patch_error.Annotation.LegendInformation.IconDisplayStyle = 'off';
                
            end
            hold off;
            if ~ismember(nj,[4:6])
                figmain.Annotation.LegendInformation.IconDisplayStyle = 'on';
            end
            patch_error.Annotation.LegendInformation.IconDisplayStyle = 'on';
            name1="CV curve "+Kernel+" opttype"+ iii+...
                newline+"input all";
            title(name1);
             title(" ");
            xlabel("\nu (mV/s)",'FontSize',labelFontSize)
            ylabel("C_s_p (F/g)",'FontSize',labelFontSize)
            lgn=legend('FontSize',legendFontSize,...
                'Orientation','horizontal','NumColumns',2,'Location',"northeast");
            legend('hide');
            ax=gca;
            Fun_Axislinefontsize(ax,axisFontSize,axislinewidth)
            ylim([0,400]);
            xlim([0,500]);
            x_all_ticks=0:50:500;
            y_all_ticks=0:50:400;
            Fun_AxisTicksformat(ax,x_all_ticks,y_all_ticks);

            [~,~]=mkdir("figures/"+Kernel+"/"+name);
            [~,~]=mkdir("figures/"+Kernel+"/"+name+"/Cnu");
            fig1=gcf;
            set(fig1,'Position',[100 100 600 450]);
            newpos=fig1.Position/100;
            set(fig1,'Paperunits',"inches","Paperposition",newpos);
            saveas(fig1,"figures/"+Kernel+"/"+name+"/Cnu/all/scanrate-C prediction NB all"+nfig+".fig")
            %saveas(fig1,"figures/"+Kernel+"/"+name+"/Cnu/all/scanrate-C prediction NB all"+nfig+".jpg")
            print(fig1,"figures/"+Kernel+"/"+name+"/Cnu/all/scanrate-C prediction NB all"+nfig+".jpg","-djpeg",'-r100')
            close all;
        end
        
        for nfig=1:7
            if nfig<6
                idfigs=(nfig*3-2):(nfig*3);
            elseif nfig==6
                idfigs=16:19;
            elseif nfig==7
                idfigs=20:23;
            end
            %figure('Position',[100 100 600*2 500]);
            for nj=idfigs
                material_1=cell_material{nj};
                %DispName="Smicro="+material_1(1)+"Smeso="+material_1(2);
                DispName=cell_inputtype{nj};
                input=cell_input{nj};
                [target_predict_gpr, predict_Asd, predict_rsd] = Fun_predict_NB2(gprMdl_now,input);
                
                
                if ~ismember(nj,[4:6])
                    figdata=plot(cell_sampledata{nj}(:,2),cell_sampledata{nj}(:,1),...
                        'LineStyle','none',"Color",cell_color{nj},...
                        "Marker",cell_Marker{nj},'MarkerFaceColor',cell_color{nj},'MarkerSize',12,...
                        ...'DisplayName','Experiment '+DispName);
                        'DisplayName',DispName);
                    figdata.Annotation.LegendInformation.IconDisplayStyle = 'on';
                elseif nj==4
                    close;
                end
                hold on;
                figmain=plot(scanrate_Cnu,target_predict_gpr,...
                    'LineStyle',cell_Line{nj},'LineWidth',linewidth,...
                    "Color",cell_color{nj},...
                    ...'DisplayName','Prediction '+DispName);
                    'DisplayName','Prediction ');
                figmain.Color=cell_color{nj};
                cl=figmain.Color;
                if ~ismember(nj,[4:6])
                    %figmain.Annotation.LegendInformation.IconDisplayStyle = 'off';
                else
                    figmain.DisplayName=DispName;
                end
                hold on;
                
                patch_error=fill([scanrate_Cnu;flipud(scanrate_Cnu)],...
                    [target_predict_gpr-predict_Asd;flipud(target_predict_gpr+predict_Asd)],...
                    cl,'linestyle', 'none','FaceAlpha',0.5,'DisplayName','Standard error bar');
                patch_error.Annotation.LegendInformation.IconDisplayStyle = 'off';
                
            end
            hold off;
            if ~ismember(nj,[4:6])
                figmain.Annotation.LegendInformation.IconDisplayStyle = 'on';
            end
            patch_error.Annotation.LegendInformation.IconDisplayStyle = 'on';
            name1="CV curve "+Kernel+" opttype"+ iii+...
                newline+"input all";
            title(name1);
             title(" ");
            xlabel("\nu (mV/s)",'FontSize',labelFontSize)
            ylabel("C_s_p (F/g)",'FontSize',labelFontSize)
            lgn=legend('FontSize',legendFontSize,...
                'Orientation','horizontal','NumColumns',4,'Location',"northoutside");
                legend('boxoff');
            %lgn.Layout.Tile = 2;
            ax=gca;
            Fun_Axislinefontsize(ax,axisFontSize,axislinewidth)
            ylim([0,400]);
            xlim([0,500]);
            x_all_ticks=0:50:500;
            y_all_ticks=0:50:400;
            Fun_AxisTicksformat(ax,x_all_ticks,y_all_ticks);

            [~,~]=mkdir("figures/"+Kernel+"/"+name);
            [~,~]=mkdir("figures/"+Kernel+"/"+name+"/Cnu");
            [~,~]=mkdir("figures/"+Kernel+"/"+name+"/Cnu/all/withlegend");
            fig2=gcf;
            set(fig2,'Position',[100 100 600*2 500]);
            newpos=fig2.Position/100;
            set(fig2,'Paperunits',"inches","Paperposition",newpos);
            saveas(fig2,"figures/"+Kernel+"/"+name+"/Cnu/all/withlegend/scanrate-C prediction NB all"+nfig+".fig")
            saveas(fig2,"figures/"+Kernel+"/"+name+"/Cnu/all/withlegend/scanrate-C prediction NB all"+nfig+".jpg")
            %print(fig2,"figures/"+Kernel+"/"+name+"/Cnu/all/withlegend/scanrate-C prediction NB all"+nfig+".jpg","-djpeg",'-r100');
            close all;
        end

        for nfig=1:7
            if nfig<6
                idfigs=(nfig*3-2):(nfig*3);
            elseif nfig==6
                idfigs=16:19;
            elseif nfig==7
                idfigs=20:23;
            end
            %figure('Position',[100 100 600*2 500]);
            for nj=idfigs
                material_1=cell_material{nj};
                %DispName="Smicro="+material_1(1)+"Smeso="+material_1(2);
                DispName=cell_inputtype{nj};
                input=cell_input{nj};
                [target_predict_gpr, predict_Asd, predict_rsd] = Fun_predict_NB2(gprMdl_now,input);
                
                
                if ~ismember(nj,[4:6])
                    figdata=plot(cell_sampledata{nj}(:,2),cell_sampledata{nj}(:,1),...
                        'LineStyle','none',"Color",cell_color{nj},...
                        "Marker",cell_Marker{nj},'MarkerFaceColor',cell_color{nj},'MarkerSize',12,...
                        'DisplayName','Experiment '+DispName);
                    figdata.Annotation.LegendInformation.IconDisplayStyle = 'on';
                elseif nj==4
                    close;
                end
                hold on;
                figmain=plot(scanrate_Cnu,target_predict_gpr,...
                    'LineStyle',cell_Line{nj},'LineWidth',linewidth,...
                    "Color",cell_color{nj},'DisplayName','Prediction '+DispName);
                figmain.Color=cell_color{nj};
                cl=figmain.Color;
                if ~ismember(nj,[4:6])
                    %figmain.Annotation.LegendInformation.IconDisplayStyle = 'off';
                else
                    figmain.DisplayName=DispName;
                end
                hold on;
                

                %{
                 patch_error=fill([scanrate_Cnu;flipud(scanrate_Cnu)],...
                    [target_predict_gpr-predict_Asd;flipud(target_predict_gpr+predict_Asd)],...
                    cl,'linestyle', 'none','FaceAlpha',0.5,'DisplayName','Standard error bar');
                patch_error.Annotation.LegendInformation.IconDisplayStyle = 'off'; 
                %}

                
            end
            hold off;
            if ~ismember(nj,[4:6])
                figmain.Annotation.LegendInformation.IconDisplayStyle = 'on';
            end
            %patch_error.Annotation.LegendInformation.IconDisplayStyle = 'on';
            name1="CV curve "+Kernel+" opttype"+ iii+...
                newline+"input all";
            title(name1);
             title(" ");
            xlabel("\nu (mV/s)",'FontSize',labelFontSize)
            ylabel("C_s_p (F/g)",'FontSize',labelFontSize)
            lgn=legend('FontSize',legendFontSize,...
                'Orientation','horizontal','NumColumns',4,'Location',"northeast");
            legend('hide');
            %lgn.Layout.Tile = 2;
            ax=gca;
            Fun_Axislinefontsize(ax,axisFontSize,axislinewidth)
            ylim([0,400]);
            xlim([0,500]);
            x_all_ticks=0:50:500;
            y_all_ticks=0:50:400;
            Fun_AxisTicksformat(ax,x_all_ticks,y_all_ticks);

            [~,~]=mkdir("figures/"+Kernel+"/"+name);
            [~,~]=mkdir("figures/"+Kernel+"/"+name+"/Cnu");
            [~,~]=mkdir("figures/"+Kernel+"/"+name+"/Cnu/all/mean");
            fig1=gcf;
            set(fig1,'Position',[100 100 600 450]);
            newpos=fig1.Position/100;
            set(fig1,'Paperunits',"inches","Paperposition",newpos);
            saveas(fig1,"figures/"+Kernel+"/"+name+"/Cnu/all/mean/scanrate-C prediction NB all"+nfig+".fig")
            %saveas(fig1,"figures/"+Kernel+"/"+name+"/Cnu/all/mean/scanrate-C prediction NB all"+nfig+".jpg")
            print(fig1,"figures/"+Kernel+"/"+name+"/Cnu/all/mean/scanrate-C prediction NB all"+nfig+".jpg","-djpeg",'-r100');
            close all;
        end
        disp(name+"/Cnu/"+" over");
    end
end

