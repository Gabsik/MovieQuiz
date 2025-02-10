import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter?
//    private var questionFactory: QuestionFactoryProtocol!
    private var currentQuestion: QuizQuestion?
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
//        self.questionFactory = questionFactory
        
//        questionFactory.requestNextQuestion()
        changeStateButton(isEnabled: true)
        
        showLoadingIndicator()
//        questionFactory.loadData()
        presenter = MovieQuizPresenter(viewController: self)
//        presenter.viewController = self
    }
    
//    func didReceiveNextQuestion(question: QuizQuestion?) {
//        presenter.didReceiveNextQuestion(question: question)
//    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {

        presenter.didAnswer(isCorrectAnswer: isCorrect)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        changeStateButton(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
//            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            self.changeStateButton(isEnabled: true)
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    func show(quiz result: QuizResultsViewModel) {
        alertPresenter = AlertPresenter(viewController: self)
        let alert = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
//                self.questionFactory.requestNextQuestion()
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
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    //MARK: - ERORR ALERT
     func showNetworkError(message: String) {
        hideLoadingIndicator()
        alertPresenter = AlertPresenter(viewController: self)
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [ weak self ] in
            guard let self = self else { return }
            self.presenter.restartGame()
//            self.questionFactory.requestNextQuestion()
        }
        alertPresenter?.showAlert(model: model)
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    //    func didLoadDataFromServer() {
    //        activityIndicator.isHidden = true
    //        questionFactory.requestNextQuestion()
    //    }
    
    //    func didFailToLoadData(with error: Error) {
    //        showNetworkError(message: error.localizedDescription)
    //    }
    
    func hideLoadingIndicatorr() {
        activityIndicator.isHidden = true
    }
    
}
