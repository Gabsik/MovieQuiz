import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter?
    private var correctAnswers: Int = .zero
    private var questionFactory: QuestionFactoryProtocol!
    private var currentQuestion: QuizQuestion?
    private let presenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
        changeStateButton(isEnabled: true)
        
        showLoadingIndicator()
        questionFactory.loadData()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        changeStateButton(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let bestGame = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            let totalGames = statisticService.gamesCount
            let bestGameText = """
                    Лучший результат: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                    Общая точность: \(String(format: "%.2f", totalAccuracy))%
                    """
            
            let text = """
                    Ваш результат: \(correctAnswers) из \(presenter.questionsAmount)
                    Количество сыграных квизов: \(totalGames)
                    \(bestGameText)
                    """
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            //currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
            imageView.layer.borderWidth = 0
            changeStateButton(isEnabled: true)
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        alertPresenter = AlertPresenter(viewController: self)
        let alert = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
                self.imageView.layer.borderWidth = 0
                self.changeStateButton(isEnabled: true)
            }
        alertPresenter?.showAlert(model: alert)
    }
    
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    //MARK: - activityIndicator
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    //MARK: - ERORR ALERT
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        alertPresenter = AlertPresenter(viewController: self)
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [ weak self ] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory.requestNextQuestion()
        }
        alertPresenter?.showAlert(model: model)
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
}
