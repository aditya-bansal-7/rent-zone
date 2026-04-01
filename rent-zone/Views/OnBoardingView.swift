//
//  OnBoardingView.swift
//  rent-zone
//
//  Created by Vansh     on 01/04/26.
//

import SwiftUI

struct OnboardingPage {
    let imageName: String
    let title: String
    let subtitle: String
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "onboarding1",
            title: "Affordable Fits For\nEvery College Event",
            subtitle: "Fest, farewell, traditional - we've\ngot you covered"
        ),
        OnboardingPage(
            imageName: "onboarding2",
            title: "Earn Money From Your\nWardrobe",
            subtitle: "List your outfits and make extra cash"
        ),
        OnboardingPage(
            imageName: "onboarding3",
            title: "Rent Outfits From\nStudents",
            subtitle: "Discover affordable fashion from your\ncampus community"
        )
    ]
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                if currentPage == pages.count - 1 {
                    Button(action: {
                        hasCompletedOnboarding = true
                    }) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                            )
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                } else {
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.primary : Color(.systemGray4))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            
            Button(action: {
                hasCompletedOnboarding = true
            }) {
                Text("Skip")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
            }
            .padding(.top, 12)
            .padding(.trailing, 24)
        }
        .background(Color.white)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 0) {
            Image(page.imageName)
                .resizable()
                .frame(width: 650, height: 500)
                .clipped()
                .padding(.top, 20)
            
            Spacer().frame(height: 10)
            
            Text(page.title)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Spacer().frame(height: 14)
            
            Text(page.subtitle)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
