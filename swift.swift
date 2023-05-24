//
//  main.swift
//  parser_popl
//
//  Created by Aryaman Khandelwal on 22/05/23.
//

import Foundation

// Adds '1' in the beginning if the coefficient is missing for that term
func addDigStart(_ word: String) -> String { // Checked ---> Works fine
    var modifiedWord: String // Declaring the variable
    if word.prefix(1) == "-" {
        if let secondChar = word.dropFirst().first, secondChar.isNumber {
            return word
        } else {
            modifiedWord = "1" + word
            return modifiedWord
        }
    } else {
        if let firstChar = word.first, firstChar.isNumber {
            return word
        } else {
            modifiedWord = "1" + word
            return modifiedWord
        }
    }
}


// This function parses the string until it gets the alphabet | Output ---> length of the substring and substring

func parseStringUntilAlphabet(_ string: String) -> (Int, String) { // Checked ---> Works fine
    for (index, character) in string.enumerated() {
        if character.isLetter {
            let substring = String(string.prefix(index))
            return (index, substring)
        }
    }
    
    return (string.count, string)
}
// This function stores the sign of each term. This is calld while assigning the sign to the coefficients

func assignSign(_ word: String) -> [Character] { // Checked ---> Works fine
    var signList: [Character] = []
    var currentSign: Character = "+"
    
    if word.first == "-" {
        currentSign = "-"
    }
    
    if word.first?.isNumber == true || word.first?.isLetter == true {
        signList.append(currentSign)
    }
    
    for char in word {
        if char == "+" || char == "-" {
            currentSign = char
            signList.append(currentSign)
        }
    }
    
    return signList
}


func simplifyExpression(charList: [String]) -> [String] { // Checked ---> Works fine
    var simplifiedList = [String]()
    
    for i in 0..<charList.count {
        if let firstCharacter = charList[i].first, firstCharacter.isLetter {
            if i + 1 < charList.count, let nextCharacter = charList[i + 1].first, nextCharacter.isNumber {
                simplifiedList.append(charList[i] + charList[i + 1])
            } else {
                simplifiedList.append(charList[i])
            }
        }
    }
    return simplifiedList
}

func splitExpression(word: String) -> [String] { // Checked ---> Works fine
    var modifiedWord = word
    
    if !modifiedWord.first!.isNumber {
        modifiedWord = "1" + modifiedWord
    }
    
    let (index, coeff) = parseStringUntilAlphabet(modifiedWord)
    let text = String(modifiedWord.suffix(from: modifiedWord.index(modifiedWord.startIndex, offsetBy: index)))
    
    var i = 0
    var listChar = [String]()
    
    while i < text.count {
        listChar.append(String(text[text.index(text.startIndex, offsetBy: i)]))
        
        if i + 1 < text.count && text[text.index(text.startIndex, offsetBy: i + 1)] == "^" {
            var j = i + 2
            let remainingWord = String(text.suffix(from: text.index(text.startIndex, offsetBy: j)))
            var parsedString = ""
            
            for character in remainingWord {
                if character.isLetter {
                    break
                } else {
                    parsedString += String(character)
                    j += 1
                }
            }
            
            i = j
            listChar.append(parsedString)
        } else {
            i += 1
        }
    }
    var output = simplifyExpression(charList: listChar)
    output = [String(coeff)] + output
    return output
}

func convertString(_ string: String) -> String { // Checked ---> Works fine
    var result = ""
    var i = string.startIndex
    
    while i < string.endIndex {
        let currentChar = string[i]
        
        if currentChar.isLetter {
            result.append(currentChar)
            i = string.index(after: i)
        } else {
            let numStart = i
            while i < string.endIndex, string[i].isNumber {
                i = string.index(after: i)
            }
            if let num = Int(string[numStart..<i]) {
                let previousChar = string[string.index(before: numStart)]
                result.append(String(repeating: previousChar, count: num - 1))
            }
        }
    }
    
    return result
}

