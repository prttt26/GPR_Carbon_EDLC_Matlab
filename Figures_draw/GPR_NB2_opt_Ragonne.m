%run("GPR_newbasis2.m")

space = 10;
a = 0:space:1500;
b = 250:space:1500;

linewidth=2;
labelFontSize=22;
legendFontSize=20;
titleFontSize=22;
axisFontSize=20;
axislinewidth=linewidth;


scan_range = linspace(5,50,10);
for ni=1:length(param(2).Range)
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
        [~,~]=mkdir("figures/"+Kernel+"/"+name+"/Ragonne/");
        
        %save mean prediction

        %predict for different input
        input = zeros(length(a)*length(b)*length(scan_range), 3);
        energy_result = zeros(length(a)*length(b)*length(scan_range), 1);
        power_result = zeros(length(a)*length(b)*length(scan_range), 1);
        nj = 0;
        for nk=1:length(scan_range)
            scan_rate = scan_range(nk);
        
            for ii = min(a):space:max(a)
                for jj = min(b):space:max(b)
                    nj = nj + 1;
                    input(nj,:) = [ scan_rate ii jj  ];
                end
            end
        end

        %predict
        x=min(a):space:max(a);
        y= min(b):space:max(b);
        [X_i, Y_i]=meshgrid(x,y);
        [target_predict_gpr, predict_Asd,  predict_rsd]=Fun_predict_NB2(gprMdl_now,input);
        %predict=target_predict_gpr;
        energy_result = target_predict_gpr/8/3.6;
        power_result= energy_result.*input(:,1)*3.6;
        energy_result=[energy_result;energy_result/1.1];
        power_result=[power_result;power_result/10];

        save("figures/"+Kernel+"/"+name+"/Ragonne/"+"Ragonne.mat","energy_result","power_result")

        k = 0;
        for ii = 1:length(energy_result)
            if ((energy_result(ii) > 0) && (power_result(ii) > 3) && (energy_result(ii) < 1e22))
                k = k + 1;
            end
        end
        energy_filter = zeros(k,1);
        power_filter = zeros(k,1);
        

        k = 0;
        for ii = 1:length(energy_result)
            if ((energy_result(ii) > 0) && (power_result(ii) > 3) && (energy_result(ii) < 1e22))
                k = k + 1;
                energy_filter(k,1) = energy_result(ii);
                power_filter(k,1) = power_result(ii);
            end
        end

        maxIndex = [0;0];
        max_energy =[0;0];max_power = [0;0];
        
        for ii = 1:length(energy_filter)
            if (energy_filter(ii) > max_energy(1))
                %if (power_filter(ii) > max_power(1))
                    maxIndex(1) = ii;
                    max_power(1) = power_filter(ii);
                    max_energy(1) = energy_filter(ii);
                    
                %end
            end
        end


        for ii = 1:length(energy_filter)
            if (power_filter(ii) > max_power(2))
                %if (energy_filter(ii) > max_energy(2))
                    maxIndex(2) = ii;
                    max_power(2) = power_filter(ii);
                    max_energy(2) = energy_filter(ii);
                    
                %end
            end
        end
        save("figures/"+Kernel+"/"+name+"/Ragonne/"+"MaxEnergy.txt","max_energy","max_power",'-ascii')
        
        
        close all;
        plot(energy_filter,power_filter,"k.");
        k = boundary(energy_filter, power_filter,0.5);
        hold on;
        bound=[energy_filter(k),power_filter(k)];
        plot(energy_filter(k),power_filter(k),"r-","LineWidth",2);
        plotMax=plot(max_energy,max_power,...
            'LineStyle','none',"Color","red","Marker","pentagram","MarkerSize",14);
        hold off;
        xlabel("Energy density (Wh/kg)",'FontSize',labelFontSize)
        ylabel("Power density (Wh/kg)",'FontSize',labelFontSize)
        ax=gca;
        Fun_Axislinefontsize(ax,axisFontSize,axislinewidth)
        saveas(gcf,"figures/"+Kernel+"/"+name+"/Ragonne/"+"Ragonne.fig");
        saveas(gcf,"figures/"+Kernel+"/"+name+"/Ragonne/"+"Ragonne.jpg");

        save("figures/"+Kernel+"/"+name+"/Ragonne/"+"bound.txt","bound",'-ascii')
    end
end