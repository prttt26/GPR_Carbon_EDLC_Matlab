%run("GPR_newbasis2.m")

space = 20;
a = 0:space:1500;
b = 0:space:1500;

linewidth=2;
labelFontSize=22;
legendFontSize=20;
titleFontSize=22;
axisFontSize=20;
axislinewidth=linewidth;


scan_rate_array =[5 10 20 50 100 200 300 400 500];
for ni=1:length(param(2).Range)
%for ni=9
    %input = zeros(length(a)*length(b), 3);
    
    %find the gpr model
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
        
        %save kernel name
        %Kernel = gprMdl_now.KernelFunction;
        name1="GPR "+Kernel+" opttype"+ iii;
        [~,~]=mkdir("figures/"+Kernel+"/"+name);
        [~,~]=mkdir("figures/"+Kernel+"/"+name+"/fieldprecict");
        
        %save mean prediction
        cell_target_predict_scanrate=cell(length(scan_rate_array),1);
        %predict for different input
        for nii=1:length(scan_rate_array)
            %input part
            input = zeros(length(a)*length(b), 3);
            scan_rate = scan_rate_array(nii);
            nj = 0;
            for ii = min(a):space:max(a)
                for jj = min(b):space:max(b)
                    nj = nj + 1;
                    input(nj,:) = [ scan_rate ii jj  ];
                end
            end

            %predict
            x=min(a):space:max(a);
            y= min(b):space:max(b);
            [X_i, Y_i]=meshgrid(x,y);
            [target_predict_gpr, predict_Asd,  predict_rsd]=Fun_predict_NB2(gprMdl_now,input);
            cell_target_predict_scanrate{nii}=target_predict_gpr;
            
            %predictpart
            maxtypefig=4;
            for ntypefig=1:maxtypefig
                if ntypefig==1
                    draw_z=target_predict_gpr;
                    string_type="fieldprecict";
                    [M,I]=max(draw_z);
                    bestpoint=[input(I,2:3) draw_z(I)];
                    [~,~]=mkdir("figures/"+Kernel+"/"+name+"/fieldprecict/bestpoint");
                    save("figures/"+Kernel+"/"+name+"/fieldprecict/bestpoint/"+string_type+scan_rate+"bestpoint.txt",...
                        "bestpoint",'-ascii');
                    save("figures/"+Kernel+"/"+name+"/fieldprecict/bestpoint/"+string_type+scan_rate+"bestpoint.mat",...
                        "bestpoint");
                    %csvwrite("figures/"+Kernel+"/"+name+"/fieldprecict/bestpoint/"+string_type+scan_rate+"bestpoint.csv",...
                    %    "bestpoint");
                    zzmax=ceil(max(draw_z)/100)*100;
                    cmax=max(zzmax,400);
                    cb_title="C_s_p (F/g)";
                elseif ntypefig==2
                    draw_z=predict_rsd;
                    string_type="precictrSD";
                    zzmax=ceil(max(draw_z)*10)/10;
                    cmax=min(1,max(zzmax,0.5));
                    cb_title = "Relative SD";
                elseif ntypefig==3
                    draw_z=predict_Asd;
                    string_type="precictASD";
                    zzmax=ceil(max(draw_z)/100)*100;
                    cmax=min(400,max(zzmax,100));
                    cb_title = "SD of C_s_p (F/g)";
                elseif ntypefig==4
                    if nii>=2
                        draw_z=cell_target_predict_scanrate{nii}./cell_target_predict_scanrate{nii-1};
                        string_type="Ratio C_s_p";
                        zzmax=ceil(max(draw_z)*10)/10;
                        zzmin=floor(min(draw_z)*10)/10;
                        cmax=2;...(min(zzmax,2),1);
                        cmin=0;...min(max(zzmin,0),0.5);
                        cb_title="Ratio pred";
                    else
                        continue;
                    end
                end
                z_gpr = [input(:,2:3) draw_z];
                Z_i=griddata(z_gpr(:,1),z_gpr(:,2),z_gpr(:,3),X_i,Y_i);
                %figure('Position',[100 100 600 450]);
                pcolor(X_i,Y_i,Z_i);
                colormap(jet);
                if ntypefig ~= 4
                    cmin=0;
                end
                caxis([cmin cmax]);
                cb=colorbar;
                cb.Title.String = cb_title;
                cb.Title.FontSize = legendFontSize;
                arrayfun(@(s) set(s,'EdgeColor','none'), findobj(gcf,'type','surface'))
                axis_title=title(name1+newline+string_type+" "+", scan rate="+scan_rate,'FontSize',titleFontSize);
                axis_title.Position=axis_title.Position+[0 200 0];
                hold on;
                [conM,confield]=contour(X_i,Y_i,Z_i,"k");
                if ntypefig==4 
                    [conM1,confield1]=contour(X_i,Y_i,Z_i,[1 1],"r",'LineWidth',4);
                    cm_temp=colormap;
                    cm_cut=colormap;
                    cm_cut(size(cm_temp,1)/2+1:end,:)=cm_cut(size(cm_temp,1)/2+1:end,:)/2;
                    cm_cut(size(cm_temp,1)/2+1:end,1)=1;
                    colormap((cm_temp+cm_cut)/2);
                end 
                hold off;
                xlabel("S Micro (m^2/g)",'FontSize',labelFontSize)
                ylabel("S Meso (m^2/g)",'FontSize',labelFontSize)

                ax=gca;
                Fun_Axislinefontsize(ax,axisFontSize,axislinewidth)
                ax.TickDir = 'out';
                Fun_AxisTicksformat(ax,0:250:1500,0:250:1500);
                [~,~]=mkdir("figures/"+Kernel+"/"+name+"/fieldprecict/"+string_type+"/");
                fig1=gcf;
                set(fig1,'Position',[100 100 600 450]);
                newpos=fig1.Position/100;
                set(fig1,'Paperunits',"inches","Paperposition",newpos);
                saveas(gcf,"figures/"+Kernel+"/"+name+"/fieldprecict/"+string_type+"/"+string_type+scan_rate+".fig");
                print(fig1,"figures/"+Kernel+"/"+name+"/fieldprecict/"+string_type+"/"+string_type+scan_rate+".jpg","-djpeg",'-r100');
                close all;
            end
           
            
        end
        save("figures/"+Kernel+"/"+name+"/fieldprecict/"+"cell_target_predict_scanrate.mat","cell_target_predict_scanrate")
    end
end