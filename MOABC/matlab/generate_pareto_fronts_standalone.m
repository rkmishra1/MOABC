%% generate_pareto_fronts_standalone.m
% Standalone script to generate Pareto front plots for ZDT1.
% Does NOT depend on GLOBAL/INDIVIDUAL classes.
% Run from the matlab/ directory.
%
% Usage:
%   generate_pareto_fronts_standalone

function generate_pareto_fronts_standalone()

    results_dir = fullfile('..', 'results');
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end

    rng(42);  % reproducibility

    %% Problem settings
    M = 2;     % objectives
    D = 30;    % decision variables
    N = 100;   % population size
    MaxEval = 10000;
    T = 20;    % neighbourhood size

    %% True Pareto Front
    f1_true = linspace(0, 1, 1000)';
    f2_true = 1 - sqrt(f1_true);
    PF = [f1_true, f2_true];

    %% ZDT1 objective function
    zdt1 = @(x) deal( ...
        x(:,1), ...
        (1 + 9*sum(x(:,2:end),2)) .* (1 - sqrt(x(:,1) ./ (1 + 9*sum(x(:,2:end),2)))) ...
    );

    agg_names = {'PBI', 'Tchebycheff', 'Normalised_Tchebycheff', 'Modified_Tchebycheff'};
    all_results = cell(4,1);

    for agg_type = 1:4
        fprintf('Running MOEAD-ABC with %s (type=%d)...\n', agg_names{agg_type}, agg_type);

        %% Weight vectors
        [W, N_actual] = UniformPoint(N, M);
        N = N_actual;

        %% Neighbourhood
        B_dist = pdist2(W, W);
        [~, B_sorted] = sort(B_dist, 2);
        B = B_sorted(:, 1:T);

        %% Initialise population
        PopDec = rand(N, D);  % uniform in [0,1]^D
        [obj1, obj2] = zdt1(PopDec);
        PopObj = [obj1, obj2];
        Z = min(PopObj, [], 1);  % ideal point

        %% Main loop
        eval_count = N;
        while eval_count < MaxEval
            for i = 1:N
                P = B(i,:);

                % Fitness-proportionate selection
                neighbour_objs = PopObj(P,:);
                Zmax = max(PopObj, [], 1);
                denom = Zmax - Z;
                denom(denom == 0) = 1e-10;
                te = max(abs(neighbour_objs - repmat(Z,T,1)) ./ repmat(denom,T,1) ./ W(i,:), [], 2);
                mean_cost = mean(te);

                if mean_cost == 0
                    m = randi(T);
                else
                    F = exp(-te / mean_cost);
                    prob = F / sum(F);
                    m = SelfRouletteWheelSelection(prob);
                end

                % Choose k != m
                idx = randperm(T);
                while idx(1) == m
                    idx = randperm(T);
                end
                k = B(i, idx(1));

                % ABC offspring
                phi = unifrnd(-1, 1, [1, D]);
                offspring = PopDec(B(i,m),:) + phi .* (PopDec(B(i,m),:) - PopDec(k,:));

                % Polynomial mutation
                mu_pm = 20;
                for ii = 1:D
                    if rand < 1/D
                        r = rand;
                        if r < 0.5
                            delta = (2*r)^(1/(1+mu_pm)) - 1;
                        else
                            delta = 1 - (2*(1-r))^(1/(mu_pm+1));
                        end
                        offspring(ii) = offspring(ii) + delta;
                    end
                end

                % Clamp to [0,1]
                offspring = max(min(offspring, 1), 0);

                % Evaluate offspring
                [o1, o2] = zdt1(offspring);
                off_obj = [o1, o2];
                eval_count = eval_count + 1;

                % Update ideal point
                Z = min(Z, off_obj);

                % Update neighbours
                switch agg_type
                    case 1  % PBI
                        normW   = sqrt(sum(W(P,:).^2, 2));
                        normP   = sqrt(sum((PopObj(P,:) - repmat(Z,T,1)).^2, 2));
                        normO   = sqrt(sum((off_obj - Z).^2));
                        CosP = sum((PopObj(P,:) - repmat(Z,T,1)) .* W(P,:), 2) ./ normW ./ max(normP, 1e-30);
                        CosO = sum(repmat(off_obj - Z, T, 1) .* W(P,:), 2) ./ normW ./ max(normO, 1e-30);
                        g_old = normP .* CosP + 5 * normP .* sqrt(max(1 - CosP.^2, 0));
                        g_new = normO .* CosO + 5 * normO .* sqrt(max(1 - CosO.^2, 0));
                    case 2  % Tchebycheff
                        g_old = max(abs(PopObj(P,:) - repmat(Z,T,1)) .* W(P,:), [], 2);
                        g_new = max(repmat(abs(off_obj - Z), T, 1) .* W(P,:), [], 2);
                    case 3  % Normalised Tchebycheff
                        Zm = max([PopObj; off_obj], [], 1);
                        dn = Zm - Z; dn(dn==0) = 1e-10;
                        g_old = max(abs(PopObj(P,:) - repmat(Z,T,1)) ./ repmat(dn,T,1) ./ W(P,:), [], 2);
                        g_new = max(repmat(abs(off_obj - Z) ./ dn, T, 1) ./ W(P,:), [], 2);
                    case 4  % Modified Tchebycheff
                        g_old = max(abs(PopObj(P,:) - repmat(Z,T,1)) ./ W(P,:), [], 2);
                        g_new = max(repmat(abs(off_obj - Z), T, 1) ./ W(P,:), [], 2);
                end

                replace_idx = P(g_old >= g_new);
                PopDec(replace_idx,:) = repmat(offspring, length(replace_idx), 1);
                PopObj(replace_idx,:) = repmat(off_obj, length(replace_idx), 1);

                if eval_count >= MaxEval
                    break;
                end
            end
        end

        all_results{agg_type} = PopObj;

        %% IGD
        dist = min(pdist2(PF, PopObj), [], 2);
        igd_val = mean(dist);
        fprintf('  IGD = %.6f\n', igd_val);

        %% Save individual plot
        fig = figure('Visible', 'off', 'Position', [100 100 800 600]);
        hold on;
        plot(f1_true, f2_true, 'b-', 'LineWidth', 1.5, 'DisplayName', 'True PF');
        scatter(PopObj(:,1), PopObj(:,2), 30, 'r', 'filled', ...
            'MarkerEdgeColor', [0.6 0 0], 'DisplayName', 'MOEAD-ABC');
        xlabel('f_1', 'FontSize', 14);
        ylabel('f_2', 'FontSize', 14);
        title(sprintf('MOEAD-ABC on ZDT1 — %s  (IGD=%.4e)', ...
            strrep(agg_names{agg_type}, '_', ' '), igd_val), 'FontSize', 15);
        legend('Location', 'northeast', 'FontSize', 12);
        grid on; set(gca, 'FontSize', 12);
        hold off;
        fname = sprintf('ZDT1_MOEADABC_%s.png', agg_names{agg_type});
        saveas(fig, fullfile(results_dir, fname));
        close(fig);
        fprintf('  Saved: %s\n', fname);

        % Save CSV
        csv_fname = sprintf('ZDT1_MOEADABC_%s_objectives.csv', agg_names{agg_type});
        csvwrite(fullfile(results_dir, csv_fname), PopObj);
    end

    %% True PF plot
    fig = figure('Visible', 'off', 'Position', [100 100 800 600]);
    plot(f1_true, f2_true, 'b-', 'LineWidth', 2);
    xlabel('f_1', 'FontSize', 14); ylabel('f_2', 'FontSize', 14);
    title('True Pareto Front — ZDT1', 'FontSize', 16);
    grid on; set(gca, 'FontSize', 12);
    saveas(fig, fullfile(results_dir, 'ZDT1_true_pareto_front.png'));
    close(fig);
    fprintf('Saved: ZDT1_true_pareto_front.png\n');

    %% Combined comparison plot
    fig = figure('Visible', 'off', 'Position', [100 100 1000 800]);
    colors = lines(4);
    hold on;
    plot(f1_true, f2_true, 'k-', 'LineWidth', 2, 'DisplayName', 'True PF');
    for agg_type = 1:4
        data = all_results{agg_type};
        scatter(data(:,1), data(:,2), 25, colors(agg_type,:), 'filled', ...
            'MarkerEdgeColor', colors(agg_type,:)*0.7, ...
            'DisplayName', strrep(agg_names{agg_type}, '_', ' '));
    end
    xlabel('f_1', 'FontSize', 14); ylabel('f_2', 'FontSize', 14);
    title('MOEAD-ABC on ZDT1 — All Aggregation Types Compared', 'FontSize', 16);
    legend('Location', 'northeast', 'FontSize', 11);
    grid on; set(gca, 'FontSize', 12);
    hold off;
    saveas(fig, fullfile(results_dir, 'ZDT1_MOEADABC_comparison.png'));
    close(fig);
    fprintf('Saved: ZDT1_MOEADABC_comparison.png\n');

    fprintf('\n=== All done! ===\n');
    fprintf('Results saved to: %s\n', results_dir);
    fprintf('\nTo commit and push:\n');
    fprintf('  cd %s\n', fullfile('..'));
    fprintf('  git add results/ matlab/generate_pareto_fronts.m matlab/generate_pareto_fronts_standalone.m\n');
    fprintf('  git commit -m "Add Pareto front results for ZDT1"\n');
    fprintf('  git push\n');
end
