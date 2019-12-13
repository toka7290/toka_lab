using Printf

入力 = 0
print("値を入力してください = ")
try
    入力 = parse(Int,readline())
    for 縦 = 1:入力, 横 = 1:入力
        @printf " %3d" (縦*横)
        if 横 >= 入力
            print("\n")
        end
    end
catch
    println("入力した値は数値ではありません")
    return
end
