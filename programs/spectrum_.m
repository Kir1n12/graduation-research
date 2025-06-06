clear all;
close all;
fs = 48000;
dft_size = 65536;
lifter_size = 400;
range = 13120;

% 入力ファイル名を指定
filename = 'c_data/11_N_I_P.wav';

% WAVファイルの読み込み
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
w = HanningWindow_(dft_size);
x = x(1:dft_size) .* w;
X = fft(x, dft_size);
A_dft = 20 * log10(abs(X(1:range)));

% 1つのフィギュアに2つのサブプロット
figure(1);

% サブプロット2: DFTスペクトル
subplot(2,1,1);
plot(frequency, A_dft, 'm','LineWidth', 0.8);
title('Spectrum', 'FontSize', 14);
xlabel('Frequency [Hz]', 'FontSize', 14);
ylabel('Magnitude (dB)', 'FontSize', 14);
set(gca, 'FontSize', 12, 'XScale', 'log');
xticks([20 50 100 200 500 1e3 2e3 5e3 10e3 20e3]);
xticklabels({'20', '50', '100', '200', '500', '1k', '2k', '5k', '10k', '20k'});
xlim([20 10000]);
ylim([-60 75]);
grid on;

% サブプロット1: スペクトル包絡
subplot(2,1,2);
plot(frequency, A, '-b', 'LineWidth', 0.8);
title('Cepstrum', 'FontSize', 14);
xlabel('Quefrency [Hz]', 'FontSize', 14);
ylabel('Magnitude (dB)', 'FontSize', 14);
set(gca, 'FontSize', 12, 'XScale', 'log');
xticks([20 50 100 200 500 1e3 2e3 5e3 10e3 20e3]);
xticklabels({'20', '50', '100', '200', '500', '1k', '2k', '5k', '10k', '20k'});
xlim([20 10000]);
ylim([-60 30]);
grid on;



% 画像として保存
saveas(figure(1), fullfile('fullpass', 'result_3_C_combined.png'));

