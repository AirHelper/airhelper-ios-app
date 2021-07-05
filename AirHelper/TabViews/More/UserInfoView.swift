//
//  UserInfo.swift
//  AirHelper
//
//  Created by Junho Son on 2021/06/30.
//

import SwiftUI
import Alamofire
struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    
    final class Coordinator: NSObject,
                             UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate {
        
        @Binding
        private var presentationMode: PresentationMode
        private let sourceType: UIImagePickerController.SourceType
        private let onImagePicked: (UIImage) -> Void
        
        init(presentationMode: Binding<PresentationMode>,
             sourceType: UIImagePickerController.SourceType,
             onImagePicked: @escaping (UIImage) -> Void) {
            _presentationMode = presentationMode
            self.sourceType = sourceType
            self.onImagePicked = onImagePicked
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            onImagePicked(uiImage)
            presentationMode.dismiss()
            
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode,
                           sourceType: sourceType,
                           onImagePicked: onImagePicked)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
}

extension Image {
    func data(url:URL) -> Self {
        if let data = try? Data(contentsOf: url) {
            return Image(uiImage: UIImage(data: data)!)
                .resizable()
        }
        return self.resizable()
    }
}



struct UserInfoView: View {
    @State var showImagePicker: Bool = false
    @State var image: Image? = nil
    @State var uploadImage: UIImage? = nil
    @State var name: String = ""
    @State var email: String = ""
    @State var callSign: String = ""
    @State var profile_image: String = "http://airhelper.kro.kr/media/profiles/default.png"
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        GeometryReader { gp in
            VStack(alignment: .center, spacing: 0){
                if image == nil {
                    
                    Image(systemName: "person.fill")
                        .data(url: URL(string: self.profile_image)!)
                        .resizable()
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, 30)
                }
                else {
                    image?
                        .resizable()
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .padding(.top, 30)
                }
                
                Button(action: {
                    self.showImagePicker.toggle()
                }) {
                    Text("프로필 사진 변경")
                }
                //.position(x: gp.size.width / 2)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(sourceType: .photoLibrary) { image in
                        self.uploadImage = image
                        self.image = Image(uiImage: image)
                        
                    }
                }
                .navigationTitle("사용자 정보")
                
                HStack(alignment: .center){
                    Text("이름")
                        .frame(width: gp.size.width * 0.2, alignment: .center)
                    TextField(self.name, text: self.$name)
                }
                .padding()
                .background(Color.white)
                Divider()
                HStack(alignment: .center){
                    Text("이메일")
                        .frame(width: gp.size.width * 0.2, alignment: .center)
                    TextField(self.email, text: self.$email)
                }
                .padding()
                .background(Color.white)
                Divider()
                HStack(alignment: .center){
                    Text("콜사인")
                        .frame(width: gp.size.width * 0.2, alignment: .center)
                    TextField(self.callSign, text: self.$callSign)
                }
                .padding()
                .background(Color.white)
            }
            .navigationBarItems(
                trailing:
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        let headers: HTTPHeaders = [
                            /* "Authorization": "your_access_token",  in case you need authorization header */
                            "Content-type": "multipart/form-data"
                        ]
                        
                        
                        AF.upload(
                            multipartFormData: { multipartFormData in
                                multipartFormData.append(self.uploadImage!.jpegData(compressionQuality: 0.5)!, withName: "profile_image" , fileName: "user\(UserDefaults.standard.string(forKey: "user_id")!)Profile.jpeg", mimeType: "image/jpeg")
                            },
                            to: "http://airhelper.kro.kr/api/cert/user/\(UserDefaults.standard.string(forKey: "user_id")!)", method: .patch , headers: headers)
                            .responseJSON { resp in
                                print(resp)
                                
                            }
                        
                    }) {
                        Text("저장")
                    }
            )
        }
        .background(Color(hex: 0xF2F2F7))
        .edgesIgnoringSafeArea(.bottom)
        .onAppear(perform: {
            AF.request("http://airhelper.kro.kr/api/cert/user/\(UserDefaults.standard.string(forKey: "user_id")!)", method: .get).responseJSON() { response in
                switch response.result {
                case .success:
                    if let data = try! response.result.get() as? [String: Any]{
                        if let callsign = data["call_sign"] as? String,
                           let name = data["name"] as? String,
                           let email = data["email"] as? String,
                           let profile_image = data["profile_image"] as? String{
                            self.callSign = callsign
                            self.name = name
                            self.email = email
                            self.profile_image = profile_image
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

//struct UserInfo_Previews: PreviewProvider {
//
//    static var previews: some View {
//        UserInfoView()
//    }
//}
