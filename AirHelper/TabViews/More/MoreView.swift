//
//  MoreView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/06/25.
//

import SwiftUI
import Alamofire


func apiGetCallSign(user_id: String) -> String {
    AF.request("http://airhelper.kro.kr/api/cert/user/\(user_id)", method: .get).responseJSON() { response in
        switch response.result {
        case .success:
            if let data = try! response.result.get() as? [String: Any]{
                if let callsign = data["call_sign"] as? String {
                    
                    var dd:String = callsign
                }
            }
        case .failure(let error):
            print("Error: \(error)")
            return
        }
    }

    return ""
}

struct MoreView: View {
    @State var showAlert = false
    @State var drawalAlert = false
    @Binding var shouldPopToRoot : Bool
    @State var isUserInfoViewActive: Bool = false
    @State var callSign : String = ""
    
    
    var body: some View {
        GeometryReader { gp in
            ZStack() {
                Form {
                    Section(header: Text("사용자 정보"), content: {
                        NavigationLink(destination: UserInfoView(), isActive: self.$isUserInfoViewActive) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text(self.callSign)
                            }
                        }
                        .isDetailLink(false)
                    })
                    
                    Section(header: Text("기타"), content: {
                        HStack {
                            Text("버전정보")
                            Spacer()
                            Text("1.0.0")
                        }
                        
                        Button("로그아웃"){
                            self.showAlert = true
                        }
                        .foregroundColor(Color.black)
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("로그아웃"), message: Text("정말 로그아웃 하시겠어요?"),
                                  primaryButton: .default (Text("OK")) {
                                    AF.request("http://airhelper.kro.kr/api/oauth/logout", method: .delete, parameters: ["refresh": UserDefaults.standard.string(forKey: "refresh_token")!], encoding: URLEncoding.httpBody).responseJSON() { response in
                                        switch response.result {
                                        case .success:
                                            UserDefaults.standard.removeObject(forKey: "refresh_token")
                                            UserDefaults.standard.removeObject(forKey: "access_token")
                                            UserDefaults.standard.removeObject(forKey: "user_id")
                                            self.shouldPopToRoot = false
                                        case .failure(let error):
                                            print("Error: \(error)")
                                            return
                                        }
                                        
                                    }
                                  },
                                  secondaryButton: .cancel()
                            )
                        }
                        Button("탈퇴하기"){
                            self.drawalAlert = true
                        }
                        .foregroundColor(Color.black)
                        .alert(isPresented: self.$drawalAlert) {
                            Alert(title: Text("회원탈퇴"), message: Text("정말로 탈퇴 하시겠어요?"),
                                  primaryButton: .default (Text("OK")) {
                                    AF.request("http://airhelper.kro.kr/api/cert/user/\(UserDefaults.standard.integer(forKey: "user_id"))", method: .delete, encoding: URLEncoding.httpBody).responseJSON() { response in
                                        switch response.result {
                                        case .success:
                                            UserDefaults.standard.removeObject(forKey: "refresh_token")
                                            UserDefaults.standard.removeObject(forKey: "access_token")
                                            UserDefaults.standard.removeObject(forKey: "user_id")
                                            self.shouldPopToRoot = false
                                        case .failure(let error):
                                            print("Error: \(error)")
                                            return
                                        }
                                        
                                    }
                                  },
                                  secondaryButton: .cancel()
                            )
                        }
                    })
                }
                
            }
            .onAppear(perform: {
                AF.request("http://airhelper.kro.kr/api/cert/user/\(UserDefaults.standard.string(forKey: "user_id")!)", method: .get).responseJSON() { response in
                    switch response.result {
                    case .success:
                        if let data = try! response.result.get() as? [String: Any]{
                            if let callsign = data["call_sign"] as? String {
                                self.callSign = callsign
                            }
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                        return
                    }
                }
            })
        }
    }
}

//struct MoreView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            MoreView()
//        }
//    }
//}

