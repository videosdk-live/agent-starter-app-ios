//
//  APIService.swift
//  agent-starter-ios
//
//  Created by Parth Asodariya on 16/03/26.
//

import Foundation

enum EndPoint {
    case getToken
    case createMeeting(String)
    case validateMeeting(String, String)
    case dispatchAgent(meetingId: String, agentId: String, versionId: String?, variables: [String: Any]?)
    case getAgentVersions(agentId: String)

    var baseURL: URL {
        URL(string: "https://api.videosdk.live")!
    }

    var value: String {
        switch self {
        case .getToken:
            return "get-token"
        case .createMeeting:
            return "/v2/rooms"
        case .validateMeeting(let meetingId, _):
            return "/v2/rooms/validate/\(meetingId)"
        case .dispatchAgent:
            return "/v2/agent/dispatch"
        case .getAgentVersions(let agentId):
            return "/ai/v1/agents/\(agentId)/versions"
        }
    }

    var method: String {
        switch self {
        case .createMeeting, .validateMeeting, .dispatchAgent:
            return "POST"
        default:
            return "GET"
        }
    }

    var body: Data? {
        switch self {
        case .getToken, .getAgentVersions:
            return nil

        case .createMeeting(let token):
            let params = ["token": token]
            return try? JSONSerialization.data(
                withJSONObject: params,
                options: []
            )

        case .validateMeeting(_, let token):
            let params = ["token": token]
            return try? JSONSerialization.data(
                withJSONObject: params,
                options: []
            )

        case .dispatchAgent(let meetingId, let agentId, let versionId, let variables):
            var body: [String: Any] = [
                "meetingId": meetingId,
                "agentId": agentId,
            ]
            if let versionId = versionId, !versionId.isEmpty {
                body["versionId"] = versionId
            }
            if let variables = variables, !variables.isEmpty {
                body["metadata"] = [
                    "variables": variables
                ]
            }
            return try? JSONSerialization.data(
                withJSONObject: body,
                options: []
            )
        }
    }

    var request: URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(value))
        request.httpMethod = method
        request.addValue(
            MeetingConfig.AUTH_TOKEN,
            forHTTPHeaderField: "Authorization"
        )
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }
}

class APIService {

    class func getToken(completion: @escaping (Result<String, Error>) -> Void) {
        let request = EndPoint.getToken.request

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                    let token = data.toJSON()["token"] as? String
                {
                    completion(.success(token))
                } else if let err = error {
                    completion(.failure(err))
                }
            }
        }
        .resume()
    }

    class func createMeeting(
        token: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = EndPoint.createMeeting(token).request

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                    let meetingId = data.toJSON()["roomId"] as? String
                {
                    completion(.success(meetingId))
                } else if let err = error {
                    completion(.failure(err))
                } else {
                    print("Error while create meeting")
                }
            }
        }
        .resume()
    }

    class func validateMeeting(
        id: String,
        token: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = EndPoint.validateMeeting(id, token).request

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                    let meetingId = data.toJSON()["meetingId"] as? String
                {
                    completion(.success(meetingId))
                } else if let err = error {
                    completion(.failure(err))
                }
            }
        }
        .resume()
    }

    // Updated dispatchAgent with versionId check and chaining
    class func dispatchAgent(
        meetingId: String,
        agentId: String,
        versionId: String? = nil,
        variables: [String: Any]? = nil,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        // Helper to actually make the dispatchAgent call
        func performDispatch(with versionIdToUse: String?) {
            let endpoint = EndPoint.dispatchAgent(
                meetingId: meetingId,
                agentId: agentId,
                versionId: versionIdToUse,
                variables: variables
            )
            let request = endpoint.request

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(
                        .failure(
                            NSError(
                                domain: "APIServiceError",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "No data received"]
                            )
                        )
                    )
                    return
                }

                let responseDict = data.toJSON()
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(
                        .failure(
                            NSError(
                                domain: "APIServiceError",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Invalid response"]
                            )
                        )
                    )
                    return
                }

                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201
                {
                    if let dataDict = responseDict["data"] as? [String: Any],
                        dataDict["success"] as? Bool == true
                    {
                        completion(.success(responseDict))
                        return
                    }
                }

                let message =
                    responseDict["message"] as? String
                    ?? "Agent dispatch failed. Please try again."
                completion(
                    .failure(
                        NSError(
                            domain: "APIServiceError",
                            code: httpResponse.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: message]
                        )
                    )
                )
            }.resume()
        }

        // If versionId is nil or empty, fetch agent versions first
        if versionId == nil || versionId?.isEmpty == true {
            getAgentVersions(agentId: agentId) { result in
                switch result {
                case .success(let versions):
                    if let firstVersion = versions.first,
                       let latestVersionId = firstVersion["versionId"] as? String {
                        performDispatch(with: latestVersionId)
                    } else {
                        completion(
                            .failure(
                                NSError(
                                    domain: "APIServiceError",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "No versions found for agent"]
                                )
                            )
                        )
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            performDispatch(with: versionId)
        }
    }

    // MARK: - Get Agent Versions
    class func getAgentVersions(
        agentId: String,
        completion: @escaping (Result<[[String: Any]], Error>) -> Void
    ) {
        let request = EndPoint.getAgentVersions(agentId: agentId).request

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "APIServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "APIServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }

                let responseDict = data.toJSON()
                if httpResponse.statusCode != 200 {
                    let message = responseDict["message"] as? String ?? "Failed to fetch agent versions"
                    completion(.failure(NSError(domain: "APIServiceError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])))
                    return
                }

                guard let versions = responseDict["versions"] as? [[String: Any]], !versions.isEmpty else {
                    completion(.failure(NSError(domain: "APIServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No versions found for agent"])))
                    return
                }

                completion(.success(versions))
            }
        }.resume()
    }
}

extension Data {

    /// Data to JSON String
    /// - Returns: json string
    public func toJSONString() -> String {
        String(data: self, encoding: .utf8) ?? ""
    }

    /// Data to JSON Dictionary
    /// - Returns: json dictionary
    public func toJSON() -> [String: Any] {
        let object = try? JSONSerialization.jsonObject(with: self, options: [])
        return object as? [String: Any] ?? [:]
    }

    /// Data to JSON array
    /// - Returns: json array
    public func toJSONArray() -> [Any] {
        let array = try? JSONSerialization.jsonObject(with: self, options: [])
        return array as? [Any] ?? []
    }
}
