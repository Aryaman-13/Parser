# In this code we will be implementing the magic matrix problem in python

import re
from collections import defaultdict

# Adds '1' in the beginning if the coefficient is missing for that term 

def add_dig_start(word):

    if(word[0] == '-'):
        if(word[1].isdigit() == True):
            return word # It already has a coefficient
        else:
            word = "1" + word # Adding "1" as the leading coefficient
            return word
    else:
        if(word[0].isdigit() == True):
            return word # It already has a coefficient
        else:
            word = "1" + word # Adding "1" as the leading coefficient
            return word
        
# This function parses the string until it gets the alphabet | Output ---> length of the substring and substring
    
def parse_string_until_alphabet(string):
    for i in range(len(string)):
        if string[i].isalpha():
            return i, string[:i]
    return len(string), string

# This function stores the sign of each term. This is calld while assigning the sign to the coefficients

def assign_sign(word):
    sign_list = []
    current_sign = '+'
    if word[0] == '-':
        current_sign = '-'
    if word[0].isdigit() == True or word[0].isalpha():
        sign_list.append(current_sign)
        
    for char in word:
        if char in ['+','-']:
            current_sign = char
            sign_list.append(current_sign)
    return sign_list

# This function is used to simplify the terms containing variables | Concatenates the variable with its power

def simplify_expression(char_list):
    j = 0 
    total_list = []
    while(j<len(char_list)):
       if(char_list[j].isalpha()==True):
           if(j+1<len(char_list) and char_list[j+1].isdigit()==True):
               output = char_list[j]+char_list[j+1]
               total_list.append(output)
               j+=1
           else:
               total_list.append(char_list[j])
               j+=1
       else:
           j+=1
    return total_list

# This function splits the each term

def split_expression(word):
    if word[0].isdigit() == False:
        word = "1"+word
    # Now we will start iterating through the word
    index, coeff = parse_string_until_alphabet(word)
    text = word[index:]
    i = 0
    list_char = []
    while(i<len(text)):
        list_char.append(text[i])
        # Now checking whether the next character is an alphabet or '^'
        if (i+1<len(text) and text[i+1]=='^'):
            j = i+2
            remaining_word = text[j:]
            parsed_string = ""
            for character in remaining_word:
                if character.isalpha():
                    break
                else:
                    parsed_string+= character
                    j+=1
            i = j
            list_char.append(parsed_string)
        else:
            i+=1

    output = simplify_expression(list_char)
    output.insert(0,coeff)
    return output

# This function is used to create dictionary of the resultant expression. Keys are all the unique terms that appear in the expression, and the value 
#  of the keys are the coefficients of the terms


def convert_string(string):
    result = ''
    i = 0

    while i < len(string):
        if string[i].isalpha():
            result += string[i]
            i += 1
        else:
            num_start = i
            while i < len(string)  and string[i].isdigit():
                i += 1
            num = int(string[num_start:i])
            num = num - 1
            result += string[num_start - 1] * num
    return result

def update_dict(dict1):
    new_dict = {}
    for index in dict1:
        var = convert_string(index)
        var = ''.join(sorted(var))
        if var not in new_dict:
            new_dict[var] = dict1[index]
        else: # It is already present
            new_dict[var] = int(new_dict[var]) + int(dict1[index])
    return new_dict

# This function is used to create dictionary of the resultant expression. Keys are all the unique terms that appear in the expression, and the value 
#  of the keys are the coefficients of the terms

def create_dictionary(lst):
    dict1 = {}
    for elem in lst: # Extracts each element of the list
        if(len(elem) == 1): # This means that it is a constant
            var = 'constant' # Defining the variable as constant
            if var not in dict1: # No constant term in the dictionary
                dict1[var] = [elem[0]]
            else: # There exists a constant term already
                dict1['constant'].append(elem[0])
        else: # Any term except constant
            var = ""
            value = elem[0]
            for j in range(len(elem)):
                if(j>0):
                    var = var + elem[j]
            if var not in dict1: # If that term does not exist in the dictionary
                dict1[var] = [value]
            else:
                dict1[var].append(value) # If that term already exists in the dictionary
    # For terms which appear more than once in the expression, computing the resultant sum of them
    for index in dict1: 
        if len(dict1[index])==1:
            dict1[index] = (dict1[index])[0]
        else:
            sum = 0
            for value in dict1[index]:sum = sum + int(value)
            dict1[index] = sum
    dic_out = {}
    dict1 = update_dict(dict1)
    print(dict1)
    for x, y in dict1.items():
        if y != 0:
            dic_out[x] = y
    return dic_out

# Takes sum of two expressions

def perform_operations(dict1,dict2):

    master_dict = {}

    # Iterate over dict1 and check if the keys exist in dict2
    for key, val in dict1.items():
        if key in dict2:
            value = dict2[key]
            if (type(value)==str):
                if value[0] == '+':
                    value = int(value[1:])
                else:
                    value = int(value[1:])
                    value = - (value)
            if (type(val)== str):
                if val[0] == '+':
                    val = int(val[1:])
                else:
                    val = int(val[1:])
                    val = -(val)
            master_dict[key] = val + value
            

    # Iterate over dict2 and add the keys that are not present in dict1
    for key, val in dict2.items():
        if key not in dict1:
            master_dict[key] = val

    # Iterate over dict1 and add the keys that are not present in master_dict
    for key, val in dict1.items():
        if key not in master_dict:
            master_dict[key] = val
    
    return master_dict

