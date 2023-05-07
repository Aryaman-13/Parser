# In this code we will be implementing the magic matrix problem in python

def num_magic_square(matrix):
    # Get the size of the matrix
    n = len(matrix)
    
    # Calculate the magic constant
    magic_constant = n * (n**2 + 1) // 2
    
    # Check each row
    for row in matrix:
        if sum(row) != magic_constant:
            return False
    
    # Check each column
    for j in range(n):
        col_sum = sum(matrix[i][j] for i in range(n))
        if col_sum != magic_constant:
            return False
    
    # Check the main diagonal
    diag_sum = sum(matrix[i][i] for i in range(n))
    if diag_sum != magic_constant:
        return False
    
    # Check the other diagonal
    diag_sum = sum(matrix[i][n-1-i] for i in range(n))
    if diag_sum != magic_constant:
        return False
    
    # If all checks pass, the matrix is a magic square
    return True


def call_check_num():
    # Testing for some of the magic square inputs
    matrix = [[8, 1, 6],[3, 5, 7],[4, 9, 2]]
    output = num_magic_square(matrix)
    print("The output is: ",output)
    matrix = [ [16, 2, 3, 13],[5, 11, 10, 8],[9, 7, 6, 12],[4, 14, 15, 1] ]
    output = num_magic_square(matrix)
    print("The output is: ",output)
    matrix = [ [35, 1, 6, 26, 19, 24],[3, 32, 7, 21, 23, 25],[31, 9, 2, 22, 27, 20],[8, 28, 33, 17, 10, 15],[30, 5, 34, 12, 14, 16],[4, 36, 29, 13, 18, 11] ]
    output = num_magic_square(matrix)
    print("The output is: ",output)


call_check_num()






