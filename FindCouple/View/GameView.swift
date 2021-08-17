//
//  GameView.swift
//  FindCouple
//
//  Created by mr. Hakoda on 13.08.2021.
//

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

import SwiftUI

struct GameView: View {
    @EnvironmentObject var model: Model
    
    @Binding var isPresented: Bool
//    @Binding var cardModel: [[CardModel]]
    @Binding var matchArray: [String]
    @Binding var isGameOver: Bool
    @Binding var localScore: Double
    
    @State var isOpened = true
    @State var progressValue: Double = 0.0
    @State var nextLevel = false
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                
                Text("\(Int(localScore / 2)) / \((model.cardBehavior.countCardRow * model.cardBehavior.countCardRow) / 2)")
                    .font(.title)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                
                ProgressBar(value: $progressValue, geo: geo).frame(height: 4)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                
                VStack {
                    ForEach(model.cardBehavior.cardModel, id: \.self) { array in
                        CardRow(isOpened: $isOpened, matchArray: $matchArray, array: array, localScore: $localScore, progressValue: $progressValue, isGameOver: $isGameOver, nextLevel: $nextLevel, geo: geo).environmentObject(model)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 20)
                
                if nextLevel {
                    Button(action: {
                        nextLevel = false
                        model.gameModel.localScore += 1
                        model.gameModel.level += 1
                        localScore = 0.0
                        
                       if model.gameModel.level == 3 {
                            model.gameModel.timeOfLevel = 1.0
                            model.cardBehavior.countCardRow = 4
                        } else if model.gameModel.level == 5 {
                            model.cardBehavior.closeAllCardsDelay = 2.0
                        } else if model.gameModel.level == 6 {
                            model.gameModel.timeOfLevel = 0.5
                        } else if model.gameModel.level == 7 {
                            model.gameModel.timeOfLevel = 1.5
                            model.cardBehavior.closeAllCardsDelay = 3.0
                            model.cardBehavior.countCardRow = 5
                        } else if model.gameModel.level == 9 {
                            model.gameModel.timeOfLevel = 1.0
                        }
                        
                        startRound()
                        resetProgressBar()
                        isOpened = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + model.cardBehavior.closeAllCardsDelay) {
                            isOpened = false
                            startProgressBar()
                        }
                    }) {
                        Text("Продолжить")
                            .padding()
                            .foregroundColor(Color.white)
                    }
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding()
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Уровень \(model.gameModel.level)", displayMode: .inline)
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + model.cardBehavior.closeAllCardsDelay) {
                isOpened = false
                startProgressBar()
            }
        })
    }
    
    func startProgressBar() {
        var runCount = 0.0

        Timer.scheduledTimer(withTimeInterval: model.gameModel.timeOfLevel, repeats: true) { timer in
            self.progressValue += 0.0166
            runCount += 0.0166
            
            if nextLevel {
                timer.invalidate()
                resetProgressBar()
            }

            if runCount > 1.0 && !nextLevel {
                timer.invalidate()
                gameOver()
                resetProgressBar()
            }
        }
    }
    
    func resetProgressBar() {
        self.progressValue = 0.0
    }
    
    func gameOver() {
        let oldScore = UserDefaults.standard.integer(forKey: "Score")
        if model.gameModel.localScore > oldScore {
            UserDefaults.standard.set(model.gameModel.score, forKey: "Score")
        }
        localScore = 0.0
        matchArray = [String()]
        progressValue = 0.0
        isOpened = false
        isPresented = false
        isGameOver = true
    }
    
    func startRound() {
        var cardModelArray = [CardModel()]
        let array = model.cardBehavior.finalArray
        for index in 0..<array.count {
            var cardModel = CardModel()
            cardModel.id = index
            cardModel.card = array[index]
            cardModel.isLocalOpened = false
            cardModelArray.append(cardModel)
        }
        let filtered = cardModelArray.filter({ $0.card != ""})
        let chankedArray = filtered.chunked(into: model.cardBehavior.countCardRow)
        model.cardBehavior.cardModel = chankedArray
    }
}
