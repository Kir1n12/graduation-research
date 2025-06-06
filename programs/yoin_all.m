pkg load signal;

% フォルダ内のすべてのWAVファイルを取得
wav_files = dir("c_data/*.wav");
results = {"Filename", "RT30 (s)"};

for i = 1:length(wav_files)
    file_path = fullfile("c_data", wav_files(i).name);
    [file, fs] = audioread(file_path);

    % モノラル変換（ステレオの場合）
    if columns(file) > 1
        file = mean(file, 2);
    endif

    % 最初の100msを無視する
    start_index = round(0.1 * fs);
    file = file(start_index:end);

    % ヒルベルト変換でエンベロープを取得
    analytic_signal = hilbert(file);
    envelope = abs(analytic_signal);

    % エンベロープの平滑化（ノイズ低減）
    envelope = movmean(envelope, 100);

    % エンベロープを正規化しdB変換
    envelope_db = 20 * log10(envelope / max(envelope));

    % 時間軸の計算
    time = (0:length(file)-1) / fs;

    % 最大値の位置を取得（開始100ms後から探索）
    [max_value, max_index] = max(envelope_db);
    max_time = time(max_index);

    % -30dB に到達する最初の時刻を取得
    threshold_db = -60;
    idx_below_threshold = find(envelope_db(max_index:end) <= threshold_db, 1) + max_index - 1;

    if isempty(idx_below_threshold)
        rt30_time = NaN;  % -30dB に到達していない場合
    else
        rt30_time = time(idx_below_threshold) - max_time;
    endif

    % 結果をリストに保存
    results = [results; {wav_files(i).name, rt30_time}];

    % 結果の表示
    fprintf("File: %s, RT30: %.2f 秒\n", wav_files(i).name, rt30_time);

    % 波形とエンベロープをプロットし、ファイル名でPNG保存
    figure;
    plot(time, envelope_db, "r");
    hold on;
    plot([time(1), time(end)], [-30, -30], "b--", 'LineWidth', 0.3); % -30dB のラインを追加
    xlabel("Time [s]");
    ylabel("Amplitude [dB]");
    title(["Decay Curve of ", wav_files(i).name]);
    grid on;
    hold off;
    saveas(gcf, ["png/yoin/", strrep(wav_files(i).name, ".wav", ".png")]);
    close;
endfor

% CSVファイルに結果を保存
fid = fopen("png/yoin_results.csv", "w");
for i = 1:size(results, 1)
    fprintf(fid, "%s,%.2f\n", results{i, 1}, results{i, 2});
endfor
fclose(fid);

