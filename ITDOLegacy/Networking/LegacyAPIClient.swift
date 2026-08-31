import Foundation

/// Урезанный сетевой клиент для legacy-таргета.
///
/// В отличие от `ITDOApp/Networking/APIClient.swift` (56KB, основной
/// таргет) сознательно НЕ использует:
/// - async/await (Swift 5.5 / iOS 13.4+ рантайм) — вместо этого
///   completion-handler колбэки на чистом URLSession, доступные с iOS 7;
/// - Combine (iOS 13+);
/// - URLSession.shared.data(for:) async-вариант — только
///   dataTask(with:completionHandler:), это API есть с iOS 7.
///
/// Это НЕ полный порт основного APIClient — только логин/токены, чтобы
/// был рабочий скелет. Остальные эндпоинты (чаты, лента, вложения)
/// нужно переносить сюда по мере портирования соответствующих экранов.
enum LegacyAPIError: Error, LocalizedError {
    case network(Error)
    case badStatus(Int)
    case decoding

    var errorDescription: String? {
        switch self {
        case .network(let error): return error.localizedDescription
        case .badStatus(let code): return "Сервер вернул ошибку (\(code))"
        case .decoding: return "Не удалось разобрать ответ сервера"
        }
    }
}

final class LegacyAPIClient {
    static let shared = LegacyAPIClient()
    private let session = URLSession(configuration: .default)

    private init() {}

    func login(username: String, password: String, completion: @escaping (Result<Void, LegacyAPIError>) -> Void) {
        let url = APIConfig.apiURL.appendingPathComponent("login")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "username": username,
            "password": password
        ])

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.network(error)))
                return
            }
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(.badStatus(code)))
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let token = json["access_token"] as? String else {
                completion(.failure(.decoding))
                return
            }
            KeychainStore.set(token, forKey: APIConfig.tokenKeychainKey)
            if let refresh = json["refresh_token"] as? String {
                KeychainStore.set(refresh, forKey: APIConfig.refreshTokenKeychainKey)
            }
            completion(.success(()))
        }
        task.resume()
    }
}
