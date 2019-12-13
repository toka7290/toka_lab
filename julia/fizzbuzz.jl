値 = 0

for 値 in 0:100
    if 値 % 15 == 0
        println("fizzbuzz")
    elseif 値　% 5 == 0
        println("buzz")
    elseif 値 % 3 == 0
        println("fizz")
    else
        println(値)
    end
end
