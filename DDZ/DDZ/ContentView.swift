import SwiftUI
internal import Combine

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

class Player: ObservableObject{
    var name: Int
    var score: Int
    var cards: [Card]
    @Published var selectedCards: [Card] // Please implement me as as a priority queue and change clickCard to be better when you have the time :)
    var gameState: ((String, Int), Int)
//    var strategy: String?
    
    init(name: Int, score: Int, cards: [Card]){
        self.name = name
        self.score = 0
        self.cards = cards
        self.selectedCards = [Card]()
        self.gameState = (("",0),1)
    }
    
    func clickCard(card:Card){
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
    
    func beats() -> Bool{
        let myRule = getRule()
        let rule = gameState.0
        
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
    
    func playSelectedCards(){
        for card in cards{
            if (selectedCards.contains(where:{$0.id == card.id})) {
                cards.removeAll(where:{$0.id == card.id})
            }
        }
        selectedCards.removeAll()
    }
    
    func playTurn() -> (Player, (String, Int)){
        if (self.beats() && self.gameState.1 == self.name){
            let currentRule = self.getRule()
            self.playSelectedCards()
            return (self, currentRule)
        }
        return (self, ("no", 0))
    }
    
    func updateGameState(gs:((String, Int), Int)){
        self.gameState = gs
    }
    
    func pass() -> (Player, (String, Int)){
        if gameState.0.0 != ""{
            return (self, ("", 0))
        }
        return (self, ("no", 0))
    }
}

//class CPU {
//    var player: Player
//    var strategy: String
//    
//    init(player: Player){
//        self.player = player
//        self.strategy = "pass"
//    }
//    
//    func playTurn(){
//        if (self.strategy == "pass"){
//            player.pass()
//        }
//    }
//}

struct ContentView: View {
    @State var deck = [Card]()
    @StateObject var player1 = Player(name:1, score:0, cards:[Card]())
    @StateObject var player2 = Player(name:2, score:0, cards:[Card]())
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
    
    func processEvent(event:(Player, (String, Int))){
        let newRule = event.1
        let player = event.0
        // The player has passed
        if (newRule.0 == ""){
            currentTurn = 3-currentTurn
            currentRule = ("", 0)
            player1.updateGameState(gs: (currentRule, currentTurn))
            player2.updateGameState(gs: (currentRule, currentTurn))
            return
        }
        // It's a valid rule
        if (newRule.0 != "no"){
            currentRule = newRule
            currentTurn = 3-currentTurn
            player1.updateGameState(gs: (currentRule, currentTurn))
            player2.updateGameState(gs: (currentRule, currentTurn))
            if (player.cards.isEmpty){
                player.score += 1
                startRound()
            }
        }
    }
    
    var body: some View {
        ZStack {
            Image("background").ignoresSafeArea()
            
            VStack {
                Button(action: {startGame()}, label: {Text("Start Game")})
                Button(action: {startRound()}, label: {Text("Start Round")})
                Text(String(player1.name) + ": " + String(player1.score))
                Text(String(player2.name) + ": " + String(player2.score))
                Text(currentRule.0 + " " + String(currentRule.1))
                Text("current turn: " + String(currentTurn))
                Text("current P1: " + String(player1.cards.count))
                Text("current deck: " + String(deck.count))
                Text("current P1 selected: " + String(player1.selectedCards.count))
                Text("current P2 selected: " + String(player2.selectedCards.count))
            }
            HStack {
                VStack{
                    HStack{
                        Button(action: {
                            processEvent(event: player1.playTurn())
                        }, label: {Text("Play 1")})
                        Button(action: {
                            processEvent(event: player1.pass())
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
                            processEvent(event: player2.pass())
                            }, label: {Text("Play 2")})
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