func updateDict(_ dict1: [String: Any]) -> [String: Any] { // Checked ----> Works fine
    var newDict = [String: Any]()
    
    for index in dict1 {
        var varStr = convertString(index.key)
        varStr = String(varStr.sorted())
        
        if index.key == "constant" {
            varStr = "constant"
        }
        
        if newDict[varStr] == nil {
            newDict[varStr] = index.value
        } else {
            if let newValue = Int(newDict[varStr] as? String ?? "") {
                if let indexValue = Int(index.value as? String ?? "") {
                    newDict[varStr] = newValue + indexValue
                }
            }
        }
    }
    
    return newDict
}

func createDictionary(_ lst: [[String]]) -> [String: Int] { // Checked ---> WORKS FINE
    var dict1 = [String: Any]()
    
    for elem in lst {
        if elem.count == 1 {
            let varStr = "constant"
            
            if dict1[varStr] == nil {
                dict1[varStr] = [elem[0]]
            } else {
                if let constantArray = dict1["constant"] as? [String] {
                    dict1["constant"] = constantArray + [elem[0]]
                }
            }
        } else {
            var varStr = ""
            let value = elem[0]
            
            for j in 1..<elem.count {
                varStr += elem[j]
            }
            
            if dict1[varStr] == nil {
                dict1[varStr] = [value]
            } else {
                if let varArray = dict1[varStr] as? [String] {
                    dict1[varStr] = varArray + [value]
                }
            }
        }
    }
    
    for index in dict1 {
        if let varArray = index.value as? [String] {
            if varArray.count == 1 {
                dict1[index.key] = Int(varArray[0])
            } else {
                var sum = 0
                for value in varArray {
                    if let intValue = Int(value) {
                        sum += intValue
                    }
                }
                dict1[index.key] = sum
            }
        }
    }
    
    var dicOut = [String: Int]()
    dict1 = updateDict(dict1)
    
    for (key, value) in dict1 {
        if let intValue = value as? Int, intValue != 0 {
            dicOut[key] = intValue
        }
    }
    
    return dicOut
}

func performOperations(_ dict1: [String: Int], _ dict2: [String: Int]) -> [String: Int] { // Checked ---> works fine
    var masterDict = [String: Int]()
    
    // Iterate over dict1 and check if the keys exist in dict2
    for (key, value) in dict1 {
        if let dict2Value = dict2[key] {
            if let strValue = dict2Value as? String {
                if strValue.hasPrefix("+") {
                    masterDict[key] = (value as? Int ?? 0) + Int(strValue.dropFirst())!
                } else if strValue.hasPrefix("-") {
                    masterDict[key] = (value as? Int ?? 0) - Int(strValue.dropFirst())!
                }
            } else if let intValue = dict2Value as? Int {
                masterDict[key] = (value as? Int ?? 0) + intValue
            }
        } else {
            masterDict[key] = value
        }
    }
    
    // Iterate over dict2 and add the keys that are not present in dict1
    for (key, value) in dict2 {
        if dict1[key] == nil {
            masterDict[key] = value
        }
    }
    
    // Iterate over dict1 and add the keys that are not present in masterDict
    for (key, value) in dict1 {
        if masterDict[key] == nil {
            masterDict[key] = value
        }
    }
    
    return masterDict
}


import Foundation

func callFunction(text: String) -> [[String]] {
    let signList = assignSign(text)
    return text.split(whereSeparator: { "+-".contains($0) })
        .map { String($0).trimmingCharacters(in: .whitespaces) }
        .enumerated()
        .map { var exp = splitExpression(word: $1); exp[0] = String(signList[$0]) + exp[0]; return exp }

}

func rowOperations(text: String) -> [String: Int] {
    let result = callFunction(text:text)
    let dict1 = createDictionary(result)
    return dict1
}


func isMagicSquare(matrix: [[String]]) -> Bool {
    var masterDict = [String: Int]()
    
    // Checks for all the rows
    for i in 0..<matrix.count {
        let stringRow = matrix[i].map { String($0) } // Convert the elements to strings
        
        if i == 0 {
            masterDict = calculateRow(row: stringRow)
        } else {
            let checkDict = calculateRow(row: stringRow)
            if masterDict != checkDict {
                return false
            }
        }
    }
    
    // Checks for all the columns
    let numCols = matrix[0].count
    for colIdx in 0..<numCols {
        var column = [String]()
        for rowIdx in 0..<matrix.count {
            column.append(String(matrix[rowIdx][colIdx]))
        }
        let checkDict = calculateRow(row: column)
        if masterDict != checkDict {
            return false
        }
    }
    
    // Checks for the left diagonal
    var leftDiag = [String]()
    for i in 0..<matrix.count {
        leftDiag.append(String(matrix[i][i]))
    }
    let leftDiagDict = calculateRow(row: leftDiag)
    if masterDict != leftDiagDict {
        return false
    }
    
    // Checks for the right diagonal
    var rightDiag = [String]()
    let size = matrix.count
    for i in 0..<size {
        rightDiag.append(String(matrix[i][size-1-i]))
    }
    let rightDiagDict = calculateRow(row: rightDiag)
    if masterDict != rightDiagDict {
        return false
    }
    
    return true
}

