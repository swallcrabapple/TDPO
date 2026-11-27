
clear; clc; close all;

N_list = [20, 40, 60, 80, 100];
num_d = 2; 

alfa1 = 0.1;
beta1 = 2.4;   
theta1 = 0.99;  
tBegin = 0;   tFinal = 100; 
dT = 0.05;      
times = round((tFinal-tBegin)/dT);
tlen = times + 1;


figureHandle1 = figure(1);
set(gcf,'Units','centimeters','Position',[5,5,18,14]);
hold on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10, 'GridLineStyle', ':', 'GridAlpha', 0.5);
grid on;


colors = [0.8500 0.3250 0.0980;
          0.0000 0.4470 0.7410;
          0.9290 0.6940 0.1250;
          0.4660 0.6740 0.1880;
          0.4940 0.1840 0.5560];

plot_handles = [];
legend_strs = {};

for idx = 1:length(N_list)
    num_a = N_list(idx);
    fprintf('Topology: N = %d ...\n', num_a);

    Ad = zeros(num_a, num_a);
    d_neighbors = 2;  
    for i = 1:num_a
        for step = 1:d_neighbors
            j1 = mod(i - 1 + step, num_a) + 1;
            j2 = mod(i - 1 - step, num_a) + 1;
            Ad(i,j1) = 1;
            Ad(i,j2) = 1;
        end
    end
    L = diag(sum(Ad, 2)) - Ad;
    ADJ1 = Ad;
    Ac1 = theta1 * ADJ1;
    W = eye(num_a) - dT * L; 

    H = cell(num_a, 1);
    B = cell(num_a, 1);
    p1 = cell(num_a, tlen+1); 
    p2 = cell(num_a, tlen+1); 
    p4 = cell(num_a, tlen+1); 

    sum_H = zeros(num_d, num_d);
    rng(502); 
    for i = 1:num_a
        A_temp = rand(2, 2);
        H{i} = A_temp'*A_temp + eye(2); 
        

        B{i} = randn(2,1) * 0.5; 
        sum_H = sum_H + H{i};

        p_init = randn(2,1) * 10;
        p1{i,1} = p_init;
        p2{i,1} = p_init;
        p4{i,1} = p_init;
    end

    mean_B = sum([B{:}], 2) / num_a;
    for i = 1:num_a
        B{i} = B{i} - mean_B;
    end
    opt_tar = [0; 0];

    u1_p1 = cell(num_a, tlen+1);
    df1_p1 = cell(num_a, tlen+1);
    u1_p2 = cell(num_a, tlen+1);
    df1_p2 = cell(num_a, tlen+1);

    for i = 1:num_a
        df1_p1{i,1} = H{i} * p1{i,1} + B{i};
        u1_p1{i,1} = -alfa1 * df1_p1{i,1};
        sum_adj1 = zeros(2,1);

        df1_p2{i,1} = H{i} * p2{i,1} + B{i};
        u1_p2{i,1} = -alfa1 * df1_p2{i,1};
        sum_adj2 = zeros(2,1);

        for j = 1:num_a
            if ADJ1(i,j) ~= 0
                sum_adj1 = sum_adj1 + ADJ1(i,j) * (out(p1{j,1},1) - out(p1{i,1},1));
                sum_adj2 = sum_adj2 + ADJ1(i,j) * (p2{j,1} - p2{i,1});
            end
        end
        u1_p1{i,1} = u1_p1{i,1} + beta1 * sum_adj1;
        p1{i,2} = p1{i,1} + dT * u1_p1{i,1};

        u1_p2{i,1} = u1_p2{i,1} + beta1 * sum_adj2;
        p2{i,2} = p2{i,1} + dT * u1_p2{i,1};
    end

    t(1) = 0; t(2) = dT;
    for k = 1:times
        t(k+1) = t(k) + dT;

        for i = 1:num_a
            df1_p1{i,k+1} = H{i} * p1{i,k+1} + B{i};
            u1_p1{i,k+1} = u1_p1{i,k} - alfa1 * (df1_p1{i,k+1} - df1_p1{i,k});
            sum_d1_p1 = zeros(2,1);

            df1_p2{i,k+1} = H{i} * p2{i,k+1} + B{i};
            u1_p2{i,k+1} = u1_p2{i,k} - alfa1 * (df1_p2{i,k+1} - df1_p2{i,k});
            sum_d1_p2 = zeros(2,1);

            sum_adj_p4 = zeros(2,1);

            for j = 1:num_a
                if ADJ1(i,j) ~= 0
                    d1_cur1 = ADJ1(i,j) * (out(p1{j,k+1},k+1) - out(p1{i,k+1},k+1));
                    dc1_pre1 = Ac1(i,j) * (out(p1{j,k},k) - out(p1{i,k},k));
                    sum_d1_p1 = sum_d1_p1 + beta1 * (d1_cur1 - dc1_pre1);

                    d1_cur2 = ADJ1(i,j) * (p2{j,k+1} - p2{i,k+1});
                    dc1_pre2 = Ac1(i,j) * (p2{j,k} - p2{i,k});
                    sum_d1_p2 = sum_d1_p2 + beta1 * (d1_cur2 - dc1_pre2);
                end

                if W(i,j) ~= 0
                    sum_adj_p4 = sum_adj_p4 + W(i,j) * p4{j,k};
                end
            end

            u1_p1{i,k+1} = u1_p1{i,k+1} + sum_d1_p1;
            p1{i,k+2} = p1{i,k+1} + dT * u1_p1{i,k+1};

            u1_p2{i,k+1} = u1_p2{i,k+1} + sum_d1_p2;
            p2{i,k+2} = p2{i,k+1} + dT * u1_p2{i,k+1};

            df1_p4_cur = H{i} * p4{i,k} + B{i};
            u4_cur = -alfa1 * df1_p4_cur;
            p4{i,k+1} = dT * u4_cur + sum_adj_p4;
        end
    end


    pxres1 = zeros(tlen,1);
    pxres2 = zeros(tlen,1);
    pxres4 = zeros(tlen,1);

    px0res = 0;
    for i=1:num_a
        px0res = px0res + norm(p1{i,1} - opt_tar)^2;
    end

    for k = 1:tlen
        sum1 = 0; sum2 = 0; sum4 = 0;
        for i = 1:num_a
            sum1 = sum1 + norm(p1{i,k} - opt_tar)^2;
            sum2 = sum2 + norm(p2{i,k} - opt_tar)^2;
            sum4 = sum4 + norm(p4{i,k} - opt_tar)^2;
        end
        pxres1(k) = sum1;
        pxres2(k) = sum2;
        pxres4(k) = sum4;
    end

    res1_log = log10(pxres1 / px0res);
    res2_log = log10(pxres2 / px0res);
    res4_log = log10(pxres4 / px0res);

    k_axis = (1:tlen)';

    h4 = plot(k_axis, res4_log, 'Color', colors(idx,:), 'LineWidth', 1.5, 'LineStyle', ':');
    h2 = plot(k_axis, res2_log, 'Color', colors(idx,:), 'LineWidth', 1.5, 'LineStyle', '-');
    h1 = plot(k_axis, res1_log, 'Color', colors(idx,:), 'LineWidth', 1.5, 'LineStyle', '--');

    plot_handles = [plot_handles, h4, h2, h1];
    legend_strs{end+1} = sprintf('DGD (N=%d)', num_a);
    legend_strs{end+1} = sprintf('EXTRA (N=%d)', num_a);
    legend_strs{end+1} = sprintf('MASK-EXTRA (N=%d)', num_a);
end


xlim([0, 2000]);
ylim([-10, 1]);
legend(plot_handles, legend_strs, 'NumColumns', 2, 'Location', 'southwest', 'FontSize', 9, 'FontName', 'Times New Roman');
xlabel('Iterations (k)', 'FontSize', 12, 'FontName', 'Times New Roman');
ylabel('Relative Residual (log_{10})', 'FontSize', 12, 'FontName', 'Times New Roman');
title('Scalability Analysis of EXTRA and DGD algorithms', 'FontSize', 14, 'FontName', 'Times New Roman');


function output=out(p,k)
    phi=0.6; sigma=0.3; gamma=0.6; deta=0.8;
    output=(1+phi*exp(-sigma*k))*(p+gamma*exp(-deta*k));
end