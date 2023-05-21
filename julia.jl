# Author of the File is: Aryaman Khandelwal
# Unique Id: U20210018

#= This file contains the code of magic square matrix, where the inputs can be:
1. Numbers
2. Regular Expressions
3. Polynomials
=#

# Defining the functions

using Unicode

# Adds '1' in the beginning if the coefficient is missing for that term

function add_dig_start(word)
    if word[1] == '-'
        if isdigit(word[2])
            return word  # It already has a coefficient
        else
            word = "1" * word  # Adding "1" as the leading coefficient
            return word
        end
    else
        if isdigit(word[1])
            return word  # It already has a coefficient
        else
            word = "1" * word  # Adding "1" as the leading coefficient
            return word
        end
    end
end

# This function stores the sign of each term. This is calld while assigning the sign to the coefficients

function assign_sign(word)
    sign_list = Char[]
    current_sign = '+'
    if word[1] == '-'
        current_sign = '-'
    end
    if isdigit(word[1]) || (isascii(word[1]) && isletter(word[1]))
        push!(sign_list, current_sign)
    end
    for char in word
        if char in ['+', '-']
            current_sign = char
            push!(sign_list, current_sign)
        end
    end
    return sign_list
end

function parse_string_until_alphabet(string)
    for i in eachindex(string)
        if (isascii(string[i]) && isletter(string[i]))
            return i, string[1:i-1]
        end
    end
    return length(string), string
end

function simplify_expression(char_list)
    total_list = String[]
    for i in 1:length(char_list)
        if isletter(char_list[i][1])
            if i + 1 <= length(char_list) && isdigit(char_list[i+1][1])
                output = char_list[i] * char_list[i+1]
                push!(total_list, output)
            else
                push!(total_list, char_list[i])
            end
        end
    end
    return total_list
end

function split_expression(word)
    if !isdigit(word[1])
        word = "1" * word
    end
    # Now we will start iterating through the word
    index, coeff = parse_string_until_alphabet(word)
    text = word[index:end]
    i = 1
    list_char = String[]
    while i <= length(text)
        push!(list_char, string(text[i]))
        # Now checking whether the next character is an alphabet or '^'
        if i + 1 <= length(text) && text[i+1] == '^'
            j = i + 2
            remaining_word = text[j:end]
            parsed_string = ""
            for character in remaining_word
                if isascii(character) && isletter(character)
                    break
                else
                    parsed_string *= character
                    j += 1
                end
            end
            i = j
            push!(list_char, parsed_string)
        else
            i += 1
        end
    end
    output = simplify_expression(list_char)
    insert!(output, 1, coeff)
    return output
end

function convert_string(string)
    result = ""
    i = 1
    while i <= length(string)
        if isletter(string[i])
            result *= string[i]
            i += 1
        else
            num_start = i
            while i <= length(string) && isdigit(string[i])
                i += 1
            end
            num = parse(Int, string[num_start:i-1])
            num -= 1
            result *= string[num_start-1] ^ num
        end
    end
    return result
end

function update_dict(dict1)
    for (key, value) in pairs(dict1)
        if typeof(value) <: Integer 
            val = string(value)
            val = string(val)
            dict1[key] = val
        end
    end
    new_dict = Dict{String, Int64}()
    for index in keys(dict1)
        var = convert_string(index)
        var = join(sort(collect(var)))
        if index == "constant"
            var = "constant"
        end        
        if !haskey(new_dict, var)
            value = dict1[index]
            value = parse(Int64,value)
            new_dict[var] = value
        else
            value = dict1[index]
            value = parse(Int64,value)
            new_dict[var] += value
        end
    end
    return new_dict
end

function create_dictionary(lst)
    dict1 = Dict{String, Any}()
    for elem in lst
        if length(elem) == 1
            var = "constant"
            if !haskey(dict1, var)
                dict1[var] = [elem[1]]
            else
                push!(dict1[var], elem[1])
            end
        else
            var = ""
            value = elem[1]
            for j in 2:length(elem)
                var *= elem[j]
            end
            if !haskey(dict1, var)
                dict1[var] = [value]
            else
                push!(dict1[var], value)
            end
        end
    end
    for index in keys(dict1)
        if length(dict1[index]) == 1
            dict1[index] = dict1[index][1]
        else
            total = sum(parse.(Int, dict1[index]))
            dict1[index] = total
        end
    end
    dict1 = update_dict(dict1)
    dic_out = Dict{String, Int64}()
    for (x, y) in dict1
        if y != 0
            dic_out[x] = y
        end
    end
    return dic_out
end

