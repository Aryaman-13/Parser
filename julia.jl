using SparseArrays

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

# This function parses the string until it gets the alphabet | Output ---> length of the substring and substring
function parse_string_until_alphabet(string)
    for i in 1:length(string)
        if isalpha(string[i])
            return i, string[1:i-1]
        end
    end
    return length(string), string
end

# This function stores the sign of each term. This is called while assigning the sign to the coefficients
function assign_sign(word)
    sign_list = []
    current_sign = '+'
    if word[1] == '-'
        current_sign = '-'
    end
    if isdigit(word[1]) || isalpha(word[1])
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

# This function is used to simplify the terms containing variables | Concatenates the variable with its power
function simplify_expression(char_list)
    j = 1
    total_list = []
    while j <= length(char_list)
        if isalpha(char_list[j])
            if j + 1 <= length(char_list) && isdigit(char_list[j + 1])
                output = string(char_list[j], char_list[j + 1])
                push!(total_list, output)
                j += 1
            else
                push!(total_list, char_list[j])
            end
        end
        j += 1
    end
    return total_list
end

# This function splits each term
function split_expression(word)
    if !isdigit(word[1])
        word = "1" * word
    end
    index, coeff = parse_string_until_alphabet(word)
    text = word[index+1:end]
    i = 1
    list_char = []
    while i <= length(text)
        push!(list_char, text[i])
        if i + 1 <= length(text) && text[i + 1] == '^'
            j = i + 2
            remaining_word = text[j:end]
            parsed_string = ""
            for character in remaining_word
                if isalpha(character)
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
    unshift!(output, coeff)
    return output
end

# This function is used to create a dictionary of the resultant expression.
# Keys are all the unique terms that appear in the expression, and the value of the keys are the coefficients of the terms

function create_dictionary(lst)
    dict1 = DefaultDict{String, Int}(0)
    for elem in lst
        if length(elem) == 1 # It is a constant
            dict1["constant"] = elem[1]
        else
            var = ""
            value = elem[1]
            for j in 2:length(elem)
                var *= elem[j]
            end
            dict1[var] = value
        end
    end
    return dict1
end

function perform_operations(dict1, dict2)
    master_dict = Dict()

    # Iterate over dict1 and check if the keys exist in dict2
    for (key, val) in dict1
        if key in keys(dict2)
            value = dict2[key]
            if typeof(value) == String
                if value[1] == '+'
                    value = parse(Int, value[2:end])
                else
                    value = parse(Int, value[2:end])
                    value = -value
                end
            end
            if typeof(val) == String
                if val[1] == '+'
                    val = parse(Int, val[2:end])
                else
                    val = parse(Int, val[2:end])
                    val = -val
                end
            end
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

function call_function(text)
    sign_list = assign_sign(text)
    # Splits the string whenever it encounters a (+) or (-) sign, without including the sign in the split
    result = split(text, r"(?<![eE])[+-]")
    # Removes any leading or trailing whitespace from each term
    result = [strip(term) for term in result]
    if result[1] == ""
        result = result[2:end]
    end

    for i in 1:length(result)
        word = result[i]
        output = add_dig_start(word)
        result[i] = output
        if any(isalpha, result[i])
            result[i] = split_expression(result[i])
        else
            result[i] = [result[i]]
        end
    end

    # Adding the respective signs to each term
    for i in 1:length(result)
        expression = result[i]
        expression[1] = sign_list[i] * expression[1]
    end
    return result
end

function row_operations(term)
    result = call_function(term)
    dict1 = create_dictionary(result)
    return dict1
end

function calculate_row(row)
    resultant_dict = DefaultDict{String, Int}(0)
    for i in 1:length(row) - 1
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
    # Checks for all the rows
    master_dict = DefaultDict{String, Int}(0)
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

    check_dict.clear()
    # Checks for the left diagonal
    left_diag = [matrix[i][i] for i in 1:length(matrix)]
    check_dict = calculate_row(left_diag)
    if master_dict != check_dict
        return false
    end

    check_dict.clear()
    # Checks for the right diagonal
    size = length(matrix)
    right_diag = [matrix[i][size-i+1] for i in 1:size]
    check_dict = calculate_row(right_diag)
    if master_dict != check_dict
        return false
    end

    return true
end

function num_magic_square(matrix)
    # Get the size of the matrix
    n = length(matrix)
    # Calculate the magic constant
    magic_constant = n * (n^2 + 1) ÷ 2
    # Check each row
    for row in matrix
        if sum(row) != magic_constant
            return false
        end
    end
    # Check for each column
    for j in 1:n
        col_sum = sum(matrix[i][j] for i in 1:n)
        if col_sum != magic_constant
            return false
        end
    end
    # Checks the left diagonal
    diag_sum = sum(matrix[i][i] for i in 1:n)
    if diag_sum != magic_constant
        return false
    end
    # Check the other diagonal
    diag_sum = sum(matrix[i][n-i+1] for i in 1:n)
    if diag_sum != magic_constant
        return false
    end
    # If all checks pass, the matrix is a magic square
    return true
end

function main()
    println("This code assumes certain assumptions for the case of SIMPLE EXPRESSIONS OR POLYNOMIALS, and expects that the user gives input aligned to those assumptions")
    println()
    println("ASSUMPTION 1: ")
    println("If you want to raise a variable to its power use ('^') operator")
    println("Some Examples are:")
    println(" 2nd degree of x is represented as x^2")
    println("9th degree of y is represented as y^9")
    println("n degree of z is represented as z^n")
    println("1 degree of var is represented only by var. We do not use ('^') for this case")
    println()
    println("ASSUMPTION 2: ")
    println("Do not use any multiplicative operator ('*').")
    println("Some Examples are:")
    println(" Represent 2*x as 2x ")
    println(" Represent 7*x^2 as 7x^2")
    # Please add the fact only one term can exist
    println()
    println()
    println("Enter the value of choice to be 0, if if you want to check magic square matrix for only numbers")
    println("Enter the value of choice to be 1, if you want to check magic square matrix for polynomials and simple expressions")
    println()

