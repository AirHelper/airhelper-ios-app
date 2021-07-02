//
//  UserInfo.swift
//  AirHelper
//
//  Created by Junho Son on 2021/06/30.
//

import SwiftUI

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
    @State var name: String = ""
    @State var email: String = ""
    @State var callSign: String = ""
    @Binding var InfoActive: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        GeometryReader { gp in
            VStack(alignment: .center, spacing: 0){
                if image == nil {
                    Image(systemName: "person.fill")
                        .data(url: URL(string: "https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png")!)
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
                        self.image = Image(uiImage: image)
                        
                    }
                }
                .navigationTitle("사용자 정보")
                
                HStack(alignment: .center){
                    Text("이름")
                        .frame(width: gp.size.width * 0.2, alignment: .center)
                    TextField("홍길동", text: self.$name)
                }
                .padding()
                .background(Color.white)
                Divider()
                HStack(alignment: .center){
                    Text("이메일")
                        .frame(width: gp.size.width * 0.2, alignment: .center)
                    TextField("test@naver.com", text: self.$email)
                }
                .padding()
                .background(Color.white)
                Divider()
                HStack(alignment: .center){
                    Text("콜사인")
                        .frame(width: gp.size.width * 0.2, alignment: .center)
                    TextField("CallSign", text: self.$callSign)
                }
                .padding()
                .background(Color.white)
            }
            .navigationBarItems(
                trailing:
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("저장")
                    }
            )
        }
        .background(Color(hex: 0xF2F2F7))
        .edgesIgnoringSafeArea(.bottom)
        .onAppear(perform: {
            self.InfoActive = true
        })
        .onDisappear(perform: {
            self.InfoActive = false
        })
    }
    
}

//struct UserInfo_Previews: PreviewProvider {
//
//    static var previews: some View {
//        UserInfoView()
//    }
//}