function call_function(text)
    sign_list = assign_sign(text)
    terms = split(text, r"(?<=[+-])|([+-])")  # Split the string based on '+' or '-' operators
    result = []
    for term in terms
        term = strip(term)
        if !isempty(term)
            output = add_dig_start(term)
            if any(c -> isletter(c), output)
                output = split_expression(output)
            else
                output = [output]
            end
            push!(result, output)
        end
    end
    for i in 1:length(result)
        expression = result[i]
        expression[1] = string(sign_list[i], expression[1])
    end
    result = [string.(result[i]) for i in 1:length(result)]  # Convert each element to String
    return result
end

function row_operations(term)
    result = call_function(term)
    dict1 = create_dictionary(result)
    return dict1
end

function perform_operations(dict1, dict2)
    master_dict = Dict{Any, Any}()
    # Iterate over dict1 and check if the keys exist in dict2
    for (key, val) in dict1
        if key in keys(dict2)
            val = dict1[key]
            value = dict2[key]
            master_dict[key] = val + value
        end
    end
    # Iterate over dict2 and add the keys that are not present in dict1
    for (key, val) in dict2
        if !(key in keys(dict1))
            master_dict[key] = val
        end
    end
    # Iterate over dict1 and add the keys that are not present in master_dict
    for (key, val) in dict1
        if !(key in keys(master_dict))
            master_dict[key] = val
        end
    end
    return master_dict
end

function calculate_row(row)
    resultant_dict = Dict{String, Any}()
    for i in 1:length(row)-1
        if i == 1
            dict1 = row_operations(row[i])
            dict2 = row_operations(row[i+1])
            resultant_dict = perform_operations(dict1, dict2)
        else
            dict1 = row_operations(row[i+1])
            resultant_dict = perform_operations(resultant_dict, dict1)
        end
    end

    return resultant_dict
end

function is_magic_square(matrix)
    master_dict = Dict{String,Any}()

    # Checks for all the rows
    for i in 1:length(matrix)
        if i == 1
            master_dict = calculate_row(matrix[i])
        else
            check_dict = calculate_row(matrix[i])
            if master_dict != check_dict
                return false
            end
        end
    end

    # Checks for all the columns
    num_cols = length(matrix[1])
    for col_idx in 1:num_cols
        column = [matrix[row_idx][col_idx] for row_idx in 1:length(matrix)]
        check_dict = calculate_row(column)
        if master_dict != check_dict
            return false
        end
    end

    # Checks for the left diagonal
    left_diag = [matrix[i][i] for i in 1:length(matrix)]
    check_dict = calculate_row(left_diag)
    if master_dict != check_dict
        return false
    end

    # Checks for the right diagonal
    size = length(matrix)
    right_diag = [matrix[i][size-i+1] for i in 1:size]
    check_dict = calculate_row(right_diag)
    if master_dict != check_dict
        return false
    end

    return true
end

matrix = [["8", "1", "6"],["3", "5", "7"],["4", "9", "2"]]
println("The output is: ",is_magic_square(matrix))
matrix = [ ["16", "2", "3", "13"],["5", "11", "10", "8"],["9", "7", "6", "12"],["4", "14", "15", "1"] ]
println("The output is: ",is_magic_square(matrix))
matrix = [ ["1", "2", "3"],["4", "5", "6"],["7", "8", "9"]]
output = is_magic_square(matrix)
println("The output is: ",output)
matrix = [["x^2+2","x^2+5x+7","x^2+4x+6"], ["x^2+7x+9","x^2+3x+5","x^2-x+1"] , ["x^2+2x+4","x^2+x+3","x^2+6x+8"]]
output = is_magic_square(matrix)
println("The output is: ",output)
matrix = [["y^2x+xy-1+xz-xz","yx+1-2+xy^2"],["xy+y^2x-1" ,"yx-1+z^2+xy^2-z^2"]]
output = is_magic_square(matrix)
println("The output is: ",output)
matrix = [["-x^2y^2+2xy+1" ,"-x^2y^2+7yx-5yx+1"],["2x^2y^2-3x^2y^2+2xy+1","2xy-y^2x^2+1"]]
output = is_magic_square(matrix)
println("The output is: ",output)
matrix = [["-x^2y^2 + 2xy + 1","-x^2y^2 + 7yx - 5yx + 1"],["2x^2y^2 - 3x^2y^2 + 2xy + 1", "2xy - y^2x^2 + 1"]]
output = is_magic_square(matrix)
println("The output is: ",output)
matrix = [["1+1", "1+1"],["1+1", "1+1"]]
output = is_magic_square(matrix)
println("The output is: ",output)








