import SwiftUI

struct Card: Identifiable, Comparable{
    let val: Int
    let suit: String
    let id: String
    
    static func <(card1:Card, card2:Card) -> Bool{
        if (card1.val < card2.val){
            return true
        }
        if (card1.val == card2.val) && (card1.suit < card2.suit){
            return true
        }
        return false
    }
}

struct Player{
    var name: String
    var score: Int
    var cards: [Card]
    var selectedCards: [Card] // Please implement me as as a priority queue and change clickCard to be better when you have the time :)
    
    mutating func clickCard(card:Card){
        if (selectedCards.contains(where:{$0.id == card.id})) {
            selectedCards.removeAll(where:{$0.id == card.id})
        }
        else{
            selectedCards.append(card)
            selectedCards.sort()
        }
    }
    
    func getRule() -> (String, Int){
        let n = selectedCards.count
        if (n == 0){
            return ("no", 0)
        }
        if (n == 1){
            return ("single", selectedCards[0].val)
        }
        if ((n == 2) && ((selectedCards[0].val + selectedCards[1].val) == 33)){
            return ("bomb", selectedCards[0].val)
        }
        if ((n == 2) && (selectedCards[0].val == selectedCards[1].val)){
            return ("double", selectedCards[0].val)
        }
        if ((n == 3) && (selectedCards[0].val == selectedCards[2].val)){
            return ("triple", selectedCards[0].val)
        }
        if ((n == 4) && (selectedCards[0].val == selectedCards[3].val)){
            return ("bomb", selectedCards[0].val)
        }
        if ((n == 4) && (selectedCards[0].val == selectedCards[2].val)){
            return ("three+one", selectedCards[0].val)
        }
        if ((n == 4) && (selectedCards[1].val == selectedCards[3].val)){
            return ("three+one", selectedCards[1].val)
        }
        if ((n == 5) && (selectedCards[0].val == selectedCards[2].val) && (selectedCards[3].val == selectedCards[4].val)){
            return ("three+two", selectedCards[0].val)
        }
        if ((n == 5) && (selectedCards[2].val == selectedCards[4].val) && (selectedCards[0].val == selectedCards[1].val)){
            return ("three+two", selectedCards[2].val)
        }
        if (n >= 5){
            var prev = selectedCards[0].val
            var isStraight = true
            for i in 1...(n-1){
                if ((selectedCards[i].val >= 15 ) || (selectedCards[i].val != (prev + 1))){
                    isStraight = false
                }
                prev += 1
            }
            if isStraight{return ("straight", selectedCards[n-1].val)}
        }
        if (n >= 5){ // EDIT THIS TO ALLOW ACE + TWO ON THE BOTTOM
            
        }
        if (n >= 6){ // Check for a straight of pairs. I think it doesn't allow A + 2 on the bottom and doesn't allow 2 on the top.
        }
        if (n >= 6){ // Add airplanes
        }
        return ("no", 0)
    }
    
    func beats(rule:(String, Int)) -> Bool{
        let myRule = getRule()
        
        // My hand is not valid
        if (myRule.0 == "no"){
            return false
        }
        
        // If there's no rule, I can do anything
        if (rule.0 == ""){
            return true
        }
        
        // I beat it with a hand of the same type
        if ((myRule.0 == rule.0) && (myRule.1 > rule.1)){
            return true
        }
        
        // I beat it with a bomb (prev case gets bigger bomb)
        if ((myRule.0 == "bomb") && (rule.0 != "bomb")){
            return true
        }
        
        return false
    }
    
    mutating func playSelectedCards(){
        for card in cards{
            if (selectedCards.contains(where:{$0.id == card.id})) {
                cards.removeAll(where:{$0.id == card.id})
            }
        }
        selectedCards.removeAll()
    }
}

struct ContentView: View {
    @State var deck = [Card]()
    @State var player1 = Player(name:"Player 1", score:0, cards:[Card](), selectedCards:[Card]())
    @State var player2 = Player(name:"Player 2", score:0, cards:[Card](), selectedCards:[Card]())
    @State var currentRule = ("",0)
    @State var currentTurn = 1
    
    func startGame(){
        player1.score = 0
        player2.score = 0
        deck.removeAll()
        for val in 3...15 {
            for suit in ["C", "D", "H", "S"] {
                deck.append(Card(val:val,suit:suit,id:(String(val)+suit)))
            }
        }
        deck.append(Card(val:16,suit:"",id:"16"))
        deck.append(Card(val:17,suit:"",id:"17"))
    }
    
    func startRound(){
        deck.shuffle();
        currentRule = ("",0)
        currentTurn = 1
        player1.cards = Array(deck[0...26])
        player1.cards.sort()
        player2.cards = Array(deck[27...53])
        player2.cards.sort()
        player1.selectedCards.removeAll()
        player2.selectedCards.removeAll()
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
                Button(action: {startGame()}, label: {Text("Start Game")})
                Button(action: {startRound()}, label: {Text("Start Round")})
                Text(player1.name + ": " + String(player1.score))
                Text(player2.name + ": " + String(player2.score))
                Text(currentRule.0 + " " + String(currentRule.1))
                Text("current turn: " + String(currentTurn))
            }
            HStack {
                VStack{
                    HStack{
                        Button(action: {
                            if ((player1.beats(rule:currentRule)) && (currentTurn == 1)){
                                currentRule = player1.getRule()
                                player1.playSelectedCards()
                                currentTurn = 2
                            }
                            if (player1.cards.isEmpty){
                                player1.score += 1
                                startRound()
                            }
                        }, label: {Text("Play 1")})
                        Button(action: {
                            if ((currentTurn == 1) && currentRule != ("", 0)){
                                currentTurn = 2
                                currentRule = ("", 0)
                            }
                        }, label: {Text("Pass 1")})
                    }
                    Text(describeCards(cards: player1.selectedCards))
                    HStack{
                        ForEach(player1.cards){ card in
                            Button(action: {player1.clickCard(card:card)}, label:{Text(String(card.id))})
                        }
                    }
                }.fixedSize().rotationEffect(Angle(degrees:90)).frame(width: 30)
                Spacer().frame(width:200)
                VStack{
                    HStack{
                        Button(action: {
                            if ((player2.beats(rule:currentRule)) && (currentTurn == 2)){
                                currentRule = player2.getRule()
                                player2.playSelectedCards()
                                currentTurn = 1
                            }
                            if (player2.cards.isEmpty){
                                player2.score += 1
                                startRound()
                            }
                        }, label: {Text("Play 2")})
                        Button(action: {
                            if ((currentTurn == 2) && currentRule != ("", 0)){
                                currentTurn = 1
                                currentRule = ("", 0)
                            }
                        }, label: {Text("Pass 2")})
                    }
                    Text(describeCards(cards: player2.selectedCards))
                    HStack{
                        ForEach(player2.cards){ card in
                            Button(action: {player2.clickCard(card:card)}, label:{Text(String(card.id))})
                        }
                    }
                }.fixedSize().rotationEffect(Angle(degrees:-90)).frame(width: 30)
            }
        }
    }
}

#Preview {
    ContentView()
}
