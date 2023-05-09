//
//  Game.swift
//  Game-2048
//
//  Created by Иван Вдовин on 07.05.2023.
//

import Foundation
import SwiftUI

class Game: ObservableObject {
    @Published var board = [[Block]]()
    let emptyBlock: Block = Block()
    var sizeBoard: Int = 4
    @Published var gameOver: Bool = false
    @Published var message: String = ""
    
    init() {
        resetBoard()
    }
    
    // Функция для генерации нового блока
    func generateNewBlock() {
        // Находим все свободные блоки
        var emptyBlocks = [(Int, Int)]()
        for i in 0..<4 {
            for j in 0..<4 {
                if board[i][j].color == emptyBlock.color {
                    emptyBlocks.append((i, j)) // Координаты пустых ячеек
                }
            }
        }
        // Если есть свободные блоки, выбираем случайный и создаем новый блок
        if !emptyBlocks.isEmpty {
            let randomIndex = Int(arc4random_uniform(UInt32(emptyBlocks.count)))
            let (i, j) = emptyBlocks[randomIndex]
            board[i][j] = Block(value: Int.random(in: 1...2) * 2, color: Color(hex: 0xffc266))
        } else {
            gameOver = true
            message = "Вы проиграли"
        }
    }

    // Функция для проверки достижения числа 2048
    func checkWin() {
        for i in 0..<sizeBoard {
            for j in 0..<sizeBoard {
                if board[i][j].value == 2048 {
                    gameOver = true
                    message = "Вы выиграли!!!"
                }
            }
        }
    }
    
    // Обновляем поле
    func resetBoard() {
        var newBoard = [[Block]]()
        for _ in 0...sizeBoard {
            var row = [Block]()
            
            for _ in 0...sizeBoard {
                row.append(Block())
            }
            newBoard.append(row)
        }
        board = newBoard
        generateNewBlock()
        gameOver = false
        message = ""
    }
    
    func changeColor(in block: Block) {
        switch block.value {
        case 8, 16: block.color = Color(hex: 0xffad33)
            case 32, 64: block.color = Color(hex: 0xffa420)
            case 128: block.color = Color(hex: 0xffa000)
            case 256: block.color = Color(hex: 0xf3a505)
            case 512: block.color = Color(hex: 0xffb300)
            case 1024: block.color = Color(hex: 0xffa343)
            case 2048: block.color = Color(hex: 0xcc5500)
        default:
            block.color = Color(hex: 0xffc266)
        }
    }
    
    // Функция для сдвига блоков на игровом поле
    func shiftBlocks(to toward: Toward) {
        var isMoved = false
        
        switch toward { // TODO: ГОВНОКОДИЩЕ, переделать свитч
            case .left:
                for row in 0..<4 {
                    for col in 1..<4 {
                        if board[row][col].color == emptyBlock.color { // Скипаем сразу все пустые блоки
                            continue
                        }
                        
                        var newPosition = col
                        
                        while newPosition > 0 && board[row][newPosition - 1].color == emptyBlock.color {
                            newPosition -= 1
                        }
                        // Если мы таки переместились духовно, то перемещаемся материально
                        if newPosition != col {
                            board[row][newPosition] = board[row][col]
                            board[row][col] = emptyBlock
                            isMoved = true
                        }
                        // Мерджим значения блоков, если они равны
                        if newPosition > 0 && board[row][newPosition - 1].value == board[row][newPosition].value {
                            board[row][newPosition - 1].value *= 2
                            changeColor(in: board[row][newPosition - 1])
                            board[row][newPosition] = emptyBlock
                            isMoved = true
                        }
                    }
                }
            case .right:
                for row in 0..<4 {
                    for col in (0..<3).reversed() {
                        if board[row][col].color == emptyBlock.color {
                            continue
                        }

                        var newPosition = col
                        while newPosition < 3 && board[row][newPosition + 1].color == emptyBlock.color {
                            newPosition += 1
                        }
                    
                        if newPosition != col { // Если мы таки переместились духовно, то перемещаемся материально
                            board[row][newPosition] = board[row][col]
                            board[row][col] = emptyBlock
                            isMoved = true
                        }
                        
                        if newPosition < 3 && board[row][newPosition + 1].value == board[row][newPosition].value { // Мерджим значения блоков, если они равны
                            board[row][newPosition + 1].value *= 2
                            changeColor(in: board[row][newPosition + 1])
                            board[row][newPosition] = emptyBlock
                            isMoved = true
                        }
                    }
                }
            case .up:
                for col in 0..<4 {
                    for row in 1..<4 { // Итерируемся сверху вниз
                        if board[row][col].color == emptyBlock.color { // Скипаем сразу все пустые блоки
                            continue
                        }
                        
                        var newPosition = row
                        
                        while newPosition > 0 && board[newPosition - 1][col].color == emptyBlock.color {
                            newPosition -= 1
                        }
                    
                        if newPosition != row { // Если мы таки переместились духовно, то перемещаемся материально
                            board[newPosition][col] = board[row][col]
                            board[row][col] = emptyBlock
                            isMoved = true
                        }
                        
                        if newPosition > 0 && board[newPosition - 1][col].value == board[newPosition][col].value { // Мерджим значения блоков, если они равны
                            board[newPosition - 1][col].value *= 2
                            changeColor(in: board[newPosition - 1][col])
                            board[newPosition][col] = emptyBlock
                            isMoved = true
                        }
                    }
                }
            case .down:
                for col in 0..<4 {
                    for row in (0..<3).reversed() { // Итерируемся снизу вверх
                        if board[row][col].color == emptyBlock.color { // Скипаем сразу все пустые блоки
                            continue
                        }
                        
                    var newPosition = row
                        while newPosition < 3 && board[newPosition + 1][col].color == emptyBlock.color {
                            newPosition += 1
                        }
                        
                        if newPosition != row { // Если мы таки переместились духовно, то перемещаемся материально
                            board[newPosition][col] = board[row][col]
                            board[row][col] = emptyBlock
                            isMoved = true
                        }
                        
                        if newPosition < 3 && board[newPosition + 1][col].value == board[newPosition][col].value { // Мерджим значения блоков, если они равны
                            board[newPosition + 1][col].value *= 2
                            changeColor(in: board[newPosition + 1][col])
                            board[newPosition][col] = emptyBlock
                            isMoved = true
                        }
                    }
                }
        }
        // После каждого свайпа создаем блок
        if isMoved {
            generateNewBlock()
        }
        checkWin()
    }
}

enum Toward {
    case left, right, up, down
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
