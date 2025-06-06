clear all;
close all;
fs = 48000;
dft_size = 65536;
lifter_size = 400;
range = 13120;

% 5つのWAVファイルのパスをリスト化
filenames = {'c_data/3_C.wav', 'c_data/3_C_10.wav', 'c_data/3_C_G.wav', 'c_data/3_C_P.wav'};
colors = {'m', 'b', 'g', 'r', 'k'}; % 各ファイルの色を指定
legend_labels = cell(1, length(filenames)); % 凡例用

% 図の準備
figure(1);
hold on;

% 短時間フーリエ変換用の窓関数
w = HanningWindow_(dft_size);

for i = 1:length(filenames)
    % WAVファイルを読み込む
    filename = filenames{i};
    [x, fs] = audioread(filename);

    % ケプストラム処理
    xc = Cepstrum_(x, dft_size);
    for m = lifter_size+1:dft_size/2+1
        xc(m) = 0;
        xc(dft_size+2-m) = 0;
    end
    Xc = fft(xc, dft_size);

    % スペクトル包絡の計算
    A = zeros(1, range);
    frequency = zeros(1, range);
    for k = 1:range
        A(k) = 20 * real(Xc(k));
        frequency(k) = (k-1) * fs / dft_size;
    end

    % DFT（短時間フーリエ変換）
    x = x(1:dft_size) .* w;
    X = fft(x, dft_size);
    A_dft = 20 * log10(abs(X(1:range)));

    % プロット（DFTスペクトル）
    subplot(2,1,1);
    plot(frequency, A_dft, 'Color', colors{i}, 'LineWidth', 0.8);
    hold on;

    % プロット（スペクトル包絡）
    subplot(2,1,2);
    plot(frequency, A, 'Color', colors{i}, 'LineWidth', 0.8);
    hold on;

    % ファイル名のみを凡例用ラベルに設定
    [~, name, ext] = fileparts(filename);
    legend_labels{i} = sprintf('%s%s', name, ext);
end

% サブプロット1: DFTスペクトル
subplot(2,1,1);
title('Spectrum', 'FontSize', 14);
xlabel('Frequency [Hz]', 'FontSize', 14);
ylabel('Magnitude (dB)', 'FontSize', 14);
set(gca, 'FontSize', 12, 'XScale', 'log');
xticks([20 50 100 200 500 1e3 2e3 5e3 10e3 20e3]);
xticklabels({'20', '50', '100', '200', '500', '1k', '2k', '5k', '10k', '20k'});
xlim([20 10000]);
ylim([-60 75]);
grid on;
legend(legend_labels, 'Location', 'northeastoutside');

% サブプロット2: スペクトル包絡
subplot(2,1,2);
title('Cepstrum', 'FontSize', 14);
xlabel('Quefrency [Hz]', 'FontSize', 14);
ylabel('Magnitude (dB)', 'FontSize', 14);
set(gca, 'FontSize', 12, 'XScale', 'log');
xticks([20 50 100 200 500 1e3 2e3 5e3 10e3 20e3]);
xticklabels({'20', '50', '100', '200', '500', '1k', '2k', '5k', '10k', '20k'});
xlim([20 10000]);
ylim([-60 60]);
grid on;
legend(legend_labels, 'Location', 'northeastoutside');

% 画像として保存
saveas(figure(1), fullfile('png', 'comp_3_C_setti.png'));

hold off;

