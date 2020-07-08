//
//  ContentView.swift
//  OffsetDemo
//
//  Created by József Vesza on 2020. 07. 08..
//

import SwiftUI

struct ContentView: View {
    private struct Constants {
        static let defaultHeaderHeight: CGFloat = 250
        static let minCompactHeaderHeight: CGFloat = 100
        static let maxStretchedHeaderHeight: CGFloat = 300
        static let itemHeight: CGFloat = 100
        static let scrollUpTolerance: CGFloat = 20
        static let scrollDownTolerance: CGFloat = 100
    }
    
    @State private var headerOffset: CGFloat = .zero
    @State private var headerHeight: CGFloat?
    
    private let colors: [Color] = [
        .blue, .gray, .green, .orange, .pink, .purple, .yellow,
        .blue, .gray, .green, .orange, .pink, .purple, .yellow,
    ]
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack {
                        Rectangle()
                            .withFill(.clear,
                                      height: Constants.defaultHeaderHeight)
                            .modifier(HeightReporter())
                            .modifier(OffsetReporter())
                        ForEach(colors.indices) { index in
                            Rectangle()
                                .withFill(colors[index],
                                          height: Constants.itemHeight)
                        }
                    }
                    .onPreferenceChange(HeightPreference.self) { value in
                        headerHeight = value
                    }
                    .onPreferenceChange(OffsetPreference.self) { value in
                        headerOffset = value ?? .zero
                    }
                }
                Rectangle()
                    .edgesIgnoringSafeArea(.top)
                    .overlay(VStack {
                        Spacer()
                        Text("Calculated height: \(calculateHeaderHeight(for: headerOffset), specifier: "%.2f")")
                            .foregroundColor(.white)
                        Spacer()
                    })
                    .withFill(.black,
                              height: calculateHeaderHeight(for: headerOffset))
                    .animation(.spring())
            }
            Spacer()
            Text("Header offset: \(headerOffset, specifier: "%.2f")")
        }
    }
    
    private func calculateHeaderHeight(for scrollOffset: CGFloat) -> CGFloat {
        switch scrollOffset {
        case -CGFloat.greatestFiniteMagnitude ..< Constants.scrollUpTolerance:
            return max((headerHeight ?? .zero) - abs(headerOffset),
                       Constants.minCompactHeaderHeight)
        case Constants.scrollDownTolerance ..< CGFloat.greatestFiniteMagnitude:
            return min((headerOffset + (headerHeight ?? .zero)),
                       Constants.maxStretchedHeaderHeight)
        default:
            return Constants.defaultHeaderHeight
        }
    }
}

// MARK: - Scroll offset
struct OffsetPreference: PreferenceKey {
    static var defaultValue: CGFloat?
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

/// Modifier that will report it's frame's minimum Y value via the `OffsetPreference` key
struct OffsetReporter: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear.preference(key: OffsetPreference.self,
                                       value: proxy.frame(in: .global).minY)
            }
        )
    }
}

// MARK: - Height reporting
struct HeightPreference: PreferenceKey {
    static var defaultValue: CGFloat?
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

/// Modifier, that will report the view's height via the `HeightPreference` key
struct HeightReporter: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear.preference(key: HeightPreference.self,
                                       value: proxy.size.height)
            }
        )
    }
}

// MARK: - Convenience
/// Modifier that will apply a given foreground color and height restriction to a view.
struct FillAndHeightModifier: ViewModifier {
    let fill: Color
    let height: CGFloat
    
    func body(content: Content) -> some View {
        content.foregroundColor(fill).frame(height: height)
    }
}

extension View {
    /// Applies a foreground color and a height restriction to the view
    /// - Parameters:
    ///   - fill: The desired foreground color
    ///   - height: The desired height
    /// - Returns: A modified view with the foreground color and height applied.
    func withFill(_ fill: Color, height: CGFloat) -> some View {
        modifier(FillAndHeightModifier(fill: fill, height: height))
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