func calculateRow(row: [String]) -> [String: Int] {
    var resultantDict = [String: Int]()
    for i in 0..<row.count-1 {
        if i == 0 {
            let dict1 = rowOperations(text: row[i])
            let dict2 = rowOperations(text: row[i+1])
            resultantDict = performOperations(dict1, dict2)
        } else {
            let dict1 = rowOperations(text: row[i+1])
            resultantDict = performOperations(resultantDict, dict1)
        }
    }
    return resultantDict
}

// var matrix = [["8", "1", "6"],["3", "5", "7"],["4", "9", "2"]]
// print("The output is: ",isMagicSquare(matrix:matrix))
// matrix = [ ["16", "2", "3", "13"],["5", "11", "10", "8"],["9", "7", "6", "12"],["4", "14", "15", "1"] ]
// print("The output is: ",isMagicSquare(matrix:matrix))
// matrix = [ ["1", "2", "3"],["4", "5", "6"],["7", "8", "9"]]
// var output = isMagicSquare(matrix:matrix)
// print("The output is: ",output)
// matrix = [["x^2+2","x^2+5x+7","x^2+4x+6"], ["x^2+7x+9","x^2+3x+5","x^2-x+1"] , ["x^2+2x+4","x^2+x+3","x^2+6x+8"]]
// output = isMagicSquare(matrix:matrix)
// print("The output is: ",output)
// matrix = [["y^2x+xy-1+xz-xz","yx+1-2+xy^2"],["xy+y^2x-1" ,"yx-1+z^2+xy^2-z^2"]]
// output = isMagicSquare(matrix:matrix)
// print("The output is: ",output)
// matrix = [["-x^2y^2+2xy+1" ,"-x^2y^2+7yx-5yx+1"],["2x^2y^2-3x^2y^2+2xy+1","2xy-y^2x^2+1"]]
// output = isMagicSquare(matrix:matrix)
// print("The output is: ",output)
// matrix = [["-x^2y^2 + 2xy + 1","-x^2y^2 + 7yx - 5yx + 1"],["2x^2y^2 - 3x^2y^2 + 2xy + 1", "2xy - y^2x^2 + 1"]]
// output = isMagicSquare(matrix:matrix)
// print("The output is: ",output)
// matrix = [["1+1", "1+1"], ["1+1", "1+1"]]
// output = isMagicSquare(matrix:matrix)
// print("The output is: ",output)


// func parseText() -> [[String]] {
//     let fileURL = URL(fileURLWithPath: "./matrix.txt")
    
//     var matrix: [[String]] = []
//     if let fileContent = try? String(contentsOf: fileURL, encoding: .utf8) {
//         let lines = fileContent.components(separatedBy: "\n")
//         for line in lines {
//             let values = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
//             matrix.append(values)
//         }
//     }
    
//     return matrix
// }

func parseText() {
    let fileURL = URL(fileURLWithPath: "./matrix.txt")
    var matrix: [[String]] = []
    if let fileContent = try? String(contentsOf: fileURL, encoding: .utf8) {
        let lines = fileContent.components(separatedBy: "\n")
        for line in lines {
            if !line.isEmpty { // Not an empty line
                let values = line.components(separatedBy: " ").map { $0.trimmingCharacters(in: .whitespaces) }
                matrix.append(values)
            } else {
                if !matrix.isEmpty {
                    print("The output is:",isMagicSquare(matrix: matrix))
                    matrix = []
                }
            }
        }
        if !matrix.isEmpty {
            print(isMagicSquare(matrix: matrix))
        }
    }
}

parseText()

