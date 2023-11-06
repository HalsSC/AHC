using Base.Threads

function process_data()
    # ここに実行したい処理を記述

    # 例: 1秒ごとに何かしらの処理を行う
    for i in 1:10
        println("Iteration $i")
        sleep(1)  # 1秒待つ
    end
end

function run_with_timeout(timeout::Float64)
    timeout_channel = Channel()  # タイムアウト状態を伝えるチャンネル

    # タイムアウトを監視するタスク
    @async begin
        sleep(timeout)
        put!(timeout_channel, true)  # タイムアウト状態をチャンネルに送信
    end

    # メインの処理タスク
    task = Threads.@spawn process_data()

    is_timed_out = false
    try
        while true
            if isready(timeout_channel)
                is_timed_out = take!(timeout_channel)
                break
            elseif istaskdone(task)
                break
            end
            sleep(0.1)
        end
    finally
        close(timeout_channel)  # チャンネルをクローズ
    end

    if istaskdone(task)
        println("処理が正常に終了しました。")
    elseif is_timed_out
        println("処理がタイムアウトしました。")
        Base.cancel(task)  # タスクをキャンセル
    end
end

# 5秒間の制限で実行
run_with_timeout(2.0)
