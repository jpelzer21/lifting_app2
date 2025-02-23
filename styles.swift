//
//  customTextFields.swift
//  lift
//
//  Created by Josh Pelzer on 2/21/25.
//

import SwiftUI
import UIKit

struct CustomTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .multilineTextAlignment(.center)
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                if let textField = obj.object as? UITextField {
                    DispatchQueue.main.async {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
            }
            .padding(5)
    }
}

struct CustomButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.small)
            .saturation(0.8)
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

