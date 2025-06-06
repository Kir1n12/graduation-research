pkg load signal;

% ファイルの読み込み
[file, fs] = audioread("c_data/3_C.wav");

% モノラル変換（ステレオの場合）
if columns(file) > 1
    file = mean(file, 2);
endif

% ヒルベルト変換でエンベロープを取得
analytic_signal = hilbert(file);
envelope = abs(analytic_signal);

% エンベロープを正規化しdB変換
envelope_db = 20 * log10(envelope / max(envelope));

% 時間軸の計算
time = (0:length(file)-1) / fs;

% 最大値の位置を取得
[max_value, max_index] = max(envelope_db);
max_time = time(max_index);

% -60dB に到達する最初の時刻を取得
threshold_db = -60;
idx_below_threshold = find(envelope_db(max_index:end) <= threshold_db, 1) + max_index - 1;

if isempty(idx_below_threshold)
    rt30_time = NaN;  % -60dB に到達していない場合
else
    rt30_time = time(idx_below_threshold) - max_time;
endif

% 結果の表示
fprintf("RT60: %.2f 秒\n", rt30_time);

% 波形とエンベロープをプロット
figure;
plot(time, envelope_db, "r");
hold on;
plot([time(1), time(end)], [-30, -30], "b--", 'LineWidth', 0.3); % -30dB のラインを追加
xlabel("Time [s]");
ylabel("Amplitude [dB]");
title("Decay Curve of the Audio");
grid on;
hold off;

