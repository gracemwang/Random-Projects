//
//  ContentView.swift
//  DDZ
//
//  Created by Grace Wang on 11/17/26.
//

import SwiftUI

struct Card{
    var val: Int
    var suit: String
}

struct Player{
    var name: String
    var score: Int
    var cards: [Card]
}

struct ContentView: View {
    @State var deck = [Card]()
    @State var player1 = Player(name:"Player 1", score:0, cards:[Card]())
    @State var player2 = Player(name:"Player 2", score:0, cards:[Card]())
    
    func buildDeck(){
        for val in 3...15 {
            for suit in ["C", "D", "H", "S"] {
                deck.append(Card(val:val,suit:suit))
            }
        }
        deck.append(Card(val:16,suit:""))
        deck.append(Card(val:17,suit:""))
    }
    
    func startRound(){
        deck.shuffle();
        player1.cards = Array(deck[0...26])
        player2.cards = Array(deck[27...53])
    }
    
    func describeCards(cards:[Card]) -> String{
        var out = ""
        for card in cards{
            out += String(card.val)
            out += card.suit
            out += " "
        }
        return(out)
    }
    
    
    
    var body: some View {
        ZStack {
            Image("background").ignoresSafeArea()
            
            VStack {
                Button(action: {buildDeck()}, label: {Text("Build Deck")})
                Button(action: {startRound()}, label: {Text("Start Round")})
                Text(player1.name + ": " + String(player1.score))
                Text(player2.name + ": " + String(player2.score))
                
            }
            HStack {
                Text(describeCards(cards:player1.cards)).fixedSize().rotationEffect(Angle(degrees:90)).frame(width: 30)
                Spacer().frame(width:300)
                Text(describeCards(cards:player2.cards)).fixedSize().rotationEffect(Angle(degrees:-90)).frame(width: 30)
            }
        }
    }
}

#Preview {
    ContentView()
}
