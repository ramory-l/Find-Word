//
//  ViewController.swift
//  Challenge
//
//  Created by Mikhail Strizhenov on 15.04.2020.
//  Copyright © 2020 Mikhail Strizhenov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var scoreLabel: UILabel!
    var goalWordLabel: UILabel!
    var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    var usedLetters = [String]()
    var words: [String]!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var activatedButtons = [UIButton]()
    var letterButtons = [UIButton]()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        goalWordLabel = UILabel()
        goalWordLabel.translatesAutoresizingMaskIntoConstraints = false
        goalWordLabel.textAlignment = .center
        goalWordLabel.font = UIFont.systemFont(ofSize: 28)
        goalWordLabel.text = ""
        view.addSubview(goalWordLabel)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            goalWordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goalWordLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 100),
            
            buttonsView.topAnchor.constraint(equalTo: goalWordLabel.bottomAnchor, constant: 100),
            buttonsView.widthAnchor.constraint(equalToConstant: 350),
            buttonsView.heightAnchor.constraint(equalToConstant: 350),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

        ])
        
        let width = 27
        let height = 50
        
        for row in 0..<2 {
            for column in 0..<13 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                letterButton.setTitle("W", for: .normal)
                letterButton.layer.borderWidth = 1
                letterButton.layer.borderColor = UIColor.lightGray.cgColor
                letterButton.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
                
                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
            }
        }
        
        scoreLabel.backgroundColor = .green
        goalWordLabel.backgroundColor = .blue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performSelector(inBackground: #selector(loadWords), with: nil)
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonLetter = sender.titleLabel?.text else { return }
        var tempWord = ""
        let word = words.first!
        if word.contains(buttonLetter) {
            score += 1
            usedLetters.append(buttonLetter)
            sender.isHidden = true
        } else {
            score -= 1
            if score < 0 {
                let ac = UIAlertController(title: "You lose", message: "Try again...", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                loadWords()
                score = 0
                for button in letterButtons {
                    button.isHidden = false
                }
            }
        }
        for letter in word {
            if usedLetters.contains(String(letter)) {
                tempWord.append(letter)
            } else {
                tempWord.append("?")
            }
        }
        goalWordLabel.text = tempWord
        if !(goalWordLabel.text?.contains("?"))! {
            usedLetters.removeAll()
            
            loadWords()
            for button in letterButtons {
                button.isHidden = false
            }
        }
    }
    
    @objc func loadWords() {
        if let wordsFileURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let content = try? String(contentsOf: wordsFileURL) {
                words = content.components(separatedBy: "\n")
                words.removeAll() { $0 == "" }
                words.shuffle()
                guard let word = words?.first else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.goalWordLabel.text = ""
                    for _ in word {
                        self?.goalWordLabel.text?.append("?")
                    }
                    for (i, letter) in (self?.alphabet.shuffled().enumerated())! {
                        let strLetter = String(letter)
                        self?.letterButtons[i].setTitle(strLetter, for: .normal)
                    }
                }
            }
        }
    }
}

