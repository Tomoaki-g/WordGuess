//
//  Words.swift
//  CodeBreaker
//
//  Created by CS193p Instructor on 4/16/25.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var words = Words.shared
}

@Observable
class Words {
    private var words = Dictionary<Int, Set<String>>()
    private(set) var loadingState: LoadingState = .loading
    private(set) var url = URL(string: "https://web.stanford.edu/class/cs193p/common.words")
    static let shared =
        Words(from: URL(string: "https://web.stanford.edu/class/cs193p/common.words"))

    private init(from url: URL? = nil) {
        load(url: url)
    }
    
    var count: Int {
        words.values.reduce(0) { $0 + $1.count }
    }
    
    func load(url: URL?) {
        guard let url else {
            loadingState = .failed
            return
        }
        loadingState = .loading

        Task {
            var _words = [Int:Set<String>]()

            do {
                for try await word in url.lines {
                    _words[word.count, default: Set<String>()].insert(word.uppercased())
                }
            } catch {
                print("Words could not load words from \(url): \(error)")
                loadingState = .failed
                return
            }
            
            words = _words
            loadingState = .loaded
            
            if count > 0 {
                print("Words loaded \(count) words from \(url.absoluteString)")
            }
        }
    }
    
    func contains(_ word: String) -> Bool {
        words[word.count]?.contains(word.uppercased()) == true
    }

    func random(length: Int) -> String? {
        let word = words[length]?.randomElement()
        if word == nil {
            print("Words could not find a random word of length \(length)")
        }
        return word
    }
    
    func attemptGuess(guessWord: inout [String], count: Int) -> Bool {
        let word = guessWord.joined()

        if !contains(word) {
            guessWord = Array(repeating: "", count: count)
            return false
        } else {
            return true
        }
    }
    
    func reset() -> String? {
        return random(length: Int.random(in: 3...6))
    }
    
    enum Kind: Equatable {
        case master
        case guess
        case attempt([String])
        case unknown
    }
    
    enum LoadingState {
        case loading
        case loaded
        case failed
    }
}

extension UITextChecker {
    func isAWord(_ word: String) -> Bool {
        rangeOfMisspelledWord(
            in: word,
            range: NSRange(location: 0, length: word.utf16.count),
            startingAt: 0,
            wrap: false,
            language: "en_US"
        ).location == NSNotFound
    }
}
