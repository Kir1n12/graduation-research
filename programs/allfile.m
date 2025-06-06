clear all;
close all;

input_dir = 'c_data'; % 入力フォルダ
save_dir = 'png'; % 保存先ディレクトリ
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

% フォルダ内のすべてのWAVファイルを取得
wav_files = dir(fullfile(input_dir, '*.wav'));

fs = 48000;
dft_size = 65536;
lifter_size = 400;
range = 13120;

for i = 1:length(wav_files)
    filename = wav_files(i).name;
    filepath = fullfile(input_dir, filename);
    save_combined = fullfile(save_dir, strrep(filename, '.wav', '_combined.png'));

    % WAVファイルの読み込み
    [x, fs] = audioread(filepath);

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
    figure;

    % DFTスペクトル
    subplot(2,1,1);
    plot(frequency, A_dft, 'm', 'LineWidth', 0.8);
    title(['spectrum: ', filename], 'FontSize', 14);
    xlabel('Frequency [Hz]', 'FontSize', 14);
    ylabel('Amplitude (dB)', 'FontSize', 14);
    set(gca, 'XScale', 'log');
    xticks([20 50 100 200 500 1e3 2e3 5e3 10e3 20e3]);
    xticklabels({'20', '50', '100', '200', '500', '1k', '2k', '5k', '10k', '20k'});
    xlim([20 10000]);
    ylim([-60 75]);
    grid on;

    % スペクトル包絡
    subplot(2,1,2);
    plot(frequency, A, '-b', 'LineWidth', 0.8);
    title(['cepstrum: ', filename], 'FontSize', 14);
    xlabel('Frequency [Hz]', 'FontSize', 14);
    ylabel('Amplitude (dB)', 'FontSize', 14);
    set(gca, 'XScale', 'log');
    xticks([20 50 100 200 500 1e3 2e3 5e3 10e3 20e3]);
    xticklabels({'20', '50', '100', '200', '500', '1k', '2k', '5k', '10k', '20k'});
    xlim([20 10000]);
    ylim([-60 60]);
    grid on;



    % 画像として保存
    saveas(gcf, save_combined);
    close;
end

