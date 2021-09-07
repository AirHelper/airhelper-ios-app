import SwiftUI
import KeyboardToolbar
import MapKit
import NMapsMap
import Combine
import Alamofire
import AlertToast

struct RoomData {
    var id: Int = 0
    var title: String = ""
    var password: String = ""
    var verbose_left: Int = 0
    var verbose_right: Int = 0
    var time: Int = 0
    var game_type: Int = 0
}

struct CreateView: View {
    @State var title: String = ""
    @State var password: String = ""
    @State var verboseLeft: String = ""
    @State var verboseRight: String = ""
    @State var minuties: String = ""
    
    let buttons = ["섬멸전", "폭탄전", "스파이전"]
    @State public var buttonSelected: Int?
    @State private var showingAlert = false
    
    @State var spyPercent : String = ""
    @State var spyMax : String = ""
    
    @StateObject private var keyboardHandler = KeyboardHandler()
    
    @StateObject var locationManager = LocationManager()
    
    @State private var showToast = false

    @State var waitingroom_isActive = false
    
    @State var pass_room_data = RoomData()

    var userLatitude: Double {
        return locationManager.lastLocation?.coordinate.latitude ?? 0
    }
    
    var userLongitude: Double {
        return locationManager.lastLocation?.coordinate.longitude ?? 0
    }
    
