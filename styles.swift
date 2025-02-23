//
//  customTextFields.swift
//  lift
//
//  Created by Josh Pelzer on 2/21/25.
//

import SwiftUI

struct CustomTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .multilineTextAlignment(.center)
//            .keyboardType(.numberPad)
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                if let textField = obj.object as? UITextField {
                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                }
            }
    }
}


struct CustomButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.small)
            .saturation(0.7)
            .padding(.top, 5)
    }
}


struct HomeButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .saturation(0.9)
            .padding(5)
            .font(.title)
            .background(.pink)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 10)
    }
}




//Menu("menu button") {
//    Button {
//    } label: {
//        Label("default", systemImage: "plus")
//    }
//    Button(role: .destructive) {
//    } label: {
//        Label("destructive", systemImage: "trash")
//    }
//}




