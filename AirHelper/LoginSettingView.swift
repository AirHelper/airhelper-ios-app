//
//  LoginSettingView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/06/22.
//

import SwiftUI
import Alamofire

struct LoginSettingView: View {
    @State var call_sign = ""
    @State private var showingAlert = false
    @State var tag:Int? = 1
    @Binding var rootIsActive : Bool
    
    var body: some View {
        GeometryReader { gp in
            ZStack() {
                NavigationLink(destination: MainTabView(shouldPopToRoot: self.$rootIsActive).navigationTitle("dd"), tag: 1, selection: self.$tag) {
                    EmptyView()
                }
                .isDetailLink(false)
                Form {
                    HStack(alignment: .center) {
                        Text("콜 사인")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .padding()
                            .frame(width: gp.size.width * 0.25)
                        TextField("CALL SIGN", text: $call_sign)
                            .padding()
                            .frame(width: gp.size.width * 0.70)
                    }
                }
            }
        }
        .navigationBarTitle("추가정보 설정", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            trailing:
                Button(action: {
                    if self.call_sign != "" {
                        AF.request("http://airhelper.kro.kr/api/oauth/kakao/\(UserDefaults.standard.string(forKey: "user_id")!)", method: .patch, parameters: ["call_sign": call_sign], encoding: URLEncoding.httpBody).responseJSON() { response in
                            switch response.result {
                            case .success:
                                if let data = try! response.result.get() as? [String: Any]{ //응답 데이터 체크
                                    if let access = data["access"] as? String, let refresh = data["refresh"] as? String {
                                        UserDefaults.standard.set(access, forKey: "access_token")
                                        UserDefaults.standard.set(refresh, forKey: "refresh_token")
                                        self.tag = 1
                                    }
                                }
                            case .failure(let error):
                                print("Error: \(error)")
                                return
                            }
                            
                        }
                    }
                    else {
                        self.showingAlert = true
                    }
                }) {
                    Text("저장")
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("입력"), message: Text("콜사인을 입력해주세요."), dismissButton: .default(Text("확인")))
                }
        )
        
    }
}

//struct LoginSettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginSettingView()
//    }
//}

