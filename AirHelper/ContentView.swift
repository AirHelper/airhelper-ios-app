import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import Alamofire
import AuthenticationServices

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


struct AppleUser: Codable {
    let userId: String
    let firstName: String
    let lastName: String
    let email: String
    
    init?(credentials: ASAuthorizationAppleIDCredential) {
        guard
            let firstName = credentials.fullName?.givenName,
            let lastName = credentials.fullName?.familyName,
            let email = credentials.email
        else { return nil }
        
        self.userId = credentials.user
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
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
                        .isDetailLink(false)
                        NavigationLink(destination: MainTabView(shouldPopToRoot: self.$autoIsActive),
                                       isActive: self.$autoIsActive) {
                            EmptyView()
                        }
                        .isDetailLink(false)
                        Button(action:{
                            // ???????????? ?????? ?????? ??????
                            if (UserApi.isKakaoTalkLoginAvailable()) {
                                UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                                    if let error = error {
                                        print("????????? \(error)")
                                    }
                                    else {
                                        print("????????? ????????? ??????!")
                                        if let accessToken = oauthToken?.accessToken {
                                            AF.request("http://airhelper.kro.kr/api/oauth/kakao", method: .post, parameters: ["access": accessToken], encoding: URLEncoding.httpBody).responseJSON() { response in
                                                switch response.result {
                                                case .success:
                                                    if let data = try! response.result.get() as? [String: Any]{ //?????? ????????? ??????
                                                        if let user = data["user"] as? [String: Any] { // ??????
                                                            if let is_active = user["is_active"] as? Int, let user_id = user["id"] as? Int { // is_active ??????
                                                                UserDefaults.standard.set(user_id, forKey: "user_id")
                                                                if is_active == 1 { //?????? ????????? ????????????
                                                                    print("?????? ?????????")
                                                                    if let access = data["access"] as? String, let refresh = data["refresh"] as? String {
                                                                        UserDefaults.standard.set(access, forKey: "access_token")
                                                                        UserDefaults.standard.set(refresh, forKey: "refresh_token")
                                                                        UserDefaults.standard.set(user_id, forKey: "user_id")
                                                                    }
                                                                    self.autoIsActive = true
                                                                }
                                                                else {
                                                                    print("?????? ????????????")
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
                            // ???????????? ?????? ????????? ????????? ???????????? ?????????
                            else {
                                UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                                    if let error = error {
                                        print(error)
                                    }
                                    else {
                                        print("??????????????? ????????? ??????.")
                                        if let accessToken = oauthToken?.accessToken {
                                            AF.request("http://airhelper.kro.kr/api/oauth/kakao", method: .post, parameters: ["access": accessToken], encoding: URLEncoding.httpBody).responseJSON() { response in
                                                switch response.result {
                                                case .success:
                                                    if let data = try! response.result.get() as? [String: Any]{ //?????? ????????? ??????
                                                        if let user = data["user"] as? [String: Any] { // ??????
                                                            if let is_active = user["is_active"] as? Int, let user_id = user["id"] as? Int { // is_active ??????
                                                                UserDefaults.standard.set(user_id, forKey: "user_id")
                                                                if is_active == 1 { //?????? ????????? ????????????
                                                                    print("?????? ?????????")
                                                                    if let access = data["access"] as? String, let refresh = data["refresh"] as? String {
                                                                        UserDefaults.standard.set(access, forKey: "access_token")
                                                                        UserDefaults.standard.set(refresh, forKey: "refresh_token")
                                                                    }
                                                                    self.autoIsActive = true
                                                                }
                                                                else {
                                                                    print("?????? ????????????")
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
                            Text("????????? ?????????")
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding(.trailing, 30)
                                .frame(width: gp.size.width * 0.6)
                        }
                        .background(Color(hex: 0xFEE500))
                        .cornerRadius(5)
                        .padding(.bottom, -20)
                        
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: configure,
                            onCompletion: handle
                        )
                        .frame(height: 50)
                        .padding(30)
                        
                        Text("?????? ?????? ???, airhelper ?????? ??? ???????????? ??????????????? ???????????? ?????? ???????????????.")
                            .foregroundColor(.white)
                            .font(.system(size: gp.size.width / 35))
                    }
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func configure(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    
    func handle(_ authResult: Result<ASAuthorization, Error>) {
        switch authResult {
        case .success(let auth):
            print(auth)
            switch auth.credential {
            case let appleIdCredentials as ASAuthorizationAppleIDCredential:
                print(appleIdCredentials)
                //?????? ?????????
                if let appleUser = AppleUser(credentials: appleIdCredentials),
                   let appleUserData = try? JSONEncoder().encode(appleUser){
                    print("appleUser : ", appleUser)
                    
                }
                //?????? ????????? ??????
                else {
                    print("missing some fields", appleIdCredentials.email, appleIdCredentials.fullName, appleIdCredentials.user)
                
                }
            default:
                print(auth.credential)
            }
            
        case .failure(let error):
            print(error)
        }
    }
    
}

struct ContentView: View {
    
    var body: some View {
        if let _ = UserDefaults.standard.string(forKey: "access_token"), let _ = UserDefaults.standard.string(forKey: "refresh_token") {
            GeometryReader() { gp in
                MainLoginView(autoIsActive: true)
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