    var body: some View {
        GeometryReader { gp in
            ScrollView(.vertical, showsIndicators: false){
                VStack(alignment:.center, spacing: 0) {
                    
                    TextField("방 제목", text: self.$title)
                        .padding()
                        .frame(width: gp.size.width * 0.9)
                        .onReceive(title.publisher.collect()) {
                            self.title = String($0.prefix(15))
                        }
                    Divider()
                        .frame(width: gp.size.width * 0.9)
                    
                    SecureField("비밀번호", text: self.$password)
                        .padding()
                        .frame(width: gp.size.width * 0.9)
                        .keyboardType(.numberPad)
                        .onReceive(password.publisher.collect()) {
                            self.password = String($0.prefix(6))
                        }
                    Divider()
                        .frame(width: gp.size.width * 0.9)
                    
                    HStack() {
                        TextField("5", text: self.$verboseLeft)
                            .keyboardType(.numberPad)
                            .padding()
                            .frame(width: gp.size.width * 0.2, alignment: .center)
                            .multilineTextAlignment(.center)
                            .onReceive(verboseLeft.publisher.collect()) {
                                self.verboseLeft = String($0.prefix(3))
                            }
                        Text("VS")
                            .padding()
                        TextField("5", text: self.$verboseRight)
                            .keyboardType(.numberPad)
                            .padding()
                            .frame(width: gp.size.width * 0.2, alignment: .center)
                            .multilineTextAlignment(.center)
                            .onReceive(verboseRight.publisher.collect()) {
                                self.verboseRight = String($0.prefix(3))
                            }
                    }
                    
                    Divider()
                        .frame(width: gp.size.width * 0.9)
                    
                    HStack(){
                        TextField("게임시간(분)", text: self.$minuties)
                            .keyboardType(.numberPad)
                            .padding()
                            .multilineTextAlignment(.trailing)
                            .frame(width: gp.size.width * 0.7)
                            .onReceive(minuties.publisher.collect()) {
                                self.minuties = String($0.prefix(3))
                            }
                        Text("분")
                            .padding()
                            .frame(width: gp.size.width * 0.2)
                    }
                    
                    Divider()
                        .frame(width: gp.size.width * 0.9)
                    
                    Group(){
                        NavigationLink(destination: WaitingRoom(roomData: self.pass_room_data, is_admin: true, rootIsActive: self.$waitingroom_isActive), isActive: self.$waitingroom_isActive){
                            EmptyView()
                        }
                        HStack(){
                            Spacer()
                            Text("게임모드")
                                .padding()
                            Spacer()
                        }
                        HStack() {
                            ForEach(0..<buttons.count) { button in
                                Button(action: {
                                    self.buttonSelected = button
                                }) {
                                    VStack(){
                                        Image(self.buttonSelected == button ? self.buttons[button]+"-selected" : self.buttons[button])
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 80)
                                        Text("\(self.buttons[button])")
                                            .foregroundColor(self.buttonSelected == button ? Color.blue : Color.gray)
                                    }
                                    .frame(width: gp.size.width * 0.25, height: gp.size.width * 0.35)
                                    .clipShape(Rectangle())
                                    .border(self.buttonSelected == button ? Color.blue : Color.gray, width: 1)
                                }
                            }
                        }
                        
                        if self.buttonSelected == 1 {
                            Text("폭탄 설치지역 설정")
                                .padding(.vertical, 30)
                            
                            
                            MapView(userLatitude: self.userLatitude, userLongitude: self.userLongitude)
                                .frame(width: gp.size.width * 0.8, height: gp.size.height * 0.4)
                            
                        }
                        else if self.buttonSelected == 2 {
                            HStack() {
                                TextField("스파이 발생확률", text: self.$spyPercent)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: gp.size.width * 0.7)
                                    .onReceive(spyPercent.publisher.collect()) {
                                        self.spyPercent = String($0.prefix(2))
                                    }
                                Text("%")
                            }
                            Divider()
                                .frame(width: gp.size.width * 0.9)
                            HStack() {
                                TextField("스파이 최대인원", text: self.$spyMax)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: gp.size.width * 0.7)
                                    .onReceive(spyMax.publisher.collect()) {
                                        self.spyMax = String($0.prefix(2))
                                    }
                                Text("명")
                            }
                            Divider()
                                .frame(width: gp.size.width * 0.9)
                        }
                    }
                    
                    Button(action: {
                        print("Button action")
                        if self.create_validation() == false {
                            self.showingAlert = true
                        }
                        else {
                            AF.request("http://airhelper.kro.kr/api/game/room", method: .post, parameters: [
                                "title": self.title,
                                "password": self.password,
                                "verbose_left": self.verboseLeft,
                                "verbose_right": self.verboseRight,
                                "time": self.minuties,
                                "game_type": self.buttonSelected!
                            ], encoding: URLEncoding.httpBody).responseJSON() { response in
                                switch response.result {
                                case .success:
                                    if let data = try! response.result.get() as? [String: Any]{ //응답 데이터 체크
                                        print(data)
                                        if let room_id = data["id"] {
                                            print("통과")
                                            
                                            self.pass_room_data.id = room_id as! Int
                                            self.pass_room_data.title = self.title
                                            self.pass_room_data.password = self.password
                                            self.pass_room_data.verbose_left = Int(self.verboseLeft)!
                                            self.pass_room_data.verbose_right = Int(self.verboseRight)!
                                            self.pass_room_data.time = Int(self.minuties)!
                                            self.pass_room_data.game_type = self.buttonSelected!
                                            
                                            self.waitingroom_isActive = true
//                                            let urlSession = URLSession(configuration: .default)
//                                            let urlStr = "ws://airhelper.kro.kr/ws/create/\(room_id)/"
//                                            if let encoded = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//                                                let webSocketTask = urlSession.webSocketTask(with: URL(string: encoded)!)
//                                                webSocketTask.resume()
//
//
//                                            }
                                        }
                                        else{
                                            
                                            self.showToast = true
                                        }
                                        
                                    }
                                case .failure(let error):
                                    print("Error: \(error)")
                                    return
                                }
                            }
                        }
                    }) {
                        Text("생성하기")
                            .font(.title2)
                            .foregroundColor(Color.white)
                            .frame(width: gp.size.width * 0.6, height: gp.size.height * 0.1)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 100)
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("입력"), message: Text("모든 항목을 입력해주세요."), dismissButton: .default(Text("확인")))
                    }
                }
                .listRowInsets(EdgeInsets())
            }
            .onTapGesture(count: 1) { // 키보드밖 화면 터치시 키보드 사라짐
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .padding(.bottom, keyboardHandler.keyboardHeight)
            .animation(.default)
            .keyboardToolbar(toolbarItems)
            .toast(isPresenting: $showToast){
                AlertToast(type: .regular, title: "중복된 방이름으로 개설할 수 없습니다.")
            }
            .onAppear(perform: {
                self.locationManager.locationManagerStart()
            })
            .onDisappear(perform: {
                self.locationManager.locationManagerStop()
            })
        }
    }
    
    func create_validation() -> Bool {
        if self.title == "" {
            return false
        }
        else if self.password == "" {
            return false
        }
        else if self.verboseLeft == "" {
            return false
        }
        else if self.verboseRight == "" {
            return false
        }
        else if self.minuties == "" {
            return false
        }
        else if self.buttonSelected == nil {
            return false
        }
        
        if self.buttonSelected == 2 {
            if self.spyMax == "" {
                return false
            }
            else if self.spyPercent == "" {
                return false
            }
        }
        return true
    }
}

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView()
    }
}
