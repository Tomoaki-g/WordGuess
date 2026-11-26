//
//  WordView.swift
//  CodeBreaker
//
//  Created by takemoto on 2026/11/24.
//

import SwiftUI

struct WordView: View {
    @Environment(\.words) private var words
    let masterWord: String
    let maxLength = 1
    let kind: Words.Kind
    @FocusState private var isFocused: Bool
    @FocusState private var selection: Int?
    @State var text: String = ""
    @State var masterText: String = ""
    @Binding var guessWord: [String]
    @Binding var isSolved: Bool
    
    var onGuess: (String) -> Void = { _ in }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<masterWord.count, id: \.self) { index in
                pegShape(text: masterFlag ? masterWord : text, index: index)
                    .background {
                        if selection == index && !masterFlag {
                            Circle()
                                .foregroundStyle(Color.gray.opacity(0.8))
                        }
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            if !masterFlag {
                                selection = index
                                isFocused = true
                            }
                        }
                    )
            }
            
            Color.clear.aspectRatio(1, contentMode: .fit)
                .overlay {
                    if !masterFlag && !isSolved {
                        guessButton
                    }
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    func pegShape(text: String, index: Int) -> some View {
        Circle()
            .fill(isSolved && !masterFlag ? Color.yellow.opacity(0.4) : Color.gray.opacity(0.4))
            .overlay {
                if case .master(_) = kind {
                    if isSolved {
                        Text(String(Array(masterWord)[index]))
                    }
                } else {
                    TextField("", text: $guessWord[index].max(maxLength))
                        .keyboardType(.asciiCapable)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled(true)
                        .multilineTextAlignment(.center)
                        .focused($selection, equals: index)
                        .disabled(masterFlag || isSolved)
                        .onChange(of: guessWord[index]) { _, newValue in
                            guard selection == index,
                                  !guessWord[index].isEmpty else { return }
                            guessWord[index] = newValue.uppercased()
                            
                            if index + 1 < guessWord.count {
                                selection = index + 1
                            } else {
                                selection = 0
                            }
                        }
                }
            }
    }
    
    var guessButton: some View {
        Button("Guess") {
            let answer = guessWord.joined().uppercased()
            
            withAnimation {
                if words.attemptGuess(guessWord: &guessWord, count: masterWord.count) {
                    isSolved = guessWord.joined().uppercased() == masterWord.uppercased()

                    if !isSolved {
                        guessWord = Array(repeating: "", count: masterWord.count)
                    }
                }
                onGuess(answer)
                selection = isSolved ? nil : 0
            }
        }
        .font(.system(size: 30))
        .minimumScaleFactor(0.1)
        .lineLimit(1)
        .disabled(guessWord.count != masterWord.count || guessWord.contains(where: { $0.isEmpty }))
    }
    
    var masterFlag: Bool {
        switch kind {
        case .guess, .attempt(_):
            return false
        case .master(_), .unknown:
            return true
        }
    }
}

extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = String(newValue.suffix(limit))
            }
        )
    }
}

#Preview {
    @Previewable @State var guessWord = Array(repeating: "", count: 5)
    @Previewable @State var isSolved = false

    WordView(
        masterWord: "APPLE",
        kind: .guess,
        guessWord: $guessWord,
        isSolved: $isSolved
    )
}
