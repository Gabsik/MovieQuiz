
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func updateUI(state: UIState) {}
    func show(quiz step: QuizStepViewModel) {}
    func show(quiz result: QuizResultsViewModel) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showNetworkError(message: String) {}
}
