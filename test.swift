// Adds '1' in the beginning if the coefficient is missing for that term 
func addDigStart(_ word: String) -> String {
    var modifiedWord = word
    if word.prefix(1) == "-" {
        if let secondChar = word.dropFirst().first, secondChar.isNumber {
            return word // It already has a coefficient
        } else {
            modifiedWord = "1" + word // Adding "1" as the leading coefficient
            return modifiedWord
        }
    } else {
        if let firstChar = word.first, firstChar.isNumber {
            return word // It already has a coefficient
        } else {
            modifiedWord = "1" + word // Adding "1" as the leading coefficient
            return modifiedWord
        }
    }
}

// This function parses the string until it gets the alphabet | Output ---> length of the substring and substring

func parseStringUntilAlphabet(_ string: String) -> (Int, String) {
    for (index, character) in string.enumerated() {
        if character.isLetter {
            let substring = String(string.prefix(index))
            return (index, substring)
        }
    }
    
    return (string.count, string)
}
// This function stores the sign of each term. This is calld while assigning the sign to the coefficients

func assignSign(_ word: String) -> [Character] {
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

// This function is used to simplify the terms containing variables | Concatenates the variable with its power

// func simplifyExpression(charList: [String]) -> String {
//     var simplifiedString = ""
    
//     for i in 0..<charList.count {
//         if let firstCharacter = charList[i].first, firstCharacter.isLetter {
//             if i + 1 < charList.count, let nextCharacter = charList[i + 1].first, nextCharacter.isNumber {
//                 simplifiedString.append(charList[i] + charList[i + 1])
//             } else {
//                 simplifiedString.append(charList[i])
//             }
//         }
//     }
//     return simplifiedString
// }


func simplifyExpression(charList: [String]) -> [String] {
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

func splitExpression(word: String) -> [String] {
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

func convertString(_ string: String) -> String {
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

func updateDict(_ dict1: [String: String]) -> [String: Int] {
    var newDict = [String: Int]()
    
    for (index, value) in dict1 {
        var varString = convertString(index)
        varString = String(varString.sorted())
        
        if let intValue = Int(value) {
            if newDict[varString] == nil {
                newDict[varString] = intValue
            } else {
                newDict[varString]! += intValue
            }
        }
    }
    
    return newDict
}
func createDictionary(_ lst: [[String]]) -> [String:Int] {
    var dict1 = [String: [Any]]()

    for elem in lst {
        if elem.count == 1 {
            let varName = "constant"
            if dict1[varName] == nil {
                dict1[varName] = [elem[0]]
            } else {
                dict1[varName]!.append(elem[0])
            }
        } else {
            var varName = ""
            let value = elem[0]

            for j in 1..<elem.count {
                varName += elem[j]
            }

            if dict1[varName] == nil {
                dict1[varName] = [value]
            } else {
                dict1[varName]!.append(value)
            }
        }
    }

    for (index, valueList) in dict1 {
        if valueList.count == 1 {
            if let intValue = Int(valueList[0]) {
                dict1[index] = intValue
            }
        } else {
            var sum = 0
            for value in valueList {
                if let intValue = Int(value) {
                    sum += intValue
                }
            }
            dict1[index] = sum
        }
    }

    // dict1 = updateDict(dict1)

    // var dicOut = [String: Int]()
    // // for (x, y) in dict1 {
    // //     if y != 0 {
    // //         dicOut[x] = y
    // //     }
    // // }
    return dict1
}

let lst: [[String]] = [["a", "1"], ["b", "2"], ["a", "3"], ["c"], ["b", "4"], ["constant", "5"]]
let dict = createDictionary(lst)
print(dict)



// let dict = ["y2": "+5", "x": "+8"]
// let updatedDict = updateDict(dict)
// print(updatedDict)
