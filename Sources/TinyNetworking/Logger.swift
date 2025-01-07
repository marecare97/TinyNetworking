//
//  Logger.swift
//  NetworkingTest
//
//  Created by Aleksandar Vukovic on 20.11.24..
//

import Foundation
import os

public extension Logger {
    
    func logRequest(_ request: URLRequest) {
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = URLComponents(string: urlAsString)
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = urlComponents?.query != nil && !urlComponents!.query!.isEmpty ? "?\(urlComponents?.query ?? "")" : ""
        let host = "\(urlComponents?.host ?? "")"
        var output = """
       🔵 HTTP Request 🔵
       🕣 \(timeStamp())
       
       Host: \(host)\n⎺⎺⎺⎺⎺
       Method/path: \(method) \(path)\(query)\n⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
       Headers:\n⎺⎺⎺⎺⎺⎺⎺⎺\n
       """
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            output += "\(key): \(value) \n\n"
        }
        if let body = request.httpBody {
            if let json = body.prettyJSONString {
                output += "Body:\n⎺⎺⎺⎺⎺\n\(json)\n"
            } else {
                output += "Body: Binary Data\n⎺⎺⎺⎺⎺\n"
            }
        }
        info("\(output, privacy: .public)")
    }
    
    func logResponse(_ response: HTTPResponse) {
        let request = response.urlRequest
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = URLComponents(string: urlAsString)
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = urlComponents?.query != nil && !urlComponents!.query!.isEmpty ? "?\(urlComponents?.query ?? "")" : ""
        let host = "\(urlComponents?.host ?? "")"
        var output = """
       🟢 HTTP Response 🟢
       🕣 \(timeStamp())\n
       Host: \(host)\n⎺⎺⎺⎺⎺
       Method/path: \(method) \(path)\(query)\n⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
       Response Body:\n⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺\n
       """
        if let body = response.data {
            if let json = body.prettyJSONString {
                output += "\(json)\n"
            } else {
                output += "(Binary data)\n"
            }
            
        }
        info("\(output, privacy: .public)")
    }
    
    func logError(_ response: HTTPResponse, _ error: Error) {
        let request = response.urlRequest
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = URLComponents(string: urlAsString)
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = urlComponents?.query != nil && !urlComponents!.query!.isEmpty ? "?\(urlComponents?.query ?? "")" : ""
        let host = "\(urlComponents?.host ?? "")"
        var output = """
       🔴 HTTP Error 🔴
       🕣 \(timeStamp())\n
       Host: \(host)\n⎺⎺⎺⎺⎺
       Method/path: \(method) \(path)\(query)\n⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺\n
       """
        
        if let error = error as? HTTPError {
            switch error {
            case .noData:
                output += "Error: no data"
            case .statusCode(let response):
                output += "Status code: \(error.response?.httpURLResponse?.statusCode ?? -1)\n⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺\n"
                output += "Response Body:\n⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺\n"
                if let body = response.data {
                    if let json = body.prettyJSONString {
                        output += "\(json)\n"
                    } else {
                        output += "(Binary data)\n"
                    }
                }
            case .decoding(_, _):
                output += "Error: Decoding error\n"
            case .networkLayer(let error, _):
                if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    output += "Error: No internet\n"
                } else { output += "Error: Unrecognized network error\n" }
            }
        } else {
            output += "Error: \(error.localizedDescription)\n⎺⎺⎺⎺⎺⎺\n"
        }
        self.error("\(output, privacy: .public)")
    }
    
    private func timeStamp(date: Date = Date()) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSSSSSS yyyy-MM-dd"
        
        return formatter.string(from: date)
    }
}
