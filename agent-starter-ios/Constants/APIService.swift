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
        }
    }

    var method: String {
        switch self {
        case .createMeeting, .validateMeeting:
            return "POST"
        default:
            return "GET"
        }
    }

    var body: Data? {
        switch self {
        case .getToken:
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
        }
    }

    var request: URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(value))
        request.httpMethod = method
        request.addValue(
            MeetingConfig.AUTH_TOKEN,
            forHTTPHeaderField: "Authorization"
        )
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

    class func dispatchAgent(
        meetingId: String,
        agentId: String,
        versionId: String? = nil,
        variables: [String: Any]? = nil,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        guard
            let url = URL(string: "https://api.videosdk.live/v2/agent/dispatch")
        else {
            completion(
                .failure(
                    NSError(
                        domain: "APIServiceError",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
                    )
                )
            )
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            MeetingConfig.AUTH_TOKEN,
            forHTTPHeaderField: "Authorization"
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "meetingId": meetingId,
            "agentId": agentId,
        ]
        if versionId != nil {
            body["versionId"] = versionId ?? ""
        }
        if variables != nil && !(variables ?? [:]).isEmpty {
            body["metadata"] = [
                "variables": variables ?? [:]
            ]
        }

        do {
            request.httpBody = try JSONSerialization.data(
                withJSONObject: body,
                options: []
            )
        } catch {
            completion(.failure(error))
            return
        }

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
                            userInfo: [
                                NSLocalizedDescriptionKey: "No data received"
                            ]
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
                            userInfo: [
                                NSLocalizedDescriptionKey: "Invalid response"
                            ]
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
