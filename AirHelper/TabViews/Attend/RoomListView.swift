//
//  AttendView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/07/19.
//

import SwiftUI
struct searchBar: View {
    //Binding은 외부에서 값을 바인딩시킬수있다.
    //택스트필드에 들어갈 값을 저장하기위한 변수
    @Binding var text : String
    @State var editText : Bool = false
    
    var body: some View {
        HStack{
            //검색창을 받을수있는 택스트필드
            TextField("검색어를 넣어주세요" , text : self.$text)
                //hint와 태두리에 간격을 띄우기위해 15정도의 간격을주고
                .padding(15)
                //양옆은 추가로 15를 더줌
                .padding(.horizontal,15)
                //배경색상은 자유롭게선택
                .background(Color(.systemGray6))
                //검색창이 너무각지면 딱딱해보이기때문에 모서리를 둥글게
                //숫자는 취향것
                .cornerRadius(15)
                //내가만든 검색창 상단에
                //돋보기를 넣어주기위해
                //오버레이를 선언
                .overlay(
                    //HStack을 선언하여
                    //가로로 view를 쌓을수있도록 하나 만들고
                    HStack{
                        //맨오른쪽으로 밀기위해 Spacer()로 밀어준다.
                        Spacer()
                        //xcode에서 지원해주는 이미지
                       
                        if self.editText{
                            //x버튼이미지를 클릭하게되면 입력되어있던값들을 취소하고
                            //키입력 이벤트를 종료해야한다.
                            Button(action : {
                                self.editText = false
                                self.text = ""
                                //키보드에서 입력을 끝내게하는 코드
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }){
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(Color(.black))
                                    .padding()
                            }
                        }else{
                            //magnifyingglass 를 사용
                            //색상은 자유롭게 변경가능
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(.black))
                                .padding()
                        }
                       
                    }
                ).onTapGesture {
                    self.editText = true
                }
        }
        
        
    }
}
struct RoomListView: View {
    //@State var text : String = ""
    
    var body: some View {
        GeometryReader { gp in
            VStack(){
            //searchBar(text: self.$text)
            ScrollView(.vertical, showsIndicators: false){
                Spacer()
                NavigationLink(destination: PasswordView()){
                    VStack(alignment: .leading, spacing: 0){
                        Text("팀 내전")
                            .bold()
                            .font(.title3)
                        Text("폭탄전")
                            .font(.system(size: 13))

                        HStack(alignment: .bottom, spacing: 10){
                            Text("5vs5")
                                .font(.largeTitle.weight(.medium))
                            Image(systemName: "hourglass")
                                .padding(.bottom, 6)
                            Text("30분")
                                .fontWeight(.light)
                                .opacity(0.8)
                                .padding(.bottom, 5)
                        }
                    }
                    .background(
                        Image("Room-Boom")
                            .resizable()
                            .opacity(0.3)
                            .position(x: gp.size.width * 0.65, y: gp.size.height * 0.11)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 110)
                        ,
                        alignment: .leading
                    )
                    .padding()
                    .frame(width: gp.size.width * 0.9, height: gp.size.height * 0.2, alignment: .leading)
                    .background(Color.blue)
                    .cornerRadius(5)
                    .foregroundColor(Color.white)
                    
                    
                }
                Spacer()
                NavigationLink(destination: PasswordView()){
                    VStack(alignment: .leading, spacing: 0){
                        Text("팀 내전")
                            .bold()
                            .font(.title3)
                        Text("스파이전")
                            .font(.system(size: 13))

                        HStack(alignment: .bottom, spacing: 10){
                            Text("5vs5")
                                .font(.largeTitle.weight(.medium))
                            Image(systemName: "hourglass")
                                .padding(.bottom, 6)
                            Text("30분")
                                .fontWeight(.light)
                                .opacity(0.8)
                                .padding(.bottom, 5)
                        }
                    }
                    .background(
                        Image("Room-Spy")
                            .resizable()
                            .opacity(0.3)
                            .position(x: gp.size.width * 0.65, y: gp.size.height * 0.11)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 110)
                        ,
                        alignment: .leading
                    )
                    .padding()
                    .frame(width: gp.size.width * 0.9, height: gp.size.height * 0.2, alignment: .leading)
                    .background(Color.gray)
                    .cornerRadius(5)
                    .foregroundColor(Color.white)
                }
                Spacer()
                NavigationLink(destination: PasswordView()){
                    VStack(alignment: .leading, spacing: 0){
                        Text("팀 내전")
                            .bold()
                            .font(.title3)
                        Text("섬멸전")
                            .font(.system(size: 13))

                        HStack(alignment: .bottom, spacing: 10){
                            Text("5vs5")
                                .font(.largeTitle.weight(.medium))
                            Image(systemName: "hourglass")
                                .padding(.bottom, 6)
                            Text("30분")
                                .fontWeight(.light)
                                .opacity(0.8)
                                .padding(.bottom, 5)
                        }
                    }
                    .background(
                        Image("Room-Vs")
                            .resizable()
                            .opacity(0.3)
                            .position(x: gp.size.width * 0.65, y: gp.size.height * 0.11)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 110)
                        ,
                        alignment: .leading
                    )
                    .padding()
                    .frame(width: gp.size.width * 0.9, height: gp.size.height * 0.2, alignment: .leading)
                    .background(Color.green)
                    .cornerRadius(5)
                    .foregroundColor(Color.white)
                }


            }
            .frame(width: gp.size.width)
            .border(Color.green)
            
            .navigationBarItems(
                trailing:
                    Button(action: {
                        print("dd")
                    }) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .foregroundColor(Color.black)
                            .scaledToFit()
                            .frame(width: gp.size.width * 0.06)
                    }
            )
            }
        }
    }
}

struct AttendView_Previews: PreviewProvider {
    static var previews: some View {
        RoomListView()
    }
}

