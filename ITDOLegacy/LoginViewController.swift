import UIKit

/// Минимальный экран входа для legacy-клиента.
///
/// Написан на UIKit + программный Auto Layout (без Storyboard/SwiftUI),
/// чтобы не тянуть зависимость от Interface Builder форматов, которые
/// иногда ведут себя иначе в старых Xcode. Никаких API новее iOS 9:
/// без UIStackView spacing-новшеств iOS 11+, без SF Symbols (iOS 13+,
/// здесь просто текстовая кнопка).
final class LoginViewController: UIViewController {

    private let loginField = UITextField()
    private let passwordField = UITextField()
    private let submitButton = UIButton(type: .system)
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ITDO"
        view.backgroundColor = .white
        setupLayout()
    }

    private func setupLayout() {
        loginField.placeholder = "Логин"
        loginField.borderStyle = .roundedRect
        loginField.autocapitalizationType = .none
        loginField.autocorrectionType = .no

        passwordField.placeholder = "Пароль"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true

        submitButton.setTitle("Войти", for: .normal)
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)

        statusLabel.text = ""
        statusLabel.textColor = .red
        statusLabel.numberOfLines = 0
        statusLabel.font = UIFont.systemFont(ofSize: 13)

        let stack = UIStackView(arrangedSubviews: [loginField, passwordField, submitButton, statusLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func didTapSubmit() {
        guard let login = loginField.text, !login.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            statusLabel.text = "Заполните логин и пароль"
            return
        }
        submitButton.isEnabled = false
        statusLabel.text = ""

        LegacyAPIClient.shared.login(username: login, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.submitButton.isEnabled = true
                switch result {
                case .success:
                    // TODO: перейти на основной экран после появления
                    // legacy-порта чатов/ленты.
                    self.statusLabel.textColor = .systemGreen
                    self.statusLabel.text = "Успешный вход"
                case .failure(let error):
                    self.statusLabel.textColor = .red
                    self.statusLabel.text = error.localizedDescription
                }
            }
        }
    }
}
