//
//  NetworkManager.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/15.
//

import Foundation
import Alamofire

class NetworkManager {
    /// 네트워크 에러 종류
    enum NetworkError: Error {
        case invalidUrl
        case invalidResponse
        case jsonParse
        case accessTokenDenied
        case naverInvaildNameOrEmail
        case couponBuyConflict
        case noCouponAvailable
        case unknown
    }
    
    static var checkOnlyOne = false
    
    typealias NetworkResultHandler<T> = (Result<T, NetworkError>) -> Void
    /// 리퀘스트 생성. 메소드에 따라 겟, 포스트, 딜리트로 분기
    class func request<T: Decodable>(urlString: String, method: HTTPMethod, headers: [String: String]? = nil, parameters: [String: Any]? = nil, _ handler: @escaping NetworkResultHandler<T>) {
        guard
            let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encodedString)
        else {
            handler(.failure(.invalidUrl))
            return
        }
    
        /// 헤더가 있는 경우 HTTPHeaders 생성 (Alamofire 양식)
        var httpHeaders: HTTPHeaders?
        if let headers = headers {
            httpHeaders = HTTPHeaders(headers)
        }
      
        /// 리퀘스트 발싸
        AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: httpHeaders)
            .responseJSON { response in
                switch response.result {
                case .success:  /// 리스폰을 잘 받았을 경우.
                    if let error = response.error { /// 리스폰을 잘 받긴했는데 에러가 있는 경우
                        print(error)
                        handler(.failure(.unknown))
                        return
                    }
                    // 응답 코드 responseCode 선언
                    guard let statusCode: Int = response.response?.statusCode else {
                        handler(.failure(.unknown))
                        return }
                    
                    // 엑세스 토큰 디나이 (401)
                    if statusCode == 401 {
                        // 엑세스 토큰 거부 ( 접근권한이 없습니다 ) => 토큰 리프래쉬 시도 후 다시 리퀘스트 발사
                        guard let refreshToken: String = AccountManager.shared.user.tokenSet?.refreshToken
                        else { return }
                        AccountManager.shared.tryRefreshToken(refreshToken: refreshToken) {
                            // 리프래쉬 토큰 재발급에 성공했을 경우에만 다시 시도하므로 무한루프 안됨.
                            if !checkOnlyOne {
                                request(urlString: urlString, method: method, headers: headers,
                                        parameters: parameters, handler)
                                checkOnlyOne = true
                            }
                        }
                        // 액세스 토큰 거부 오류 처리
                        handler(.failure(.accessTokenDenied))
                    }
                    
                    // 네이버 약관 비동의 오류
                    else if statusCode == 417 {
                        handler(.failure(.naverInvaildNameOrEmail))
                    } else if statusCode == 409 {
                        handler(.failure(.couponBuyConflict))
                    } else if statusCode == 412 {
                        handler(.failure(.noCouponAvailable))
                    }
                    
                    // 유효한 응답 코드들 ( 200..<300 )
                    else if 200 <= statusCode && statusCode < 300 {
                        let decoder = JSONDecoder()
                        guard let resultDict = try? decoder.decode(T.self, from: response.data!) else {
                            handler(.failure(.jsonParse))
                            return
                        }
                        handler(.success(resultDict))
                    } else {
                        print("statusCode : \(statusCode)")
                        handler(.failure(.invalidResponse))
                    }
                    
                case .failure(let error): /// 리스폰이 이상할 경우
                    print(error)
                    handler(.failure(.invalidResponse))
                }
            }
    }
}
