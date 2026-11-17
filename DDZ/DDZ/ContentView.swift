import SwiftUI

struct Card: Identifiable{
    let val: Int
    let suit: String
    let id: String
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
                deck.append(Card(val:val,suit:suit,id:(String(val)+suit)))
            }
        }
        deck.append(Card(val:16,suit:"",id:"16"))
        deck.append(Card(val:17,suit:"",id:"17"))
    }
    
    func cmp(card1:Card, card2:Card) -> Bool{
        if (card1.val < card2.val){
            return true
        }
        if (card1.val == card2.val) && (card1.suit < card2.suit){
            return true
        }
        return false
    }
    
    func startRound(){
        deck.shuffle();
        player1.cards = Array(deck[0...26])
        player1.cards.sort(by:cmp)
        player2.cards = Array(deck[27...53])
        player2.cards.sort(by:cmp)
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
                HStack{
                    ForEach(player1.cards){ card in
                        Button(action: {}, label:{Text(String(card.id))})
                    }
                }.fixedSize().rotationEffect(Angle(degrees:90)).frame(width: 30)
                Spacer().frame(width:300)
                HStack{
                    ForEach(player2.cards){ card in
                        Button(action: {}, label:{Text(String(card.id))})
                    }
                }.fixedSize().rotationEffect(Angle(degrees:-90)).frame(width: 30)
            }
        }
    }
}

#Preview {
    ContentView()
}
