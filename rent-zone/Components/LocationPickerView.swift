import SwiftUI
import MapKit

struct LocationPickerView: View {
    var onLocationSelected: (CLLocationCoordinate2D, String?) -> Void
    var onDismiss: () -> Void
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var centerCoordinate: CLLocationCoordinate2D?
    @State private var isDragging = false
    @State private var addressName: String? = nil
    @State private var isGeocoding = false
    
    var body: some View {
        ZStack {
            Map(position: $position)
                .onMapCameraChange(frequency: .continuous) { context in
                    isDragging = true
                    centerCoordinate = context.region.center
                    addressName = nil
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    isDragging = false
                    centerCoordinate = context.region.center
                    reverseGeocode(coordinate: context.region.center)
                }
                .ignoresSafeArea()
            
            // Center Pin
            VStack {
                Spacer()
                Image(systemName: "mappin")
                    .font(.system(size: 40))
                    .foregroundColor(.brandPurple)
                    .offset(y: isDragging ? -15 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
                    // adjust offset so the tip of the pin is at the exact center
                    .padding(.bottom, 40)
                Spacer()
            }
            
            VStack {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 40, height: 40)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Bottom panel
                VStack(spacing: 16) {
                    if isGeocoding {
                        ProgressView()
                    } else if let addressName = addressName {
                        Text(addressName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    } else {
                        Text("Move the map to select a location")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        if let coord = centerCoordinate {
                            onLocationSelected(coord, addressName)
                        }
                    }) {
                        Text("Send Location")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.brandPurple)
                            .cornerRadius(12)
                    }
                    .disabled(isDragging || centerCoordinate == nil)
                    .opacity(isDragging || centerCoordinate == nil ? 0.6 : 1.0)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            ChatService.shared.requestCurrentLocation { loc in
                position = .region(MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
            }
        }
    }
    
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        isGeocoding = true
        Task {
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            if let placemarks = try? await geocoder.reverseGeocodeLocation(location), let placemark = placemarks.first {
                let name = [placemark.name, placemark.locality, placemark.administrativeArea]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                await MainActor.run {
                    self.addressName = name.isEmpty ? nil : name
                    self.isGeocoding = false
                }
            } else {
                await MainActor.run {
                    self.addressName = "Unknown Location"
                    self.isGeocoding = false
                }
            }
        }
    }
}
