//
//  OnboardingView.swift
//  DiplomskiRadBezAnimacija
//
//  Created by Orhan Pojskic on 12/28/24.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var isSignInPresented: Bool = false // Novo stanje za otvaranje SignInView
    @Environment(\.colorScheme) var colorScheme
    
    var naslov = """
                 Visualize
                 data flow
                 """
    
    var body: some View {
        ZStack{
        VStack(alignment: .leading, spacing: 20) {
            
            
            
            
            Spacer()
            
            
            HStack{
                Text(naslov)
                    .fontWeight(.heavy)
                    .font(.system(size: 60))
                    .frame(minWidth: .leastNormalMagnitude, alignment: .leading)
                //                    .padding(.top)
                    .lineSpacing(20)
                
                //MARK: .background(.yellow)
                Spacer()
                VStack {
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .resizable()
                            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                            .scaledToFit()
                            .frame(width: 34, height: 34) // Veličina ikone
                            .padding(8) // Unutrašnji razmak
                        //.background(Color.gray.opacity(0.2)) // Pozadinska boja
                            .clipShape(Circle()) // Oblik kružnice
                    }
                    .frame(width: 36, height: 36) // Ukupne dimenzije dugmeta
                    .contentShape(Circle())
                    .padding()
                    .padding(.top, 80)
                    
                    Spacer()
                }//.background(.red) // Površina klika
                
            }.frame(maxWidth: .infinity, alignment: .leading)
            //.background(.green)
                .padding(.top, 20)
            Text("Nesto sto bise trebalo napisati o kratkom opisu za sta na sluzi ova palikacija i sta dobijamo sa pristupom ")
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 17))
                .padding(.top, -20)
                .padding(.bottom, 20)
                .padding(.trailing, 50)
                .lineSpacing(2)
            
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            
            Button(action: {
                withAnimation {
                    self.isSignInPresented = true
                }
            }) {
                Image(systemName: "arrow.right")
                Text("Start the course")
            }
            .padding([.top, .bottom], 18)
            .padding([.leading, .trailing], 30)
            .foregroundColor(.black)
            .fontWeight(.bold)
            .background(
                RoundedRectangle(cornerRadius: 23)
                    .foregroundColor(.white)
            )
            .compositingGroup()
            .shadow(radius: 5, x: 0, y: 3)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            .padding(.trailing, 50)
            Text("Forgot password? Contact server administator")
                .font(.footnote)
                .opacity(0.7)
                .padding(.leading, 10)
                .padding(.trailing, 50)
                .padding(.bottom, 40)
            //Spacer()
            //            Spacer()
            //            Spacer()
            //            Spacer()
            //            Spacer()
            
            
        }
        // MARK: .background(.purple)
        .padding()
        .padding(.leading, 20)
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height) // Onboarding zauzima 90% visine ekrana
        .background(Color(.systemBackground))
        .cornerRadius(30, corners: [.bottomLeft, .bottomRight]) // Samo gornji uglovi zaobljeni
        .shadow(
            color: colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.5), // Dinamička sjena
            radius: 20
        )
        .padding(.bottom, 160) // Daje razmak na dnu
        if isSignInPresented {
            SignInView(isPresented: $isSignInPresented)
                .transition(.move(edge: .top)) // Animacija odozgo
                .zIndex(3) // Viši sloj
        }
    }.animation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0.4), value: isSignInPresented)
}
        
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
