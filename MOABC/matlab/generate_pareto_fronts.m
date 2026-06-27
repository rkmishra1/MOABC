%% generate_pareto_fronts.m
% Generates Pareto front plots for ZDT1 using MOEAD-ABC with all 4
% aggregation types, saves figures as PNG images in results/ directory.
%
% Usage (from the matlab/ directory):
%   generate_pareto_fronts

function generate_pareto_fronts()
    % Create output directory
    results_dir = fullfile('..', 'results');
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end

    %% ---- True Pareto Front for ZDT1 ----
    f1 = linspace(0, 1, 1000)';
    f2 = 1 - sqrt(f1);
    fig = figure('Visible', 'off', 'Position', [100 100 800 600]);
    plot(f1, f2, 'b-', 'LineWidth', 2);
    xlabel('f_1', 'FontSize', 14);
    ylabel('f_2', 'FontSize', 14);
    title('True Pareto Front — ZDT1', 'FontSize', 16);
    grid on;
    set(gca, 'FontSize', 12);
    saveas(fig, fullfile(results_dir, 'ZDT1_true_pareto_front.png'));
    close(fig);
    fprintf('Saved: ZDT1_true_pareto_front.png\n');

    %% ---- Run MOEAD-ABC with each aggregation type ----
    agg_names = {'PBI', 'Tchebycheff', 'Normalised_Tchebycheff', 'Modified_Tchebycheff'};

    for agg_type = 1:4
        fprintf('Running MOEAD-ABC with %s (type=%d)...\n', agg_names{agg_type}, agg_type);

        % Create GLOBAL object and run
        Global = GLOBAL( ...
            '-algorithm', {@MOEADABC, agg_type}, ...
            '-problem', @ZDT1, ...
            '-N', 100, ...
            '-M', 2, ...
            '-evaluation', 10000 ...
        );
        Global.Start();

        % Extract the final population
        if ~isempty(Global.result)
            Population = Global.result{end, 2};
            PopObj = Population.objs;

            % Plot obtained front vs true front
            fig = figure('Visible', 'off', 'Position', [100 100 800 600]);
            hold on;
            plot(f1, f2, 'b-', 'LineWidth', 1.5, 'DisplayName', 'True PF');
            scatter(PopObj(:,1), PopObj(:,2), 30, 'r', 'filled', ...
                'MarkerEdgeColor', [0.6 0 0], 'DisplayName', 'MOEAD-ABC');
            xlabel('f_1', 'FontSize', 14);
            ylabel('f_2', 'FontSize', 14);
            title(sprintf('MOEAD-ABC on ZDT1 — %s', strrep(agg_names{agg_type}, '_', ' ')), ...
                'FontSize', 16);
            legend('Location', 'northeast', 'FontSize', 12);
            grid on;
            set(gca, 'FontSize', 12);
            hold off;

            fname = sprintf('ZDT1_MOEADABC_%s.png', agg_names{agg_type});
            saveas(fig, fullfile(results_dir, fname));
            close(fig);
            fprintf('Saved: %s\n', fname);

            % Also save the objective data as CSV
            csv_fname = sprintf('ZDT1_MOEADABC_%s_objectives.csv', agg_names{agg_type});
            csvwrite(fullfile(results_dir, csv_fname), PopObj);
            fprintf('Saved: %s\n', csv_fname);
        end
    end

    %% ---- Combined comparison plot ----
    fig = figure('Visible', 'off', 'Position', [100 100 1000 800]);
    colors = lines(4);
    hold on;
    plot(f1, f2, 'k-', 'LineWidth', 2, 'DisplayName', 'True PF');

    for agg_type = 1:4
        csv_fname = sprintf('ZDT1_MOEADABC_%s_objectives.csv', agg_names{agg_type});
        fpath = fullfile(results_dir, csv_fname);
        if exist(fpath, 'file')
            data = csvread(fpath);
            scatter(data(:,1), data(:,2), 25, colors(agg_type,:), 'filled', ...
                'MarkerEdgeColor', colors(agg_type,:) * 0.7, ...
                'DisplayName', strrep(agg_names{agg_type}, '_', ' '));
        end
    end

    xlabel('f_1', 'FontSize', 14);
    ylabel('f_2', 'FontSize', 14);
    title('MOEAD-ABC on ZDT1 — All Aggregation Types', 'FontSize', 16);
    legend('Location', 'northeast', 'FontSize', 11);
    grid on;
    set(gca, 'FontSize', 12);
    hold off;
    saveas(fig, fullfile(results_dir, 'ZDT1_MOEADABC_comparison.png'));
    close(fig);
    fprintf('Saved: ZDT1_MOEADABC_comparison.png\n');

    fprintf('\nAll Pareto front plots saved to: %s\n', results_dir);
    fprintf('To push to GitHub, run:\n');
    fprintf('  git add results/ && git commit -m "Add Pareto front results" && git push\n');
end