# Calls all the functions that are defined above

def call_function(text):
    sign_list = assign_sign(text)
    # Splits the string whenever it encounters a (+) or (-) sign, without including the sign in the split
    result = re.split('(?<![eE])[+-]', text)
    # Removes any leading or trailing whitespace from each term
    result = [term.strip() for term in result]
    if result[0] == '': 
        result = result[1:]

    for i in range(len(result)):
        word = result[i]
        output = add_dig_start(word)
        result[i] = output
        if any(c.isalpha() for c in result[i]):
            result[i] = split_expression(result[i])
        else:
            result[i] = [result[i]]

    # Adding the respective signs to each term
    for i in range(len(result)):
        expression = result[i]
        expression[0] = sign_list[i] + expression[0]
    return result

def row_operations(term):
    result = call_function(term)
    dict1 = create_dictionary(result)
    return dict1

# Performs operations for a row. Here the variable row can be a single row, column, left diagonal, right diagonal

def calculate_row(row):
    resultant_dict = defaultdict(int)
    for i in range(len(row)-1):
        if i == 0:
            dict1 = row_operations(row[i])
            dict2 = row_operations(row[i+1])
            resultant_dict = perform_operations(dict1,dict2)
        else:
            dict1 = row_operations(row[i+1])
            resultant_dict = perform_operations(resultant_dict,dict1)
    return resultant_dict

def is_magic_square(matrix):
    # Checks for all the rows
    master_dict = defaultdict(int)
    for i in range(len(matrix)):
        if i == 0:
            master_dict = calculate_row(matrix[i])
        else:
            check_dict = calculate_row(matrix[i])
            if (master_dict!=check_dict):
                return False

    # Checks for all the columns
    num_cols = len(matrix[0])
    for col_idx in range(num_cols):
        # if col_idx == 0:
        #     column = [matrix[row_idx][0] for row_idx in range(len(matrix))]
        #     master_dict = calculate_row(column)
        # else:
            column = [matrix[row_idx][col_idx] for row_idx in range(len(matrix))]
            check_dict = calculate_row(column)
            if (master_dict!=check_dict):
                return False
    check_dict.clear()
    # Checks for the left diagonal
    left_diag = [matrix[i][i] for i in range(len(matrix))]
    check_dict = calculate_row(left_diag)
    if (master_dict!=check_dict):
                return False
    check_dict.clear()
    # Checks for the right diagonal
    size = len(matrix)
    right_diag = [matrix[i][-1-i] for i in range(size)]
    check_dict = calculate_row(left_diag)
    if (master_dict!=check_dict):
                return False
    return True

########################################### ALL THE FUNCTIONS FOR EXPRESSIONS END HERE ####################################################

def main():

    print("This code assumes certain assumptions for the case of SIMPLE EXPRESSIONS OR POLYNOMIALS, and expects that the user gives input aligned to those assumptions")
    print()
    print("ASSUMPTION 1: ")
    print("If you want to raise a variable to its power use ('^') operator")
    print("Some Examples are:")
    print(" 2nd degree of x is represented as x^2")
    print("9th degree of y is represented as y^9")
    print("n degree of z is represented as z^n")
    print("1 degree of var is represented only by var. We do not use ('^') for this case")
    print()
    print("ASSUMPTION 2: ")
    print("Do not use any multiplicative operator ('*').")
    print("Some Examples are:")
    print(" Represent 2*x as 2x ")
    print(" Represent 7*x^2 as 7x^2")
    print()
    print()
    matrix = [["8", "1", "6"],["3", "5", "7"],["4", "9", "2"]]
    print("The output is: ",is_magic_square(matrix))
    matrix = [ ["16", "2", "3", "13"],["5", "11", "10", "8"],["9", "7", "6", "12"],["4", "14", "15", "1"] ]
    print("The output is: ",is_magic_square(matrix))
    matrix = [ ["1", "2", "3"],["4", "5", "6"],["7", "8", "9"]]
    output = is_magic_square(matrix)
    print("The output is: ",output)
    matrix = [["x^2+2","x^2+5x+7","x^2+4x+6"], ['x^2+7x+9','x^2+3x+5','x^2-x+1'] , ['x^2+2x+4','x^2+x+3','x^2+6x+8']]
    output = is_magic_square(matrix)
    print("The output is: ",output)
    print("yo")
    matrix = [["y^2x+xy-1+xz-xz","yx+1-2+xy^2"],["xy+y^2x-1" ,'yx-1+z^2+xy^2-z^2']]
    output = is_magic_square(matrix)
    print("The output is: ",output)
    return 0

if __name__== "__main__" :
    main()
