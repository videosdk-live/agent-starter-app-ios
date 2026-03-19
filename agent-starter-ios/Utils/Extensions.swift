//
//  Extensions.swift
//  agent-starter-ios
//
//  Created by Parth Asodariya on 12/03/26.
//

import SwiftUI

// MARK: - Extension for specific corner rounding

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func customDialog<DialogContent: View>(
        isShowing: Binding<Bool>,
        onOutsideTap: (() -> Void)? = nil,
        @ViewBuilder dialogContent: @escaping () -> DialogContent
    ) -> some View {
        self.modifier(CustomDialog(isShowing: isShowing, onOutsideTap: onOutsideTap, dialogContent: dialogContent))
    }
}
