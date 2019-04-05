import UIKit

var players: [String: Int] = [:]

players["name"] = 10
players["name"] = 4
players["name"] = 7

let sorted = players.sorted { (player1, player2) -> Bool in
    player1.value > player2.value
}

players.removeAll()

print(sorted.first)
