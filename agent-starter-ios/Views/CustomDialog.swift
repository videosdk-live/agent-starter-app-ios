//
//  CustomDialog.swift
//  agent-starter-ios
//
//  Created by Parth Asodariya on 13/03/26.
//

import SwiftUI

struct CustomDialog<DialogContent: View>: ViewModifier {
    @Binding var isShowing: Bool
    let onOutsideTap: (() -> Void)?
    let dialogContent: DialogContent

    init(
        isShowing: Binding<Bool>,
        onOutsideTap: (() -> Void)? = nil,
        @ViewBuilder dialogContent: () -> DialogContent
    ) {
        _isShowing = isShowing
        self.onOutsideTap = onOutsideTap
        self.dialogContent = dialogContent()
    }

    func body(content: Content) -> some View {
        ZStack {
            // Main content of the screen
            content

            // Dialog overlay
            if isShowing {
                Rectangle()
                    .foregroundColor(Color.black.opacity(0.6))
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing = false
                        onOutsideTap?()
                    }

                dialogContent
                    .padding(Responsive.width(20))
            }
        }
    }
}
