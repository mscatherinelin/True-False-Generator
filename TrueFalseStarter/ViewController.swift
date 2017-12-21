//
//  ViewController.swift
//  TrueFalseStarter
//
//  Created by Pasan Premaratne on 3/9/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox

class ViewController: UIViewController {
    
    let questionsPerRound = 10
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion: Int = 0
    var indexOfSelectedTriviaData: Int = 0

    var gameSound: SystemSoundID = 0
    let triviaQuestions = TriviaGenerator()
    var questionsAlreadyAsked: [String] = []
    
    @IBOutlet weak var responseField: UILabel!
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    lazy var buttons: [UIButton] = [self.button1, self.button2, self.button3, self.button4]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameStartSound()
        // Start game
        playGameStartSound()
        displayQuestion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayQuestion() {
        responseField.isHidden = true
        
        var questionDictionary: [String: String]
        indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: triviaQuestions.trivia.count)
        questionDictionary = triviaQuestions.trivia[indexOfSelectedQuestion]
        
        //prevent repetition
        if var question = questionDictionary["Question"] {
            while questionsAlreadyAsked.contains(question){
                indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: triviaQuestions.trivia.count)
                questionDictionary = triviaQuestions.trivia[indexOfSelectedQuestion]
                question = questionDictionary["Question"]!
            }
            questionsAlreadyAsked.append(question)
        }
        
        if questionDictionary["Answer"] == "True" || questionDictionary["Answer"] == "False" {
            button3.isHidden = true
            button4.isHidden = true
            button1.setTitle("True", for: .normal)
            button2.setTitle("False", for: .normal)
        } else {
            button3.isHidden = false
            button4.isHidden = false
            button1.setTitle(questionDictionary["Option 1"], for: .normal)
            button2.setTitle(questionDictionary["Option 2"], for: .normal)
            button3.setTitle(questionDictionary["Option 3"], for: .normal)
            button4.setTitle(questionDictionary["Option 4"], for: .normal)
        }
        
        questionField.text = questionDictionary["Question"]
        questionsAlreadyAsked.append(questionDictionary["Question"]!)
        playAgainButton.isHidden = true
    }

    func displayScore() {
        // Hide the answer buttons
        responseField.isHidden = true
        button1.isHidden = true
        button2.isHidden = true
        button3.isHidden = true
        button4.isHidden = true

        // Display play again button
        playAgainButton.isHidden = false

        questionField.text = "Way to go!\nYou got \(correctQuestions) out of \(questionsPerRound) correct!"

    }
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        responseField.isHidden = false
        // Increment the questions asked counter
        questionsAsked += 1
        
        let selectedQuestionDict: Dictionary<String,String>
        
        //when button is clicked, lowlight the rest of the buttons
        for button in buttons {
            if(button == sender){
                continue
            }
            button.backgroundColor = UIColor(red: 1/255.0, green: 52/255.0, blue: 70/255.0, alpha: 1.0)
        }
        
        selectedQuestionDict = triviaQuestions.trivia[indexOfSelectedQuestion]
        if let correctAnswer = selectedQuestionDict["Answer"] {
            
            if (sender == button1 &&  correctAnswer == "True") || (sender == button1 && correctAnswer == "1") || (sender == button2 && correctAnswer == "2") || (sender == button3 && correctAnswer == "3") || (sender == button3 && correctAnswer == "4"){
                correctQuestions += 1
                responseField.text = "Correct!"
                responseField.textColor = UIColor(red: 105/255.0, green: 94/255.0, blue: 133/255.0, alpha: 1.0)
            } else {
                responseField.textColor = UIColor(red: 116/255.0, green: 150/255.0, blue: 61/255.0, alpha: 1.0)
                responseField.text = "Sorry, the answer is incorrect!"
            }
            
        }

        loadNextRoundWithDelay(seconds: 2)
    }
    
    func buttonColorReset(){
        for button in buttons {
            button.backgroundColor = UIColor(red:12/255.0, green:121/255.0, blue:150/255.0, alpha:1.0)
        }
    }

    func nextRound() {
        
        //reset the color of the buttons
        buttonColorReset()
        
        if questionsAsked == questionsPerRound {
            // Game is over
            displayScore()
        } else {
            // Continue game
            displayQuestion()
        }
    }

    @IBAction func playAgain() {
        // Show the answer buttons
        button1.isHidden = false
        button2.isHidden = false
        button3.isHidden = false
        button4.isHidden = false

        questionsAsked = 0
        correctQuestions = 0
        nextRound()
    }
    
    
    // MARK: Helper Methods
    
    func loadNextRoundWithDelay(seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)

        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.nextRound()
        }
    }

    func loadGameStartSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "GameSound", ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
}

