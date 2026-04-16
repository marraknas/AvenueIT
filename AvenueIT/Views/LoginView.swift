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
        ZStack {
            // Simple Gradients here to make it look cooler!
            Color("AvenueDeepNavy")
                .ignoresSafeArea()
            
            Circle()
                .fill(Color("AvenueNeonCyan").opacity(0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: -90, y: -210)

            Circle()
                .fill(Color("AvenueSkyBlue").opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: 110, y: 270)

            VStack {
                Spacer()

                VStack(spacing: 10) {
                    // TODO: Replace with custom logo later on
                    Image(systemName: "music.microphone.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(Color("AvenueNeonCyan"))
                        .shadow(color: Color("AvenueNeonCyan").opacity(0.5), radius: 20, x: 0, y: 0)

                    Text("AvenueIT")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AvenueOffWhite"))
                    
                    Text("Your one stop platform to discover events around you!")
                        .font(.subheadline)
                        .foregroundStyle(Color("AvenueOffWhite"))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Text("Sign in or create your account")
                        .font(.subheadline)
                        .foregroundStyle(Color("AvenueOffWhite").opacity(0.45))
                }
                .padding(.bottom, 15)

                VStack(spacing: 18) {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .foregroundStyle(
                                focusField == .email
                                    ? Color("AvenueNeonCyan")
                                    : Color("AvenueOffWhite").opacity(0.35)
                            )
                            .frame(width: 20)
                            .animation(.easeInOut(duration: 0.2), value: focusField)

                        TextField("Email address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .foregroundStyle(Color("AvenueOffWhite"))
                            .submitLabel(.next)
                            .focused($focusField, equals: .email)
                            .onSubmit { focusField = .password }
                            .onChange(of: email) { enableButtons() }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .background(Color("AvenueDeepNavy").opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(
                                focusField == .email
                                    ? Color("AvenueNeonCyan")
                                    : Color("AvenueOffWhite").opacity(0.12),
                                lineWidth: 1.5
                            )
                            .animation(.easeInOut(duration: 0.2), value: focusField)
                    )

                    HStack(spacing: 12) {
                        Image(systemName: "lock")
                            .foregroundStyle(
                                focusField == .password
                                    ? Color("AvenueNeonCyan")
                                    : Color("AvenueOffWhite").opacity(0.35)
                            )
                            .frame(width: 20)
                            .animation(.easeInOut(duration: 0.2), value: focusField)

                        SecureField("Password", text: $password)
                            .foregroundStyle(Color("AvenueOffWhite"))
                            .submitLabel(.done)
                            .focused($focusField, equals: .password)
                            .onSubmit { focusField = nil }
                            .onChange(of: password) { enableButtons() }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .background(Color("AvenueDeepNavy").opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(
                                focusField == .password
                                    ? Color("AvenueNeonCyan")
                                    : Color("AvenueOffWhite").opacity(0.12),
                                lineWidth: 1.5
                            )
                            .animation(.easeInOut(duration: 0.2), value: focusField)
                    )
                    
                    VStack(spacing: 12) {
                        Button(action: login) {
                            Text("Log In")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    buttonDisabled
                                        ? Color("AvenueSlate").opacity(0.5)
                                        : Color("AvenueNeonCyan")
                                )
                                .foregroundStyle(
                                    buttonDisabled
                                        ? Color("AvenueOffWhite").opacity(0.3)
                                        : Color("AvenueDeepNavy")
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                        }
                        .disabled(buttonDisabled)
                        .animation(.easeInOut(duration: 0.2), value: buttonDisabled)

                        Button(action: register) {
                            Text("Create Account")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .foregroundStyle(
                                    buttonDisabled
                                        ? Color("AvenueOffWhite").opacity(0.25)
                                        : Color("AvenueNeonCyan")
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 13)
                                        .stroke(
                                            buttonDisabled
                                                ? Color("AvenueOffWhite").opacity(0.1)
                                                : Color("AvenueNeonCyan").opacity(0.7),
                                            lineWidth: 1.5
                                        )
                                )
                        }
                        .disabled(buttonDisabled)
                        .animation(.easeInOut(duration: 0.2), value: buttonDisabled)
                    }
                    .padding(.top, 6)
                }
                .padding(26)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color("AvenueSlate").opacity(0.55))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color("AvenueNeonCyan").opacity(0.18), lineWidth: 1)
                        )
                )
                .shadow(color: Color.black.opacity(0.35), radius: 30, x: 0, y: 10)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .tint(Color("AvenueNeonCyan"))
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
