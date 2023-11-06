# 相対スコア = 10^9 * 絶対スコア / 最高絶対スコア
myscore = 352030
my_sotai_score = 1301885
high_sotai_score = 45362851156

# 最高絶対スコア = 絶対スコア * 10^9 / 相対スコア
highscore = myscore * 10^9 / my_sotai_score

# 相手の絶対スコア = 相対スコア * 最高絶対スコア / 10^9
vs_score = 45362851156
println("現在の最高得点:", trunc(Int, highscore), " 平均スコア:", highscore / 50)
println("相手の得点:", vs_score * highscore / 10^9, " 平均スコア:", vs_score * highscore / 10^9 / 50)