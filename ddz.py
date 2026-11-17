import numpy as np

class Card():
    def __init__(self, name, suit):
        self.name = name
        d = {"A":14, "2":15, "3":3, "4":4,
                     "5":5, "6":6, "7":7, "8":8,
                     "9":9, "10":10, "J":11, "Q":12, "K":13,"w":16,"W":17}
        self.value = d[name]
        self.suit = suit

    def print(self):
        if self.name == "w":
            print("Little Joker", end="")
            return
        if self.name == "W":
            print("Big Joker", end="")
            return
        print(self.name, "of", self.suit, end="")

class Player():
    def __init__(self, name, hand):
        self.name = name
        self.hand = hand

    def print(self):
        print(self.name, "has the following hand:")
        for card in self.hand:
            card.print()
            print(" ",end="")
        print("")

    def updateHand(self, newHand):
        self.hand = newHand

class Game():
    def __init__(self, deck, numPlayers, rules):
        self.deck = deck
        self.players = [Player(f"Player {i}", []) for i in range(numPlayers)]
        self.rules = rules

    def dealcards(self):
        np.random.shuffle(self.deck)
        deckSize = len(self.deck)
        numPlayers = len(self.players)
        assert deckSize % numPlayers == 0
        handSize = deckSize // numPlayers
        for i in range(0, numPlayers):
            self.players[i].updateHand(self.deck[i*handSize:(i+1)*handSize])

    def print(self):
        print("Deck:")
        for card in self.deck:
            card.print()
            print(" ",end="")
        print("")
        print("Players:")
        for player in self.players:
            player.print()
        print("Rules:")
        # rules.print()

if __name__ == "__main__":
    card1 = Card("K", "H")
    card2 = Card("Q", "H")

    d = {"A":14, "2":15, "3":3, "4":4,
         "5":5, "6":6, "7":7, "8":8,
         "9":9, "10":10, "J":11, "Q":12, "K":13}

    deck = []
    
    for suit in ["C","D","H","S"]:
        for key in d:
            deck.append(Card(key,suit))

    deck.append(Card("w",""))
    deck.append(Card("W",""))

    game = Game(deck, 2, [])

    game.print()
    game.dealcards()
    game.print()