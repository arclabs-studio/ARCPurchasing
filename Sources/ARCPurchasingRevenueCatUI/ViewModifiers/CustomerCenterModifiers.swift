//
//  CustomerCenterModifiers.swift
//  ARCPurchasingRevenueCatUI
//
//  Created by ARC Labs Studio on 24/03/2025.
//

#if os(iOS)
import ARCPurchasing
import RevenueCatUI
import SwiftUI

@available(iOS 18.0, *) public extension View {
    /// Present `ARCCustomerCenterView` as a sheet for subscription management.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls sheet presentation.
    ///   - onDismiss: Called when the Customer Center is dismissed.
    func presentARCCustomerCenter(isPresented: Binding<Bool>,
                                  onDismiss: (() -> Void)? = nil) -> some View {
        sheet(isPresented: isPresented) {
            ARCCustomerCenterView {
                isPresented.wrappedValue = false
                onDismiss?()
            }
        }
    }
}
#endif
