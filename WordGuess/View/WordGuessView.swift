//
//  WordGuessView.swift
//  WordGuess
//
//  Created by takemoto on 2026/11/25.
//

import SwiftUI
import UIKit

struct WordGuessView: View {
    @Environment(\.words) var words
    @State private var attempts: [String] = []
    @State private var masterWord: String? = nil
    @State private var guessWord: [String] = []
    @State private var isSolved = false
    
    var body: some View {
        VStack {
            if let masterWord, masterWord != "" {
                restartButton
                    .padding()
                
                WordView(masterWord: masterWord, kind: .master(isHidden: true), guessWord: $guessWord, isSolved: $isSolved) { _ in
                    // マスターコードの行は何もしない
                }
                    .environment(\.words, words)
                
                ScrollView {
                    VStack(spacing: 8) {
                        WordView(masterWord: masterWord, kind: .attempt(guessWord), guessWord: $guessWord, isSolved: $isSolved) { answer in
                            withAnimation {
                                if !isSolved {
                                    attempts.append(answer)
                                }
                            }
                        }
                        .environment(\.words, words)

                        ForEach(attempts.indices.reversed(), id: \.self) { index in
                            let letters = Array(attempts[index])
                            let masterLetters = Array(masterWord)
                            
                            HStack(spacing: 8) {
                                ForEach(0..<masterWord.count, id: \.self) { letterIndex in
                                    let isExact = letters.indices.contains(letterIndex)
                                        && masterLetters[letterIndex] == letters[letterIndex]
                                    Circle()
                                        .fill(isExact ? Color.yellow.opacity(0.4) : Color.gray.opacity(0.4))
                                        .overlay {
                                            Text(letters.indices.contains(letterIndex)
                                                 ? String(letters[letterIndex]) : "")
                                        }
                                        .aspectRatio(1, contentMode: .fit)
                                }

                                Color.clear
                                    .aspectRatio(1, contentMode: .fit)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        }
                    }
                }
            } else {
                ProgressView("読み込み中・・・")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: words.count, initial: true) {
            if words.count > 0, masterWord == nil {
                masterWord = words.random(length: Int.random(in: 3...6))
                guessWord = Array(repeating: "", count: masterWord!.count)
                print("masterWord: \(masterWord ?? "")")
            }
        }
    }
    
    var restartButton: some View {
        Button {
            isSolved = false
            masterWord = words.reset()
            attempts.removeAll()
            
            if let masterWord {
                guessWord = Array(repeating: "", count: masterWord.count)
            }
            print("masterWord: \(masterWord ?? "")")
        } label: {
            Text("Restart")
                .font(.system(size: 30))
                .minimumScaleFactor(0.1)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        }
        .foregroundStyle(.black)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
        }
        .buttonBorderShape(.roundedRectangle(radius: 8))
    }
}

#Preview {
    WordGuessView()
}
