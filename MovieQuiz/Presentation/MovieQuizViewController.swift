import UIKit


enum UIState {
    case answerResult(isCorrect: Bool)
    case resetBorder
}

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func updateUI(state: UIState)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter?
    private var currentQuestion: QuizQuestion?
    private var presenter: MovieQuizPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter?.changeStateButton(isYes: true)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter?.changeStateButton(isYes: false)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        
        alertPresenter = AlertPresenter(viewController: self)
        
        let message = presenter?.makeResultsMessage() ?? "Результаты недоступны"
        
        let alert = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText
        ) { [weak self] in
            
            guard let self = self else { return }
            self.presenter?.restartGame()
        }
        alertPresenter?.showAlert(model: alert)
    }
    
    func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        alertPresenter = AlertPresenter(viewController: self)
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [ weak self ] in
            guard let self = self else { return }
            self.presenter?.restartGame()
        }
        alertPresenter?.showAlert(model: model)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func updateUI(state: UIState) {
        switch state {
        case .answerResult(let isCorrect):
            changeStateButton(isEnabled: false)
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        case .resetBorder:
            changeStateButton(isEnabled: true)
            imageView.layer.borderWidth = 0
        }
    }
    
}
