import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import Alamofire

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}


struct MainLoginView: View {
    @State var isActive : Bool = false
    @State var autoIsActive : Bool = false
    var body: some View {
        NavigationView() {
            GeometryReader() { gp in
                ZStack() {
                    Image("background-img")
                        .resizable()
                        .frame(width: gp.size.width)
                    
                    VStack() {
                        Image("background-element")
                            .opacity(0.5)
                    }
                    .position(x: gp.size.width * 0.65, y: gp.size.height / 2.2)
                    
                    VStack(alignment: .leading, spacing: -25) {
                        Text("AIR")
                            .font(.system(size: gp.size.width / 5))
                            .foregroundColor(.white)
                            .fontWeight(.light)
                            .multilineTextAlignment(.leading)
                        
                        Text("HELPER")
                            .font(.system(size: gp.size.width / 9))
                            .foregroundColor(.white)
                            .fontWeight(.light)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(alignment: .center) {
                        NavigationLink(destination: LoginSettingView(tag: 0, rootIsActive: self.$isActive),
                                       isActive: self.$isActive) {
                            EmptyView()
                        }
                        NavigationLink(destination: MainTabView(shouldPopToRoot: self.$autoIsActive),
                                       isActive: self.$autoIsActive) {
                            EmptyView()
                        }
                        
                        Button(action:{
                            // 카카오톡 설치 여부 확인
                            if (UserApi.isKakaoTalkLoginAvailable()) {
                                UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                                    if let error = error {
                                        print("에러다 \(error)")
                                    }
                                    else {
                                        print("카카오 로그인 성공!")
                                        if let accessToken = oauthToken?.accessToken {
                                            AF.request("http://airhelper.kro.kr/api/oauth/kakao", method: .post, parameters: ["access": accessToken], encoding: URLEncoding.httpBody).responseJSON() { response in
                                                switch response.result {
                                                case .success:
                                                    if let data = try! response.result.get() as? [String: Any]{ //응답 데이터 체크
                                                        if let user = data["user"] as? [String: Any] { // 파싱
                                                            if let is_active = user["is_active"] as? Int, let user_id = user["id"] as? Int { // is_active 변환
                                                                UserDefaults.standard.set(user_id, forKey: "user_id")
                                                                if is_active == 1 { //계정 활성화 상태이면
                                                                    print("계정 활성화")
                                                                    if let access = data["access"] as? String, let refresh = data["refresh"] as? String {
                                                                        UserDefaults.standard.set(access, forKey: "access_token")
                                                                        UserDefaults.standard.set(refresh, forKey: "refresh_token")
                                                                        UserDefaults.standard.set(user_id, forKey: "user_id")
                                                                    }
                                                                    self.autoIsActive = true
                                                                }
                                                                else {
                                                                    print("계정 비활성화")
                                                                    self.isActive = true
                                                                }
                                                            }
                                                        }
                                                    }
                                                case .failure(let error):
                                                    print("Error: \(error)")
                                                    return
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                            // 설치되어 있지 않으면 카카오 계정으로 로그인
                            else {
                                UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                                    if let error = error {
                                        print(error)
                                    }
                                    else {
                                        print("카카오계정 로그인 성공.")
                                        if let accessToken = oauthToken?.accessToken {
                                            AF.request("http://airhelper.kro.kr/api/oauth/kakao", method: .post, parameters: ["access": accessToken], encoding: URLEncoding.httpBody).responseJSON() { response in
                                                switch response.result {
                                                case .success:
                                                    if let data = try! response.result.get() as? [String: Any]{ //응답 데이터 체크
                                                        if let user = data["user"] as? [String: Any] { // 파싱
                                                            if let is_active = user["is_active"] as? Int, let user_id = user["id"] as? Int { // is_active 변환
                                                                UserDefaults.standard.set(user_id, forKey: "user_id")
                                                                if is_active == 1 { //계정 활성화 상태이면
                                                                    print("계정 활성화")
                                                                    if let access = data["access"] as? String, let refresh = data["refresh"] as? String {
                                                                        UserDefaults.standard.set(access, forKey: "access_token")
                                                                        UserDefaults.standard.set(refresh, forKey: "refresh_token")
                                                                    }
                                                                    self.autoIsActive = true
                                                                }
                                                                else {
                                                                    print("계정 비활성화")
                                                                    self.isActive = true
                                                                }
                                                            }
                                                        }
                                                    }
                                                case .failure(let error):
                                                    print("Error: \(error)")
                                                    return
                                                }
                                                
                                            }
                                        }
                                        //do something
                                        _ = oauthToken
                                    }
                                }
                            }
                        }){
                            Image("kakao")
                                .resizable()
                                .frame(width: 32.0, height: 32.0)
                                .padding(10)
                            Text("카카오 로그인")
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding(.trailing, 30)
                                .frame(width: gp.size.width * 0.6)
                        }
                        .background(Color(hex: 0xFEE500))
                        .cornerRadius(5)
                        .padding(.bottom, 20)
                        
                        Text("계속 진행 시, airhelper 규정 및 개인정보 처리방침을 읽었으며 이에 동의합니다.")
                            .foregroundColor(.white)
                            .font(.system(size: gp.size.width / 35))
                    }
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
}

struct ContentView: View {
    
    var body: some View {
        if let _ = UserDefaults.standard.string(forKey: "access_token"), let _ = UserDefaults.standard.string(forKey: "refresh_token") {
            GeometryReader() { gp in
                MainLoginView(autoIsActive: true)
                //MainTabView()
            }
        }
        else {
            MainLoginView()
        }

    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
