
import Foundation
import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = .zero
    weak var viewController: MovieQuizViewController?
    private let statisticService: StatisticServiceProtocol = StatisticService()
    var questionFactory: QuestionFactoryProtocol!
    
    
    
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage (data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: true)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            
            let bestGame = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            let totalGames = statisticService.gamesCount
            let bestGameText = """
                    Лучший результат: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                    Общая точность: \(String(format: "%.2f", totalAccuracy))%
                    """
            
            let text = """
                    Ваш результат: \(correctAnswers) из \(questionsAmount)
                    Количество сыграных квизов: \(totalGames)
                    \(bestGameText)
                    """
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
