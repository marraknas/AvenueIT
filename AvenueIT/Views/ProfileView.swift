//
//  ProfileView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    // to save data
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("displayName") private var displayName = ""
    @AppStorage("dateOfBirthTimestamp") private var dateOfBirthTimestamp: Double = 0
    @State private var tempName = ""
    @State private var tempDOB: Date = Date()

    private var email: String {
        Auth.auth().currentUser?.email ?? "No email"
    }

    private var hasChanges: Bool {
        tempName != displayName
        || tempDOB.timeIntervalSince1970 != dateOfBirthTimestamp
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .foregroundStyle(Color("AvenueNeonCyan"))

                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(Color("AvenueOffWhite").opacity(0.5))
                }
                .padding(.top, 8)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Full Name")
                            .font(.caption)
                            .foregroundStyle(Color("AvenueOffWhite").opacity(0.5))
                        
                        TextField("Enter your name", text: $tempName)
                            .padding()
                            .autocorrectionDisabled()
                            .background(Color("AvenueSlate"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date of Birth")
                            .font(.caption)
                            .foregroundStyle(Color("AvenueOffWhite").opacity(0.5))

                        DatePicker("", selection: $tempDOB, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color("AvenueSlate"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)

                Button {
                    displayName = tempName
                    dateOfBirthTimestamp = tempDOB.timeIntervalSince1970
                } label: {
                    Text("Save Changes")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(hasChanges ? Color("AvenueNeonCyan") : Color("AvenueSlate"))
                        .foregroundStyle(hasChanges ? Color("AvenueDeepNavy") : Color("AvenueOffWhite").opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                }
                .disabled(!hasChanges)
                .padding(.horizontal)

                Button {
                    try? Auth.auth().signOut()
                    isLoggedIn = false
                } label: {
                    Text("Sign Out")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .foregroundStyle(.red)
                        .overlay(
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(.red.opacity(0.7), lineWidth: 1.5)
                        )
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 24)
        }
        .background(Color("AvenueDeepNavy"))
        .foregroundStyle(.white)
        .onAppear {
            tempName = displayName
            tempDOB = dateOfBirthTimestamp != 0
            ? Date(timeIntervalSince1970: dateOfBirthTimestamp)
            : Date()
        }
    }
}

#Preview {
    ProfileView()
}
