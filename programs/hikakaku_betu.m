clear all;
close all;
fs = 48000;
dft_size = 65536;
lifter_size = 400;
range = 13120;

% 画面サイズ取得
screen_size = get(0, 'ScreenSize');
fig_width = screen_size(3);
fig_height = screen_size(4);

% 5つのWAVファイルのパスをリスト化
filenames = {'c_data/7_N.wav', 'c_data/7_N_10.wav', 'c_data/7_N_G.wav', 'c_data/7_N_P.wav'};
colors = {'m', 'b', 'g', 'r', 'k'}; % 各ファイルの色を指定
legend_labels = cell(1, length(filenames)); % 凡例用

% 短時間フーリエ変換用の窓関数
w = HanningWindow_(dft_size);

% スペクトルプロット
figure('Position', [0, 0, fig_width, fig_height]); % フルスクリーン
hold on;
for i = 1:length(filenames)
    filename = filenames{i};
    [x, fs] = audioread(filename);

    x = x(1:dft_size) .* w;
    X = fft(x, dft_size);
    A_dft = 20 * log10(abs(X(1:range)));
    frequency = (0:range-1) * fs / dft_size;

    plot(frequency, A_dft, 'Color', colors{i}, 'LineWidth', 0.8);

    [~, name, ext] = fileparts(filename);
    legend_labels{i} = sprintf('%s%s', name, ext);
end

title('Spectrum', 'FontSize', 14);
xlabel('Frequency [Hz]', 'FontSize', 14);
ylabel('Magnitude (dB)', 'FontSize', 14);
set(gca, 'FontSize', 12, 'XScale', 'log');
xticks([20 50 100 200 500 1e3 2e3 5e3 10e3 20e3]);
xticklabels({'20', '50', '100', '200', '500', '1k', '2k', '5k', '10k', '20k'});
xlim([20 10000]);
ylim([-60 75]);
grid on;
legend(legend_labels, 'Location', 'northeast', 'FontSize', 8);

saveas(gcf, fullfile('png/comp', 'comp_setti_7_N_spectrum.png'));
hold off;

% スペクトル包絡プロット
figure('Position', [0, 0, fig_width, fig_height]); % フルスクリーン
hold on;
for i = 1:length(filenames)
    filename = filenames{i};
    [x, fs] = audioread(filename);

    xc = Cepstrum_(x, dft_size);
    for m = lifter_size+1:dft_size/2+1
        xc(m) = 0;
        xc(dft_size+2-m) = 0;
    end
    Xc = fft(xc, dft_size);

    A = 20 * real(Xc(1:range));
    frequency = (0:range-1) * fs / dft_size;

    plot(frequency, A, 'Color', colors{i}, 'LineWidth', 0.8);
end

title('Cepstrum', 'FontSize', 14);
xlabel('Quefrency [Hz]', 'FontSize', 14);
ylabel('Magnitude (dB)', 'FontSize', 14);
set(gca, 'FontSize', 12, 'XScale', 'log');
xticks([20 50 100 200 500 1e3 2e3 5e3 10e3 20e3]);
xticklabels({'20', '50', '100', '200', '500', '1k', '2k', '5k', '10k', '20k'});
xlim([20 10000]);
ylim([-60 60]);
grid on;
legend(legend_labels, 'Location', 'northeast', 'FontSize', 8);

saveas(gcf, fullfile('png/comp', 'comp_setti_7_N_cepstrum.png'));
hold off;

