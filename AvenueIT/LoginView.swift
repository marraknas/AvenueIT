//
//  LoginView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    enum Field {
        case email, password
    }
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var buttonDisabled = true
    @FocusState private var focusField: Field?
    
    var body: some View {
        VStack {
            Spacer()
            
            // TODO: Create a new customised logo and add here
            Image(systemName: "music.microphone.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color("AvenueOffWhite"))
                .padding(.bottom)
            
            Group {
                TextField("email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                    .focused($focusField, equals: .email)
                    .onSubmit {
                        focusField = .password
                    }
                    .onChange(of: email) {
                        enableButtons()
                    }
                
                SecureField("password", text: $password)
                    .submitLabel(.done)
                    .focused($focusField, equals: .password)
                    .onSubmit {
                        focusField = nil
                    }
                    .onChange(of: password) {
                        enableButtons()
                    }
            }
            .textFieldStyle(.roundedBorder)
            .padding(.bottom)
            
            HStack {
                Button("Sign Up") {
                    register()
                }
                .padding(.trailing)
                
                Button("Log In") {
                    login()
                }
                .padding(.leading)
            }
            .buttonStyle(.glassProminent)
            .disabled(buttonDisabled)
            
            Spacer()
        }
        .padding(.horizontal)
        .background(Color("AvenueSlate"))
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    func enableButtons() {
        let emailIsGood = email.count > 6 && email.contains("@")
        let passwordIsGood = password.count > 6
        buttonDisabled = !(emailIsGood && passwordIsGood)
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("SIGNUP ERROR: \(error.localizedDescription)")
                alertMessage = "SIGNUP ERROR: \(error.localizedDescription)"
                showingAlert = true
            } else {
                print("Registration success!")
                // TODO: go to new view
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("LOGIN ERROR: \(error.localizedDescription)")
                alertMessage = "LOGIN ERROR: \(error.localizedDescription)"
                showingAlert = true
            } else {
                print("Login success!")
                // TODO: go to new view
            }
        }
    }
}

#Preview {
    LoginView()
}
