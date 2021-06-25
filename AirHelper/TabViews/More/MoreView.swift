//
//  MoreView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/06/25.
//

import SwiftUI
import Alamofire

struct MoreView: View {
    @State var tag:Int? = nil
    @State var showAlert = false
    //@Binding var gotoTab: Bool
    
    var body: some View {
        GeometryReader { gp in
            ZStack() {
                NavigationLink(destination: MainLoginView(Maintag: 0, Logintag: 0), tag: 1, selection: self.$tag ) {
                    EmptyView()
                }
                Form {
                    Section(header: Text("기타"), content: {
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
                                            self.tag=1
                                            //self.gotoTab = false
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
                            print("dd")
                        }
                        
                    })
                }
                .navigationBarTitle("더보기", displayMode: .inline)
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

