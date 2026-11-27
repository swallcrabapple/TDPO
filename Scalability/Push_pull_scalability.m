
clear; clc; close all;

alfa = 0.1; 
N_list = [20, 40, 60, 80, 100]; 
num_d = 3; 
tlen = 1601; 
figureHandle = figure(1);
set(gcf,'Units','centimeters','Position',[5,5,15,12])
hold on;


colors = [0.8500 0.3250 0.0980;  
          0.0000 0.4470 0.7410;  
          0.9290 0.6940 0.1250;  
          0.4660 0.6740 0.1880;  
          0.4940 0.1840 0.5560]; 
legend_strs = {};
plot_handles = []; 

for idx = 1:length(N_list)
    num_a = N_list(idx);
    fprintf('Topology: N = %d ...\n', num_a);
    

    R = zeros(num_a, num_a);
    d_neighbors = 4; 
    for i = 1:num_a
        for step = -d_neighbors : d_neighbors
            j = mod(i - 1 + step, num_a) + 1;
            R(i,j) = 1 / (2 * d_neighbors + 1);
        end
    end
    C = R'; 

    H = cell(num_a, 1);
    B = cell(num_a, 1);
    p1 = cell(num_a, tlen); 
    p2 = cell(num_a, tlen); 
    y1 = cell(num_a, tlen);
    y2 = cell(num_a, tlen);
    df1 = cell(num_a, tlen);
    df2 = cell(num_a, tlen);

    sum_H = zeros(num_d, num_d);
    
    rng(42); 
    for i = 1:num_a
        A_temp = diag(rand(3,1)*0.5 + 0.2); 
        H{i} = A_temp + A_temp'; 
        B{i} = randn(3,1) * 2;
        sum_H = sum_H + H{i};
        
        p_init = randn(3,1) * 10;
        p1{i,1} = p_init;
        p2{i,1} = p_init;
    end
    
    mean_B = sum([B{:}], 2) / num_a;
    for i = 1:num_a
        B{i} = B{i} - mean_B;
        df1{i,1} = H{i} * p1{i,1} + B{i};
        y1{i,1}  = df1{i,1};
        df2{i,1} = H{i} * p2{i,1} + B{i};
        y2{i,1}  = df2{i,1};
    end
    opt_tar = [0; 0; 0]; 

    for k = 1:tlen-1
   
        for i = 1:num_a
            p1{i,k+1} = zeros(3,1);
            for j = 1:num_a 
                if R(i,j) ~= 0 
                    p1{i,k+1} = p1{i,k+1} + R(i,j)*(p1{j,k} - alfa*y1{j,k});
                end
            end 
            df1{i,k+1} = H{i} * p1{i,k+1} + B{i};
            
            sum_y = zeros(3,1);
            for j = 1:num_a
                if C(i,j) ~= 0
                    sum_y = sum_y + C(i,j)*y1{j,k};
                end
            end
            y1{i,k+1} = sum_y + df1{i,k+1} - df1{i,k};
        end
        

        for i = 1:num_a
            p2{i,k+1} = zeros(3,1);
            for j = 1:num_a
                if R(i,j) ~= 0
                    p2{i,k+1} = p2{i,k+1} + R(i,j)*(out(p2{j,k},k) - alfa*y2{j,k});
                end
            end
            df2{i,k+1} = H{i} * p2{i,k+1} + B{i};
            
            sum_y = zeros(3,1);
            for j = 1:num_a
                if C(i,j) ~= 0
                    sum_y = sum_y + C(i,j)*y2{j,k};
                end
            end
            y2{i,k+1} = sum_y + df2{i,k+1} - df2{i,k};
        end
    end


    pxres1 = zeros(tlen,1);
    pxres2 = zeros(tlen,1);
    pxres_init = 0;
    for i = 1:num_a
        pxres_init = pxres_init + norm(p1{i,1} - opt_tar)^2;
    end

    for k = 1:tlen
        sum1 = 0; sum2 = 0;
        for i = 1:num_a
            sum1 = sum1 + norm(p1{i,k} - opt_tar)^2;
            sum2 = sum2 + norm(p2{i,k} - opt_tar)^2;
        end
        pxres1(k) = sum1;
        pxres2(k) = sum2;
    end  
    
    res1_log = log10(pxres1 / pxres_init);
    res2_log = log10(pxres2 / pxres_init);

    k_axis = (1:tlen)';
    
    h1 = plot(k_axis, res1_log, 'Color', colors(idx,:), 'LineWidth', 1.5, 'LineStyle', '-');
    h2 = plot(k_axis, res2_log, 'Color', colors(idx,:), 'LineWidth', 1.5, 'LineStyle', '--');
    
    plot_handles = [plot_handles, h1, h2];
    legend_strs{end+1} = sprintf('Push-pull Scheme (N=%d)', num_a);
    legend_strs{end+1} = sprintf('Our Scheme (N=%d)', num_a);
end
set(gca,'FontName','Times New Roman');
xlim([0, 1600]); 
ylim([-20, 5]); 
legend(plot_handles, legend_strs, 'NumColumns', 1, 'Location', 'southwest', 'FontSize', 10);
xlabel('Iterations (k)', 'FontSize', 12);
ylabel('Mean Squared Residual (log_{10})', 'FontSize', 12);
title('Scalability Analysis', 'FontSize', 14);
grid on; set(gca,'GridLineStyle',':','GridAlpha',0.5);



function output = out(p,k)
    phi = 0.1; sigma = 0.1; gamma = 0.4; deta = 0.2;
    output = (1 + phi*exp(-sigma*k)) * (p + gamma*exp(-deta*k));
end