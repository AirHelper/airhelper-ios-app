//
//  MoreView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/06/25.
//

import SwiftUI
import Alamofire

struct MoreView: View {
    @State var showAlert = false
    @State var drawalAlert = false
    @Binding var shouldPopToRoot : Bool
    @State var isView1Active: Bool = false
    var body: some View {
        GeometryReader { gp in
            ZStack() {
                Form {
                    Section(header: Text("사용자 정보"), content: {
                        
                        NavigationLink(destination: Text("dd"), isActive: self.$isView1Active) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("JEFF")

                            }
                        }
                        .isDetailLink(false)
                        Button("ddd") {
                            self.isView1Active = true
                        }
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

