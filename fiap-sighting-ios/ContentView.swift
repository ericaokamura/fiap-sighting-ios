//
//  ContentView.swift
//  fiap-sighting-ios
//
//  Created by Luiz Lima on 04/06/24.
//

import CoreLocation
import MapKit
import SwiftUI

struct MarineSightApp: App {
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.locationManager)
        }
    }
}

struct ContentView: View {
    @State private var species: String = ""
    @State private var description: String = ""
    @State private var location: CLLocationCoordinate2D?
    @State private var sightings: [Sighting] = []

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Species", text: self.$species)
                    TextField("Description", text: self.$description)
                }
                Button("Submit") {
                    self.submitSighting()
                }
                .padding()
                MapView(sightings: self.$sightings)
                    .onAppear(perform: self.fetchSightings)
            }
            .navigationTitle("MarineSight")
        }
    }

    func submitSighting() {
        // Capture location and send data to backend
        let newSighting = Sighting(species: species, description: description, latitude: location?.latitude ?? 0, longitude: self.location?.longitude ?? 0)
        guard let url = URL(string: "http://localhost:8080/sightings") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let encoded = try? JSONEncoder().encode(newSighting) else { return }
        request.httpBody = encoded

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            if let decodedResponse = try? JSONDecoder().decode(Sighting.self, from: data) {
                DispatchQueue.main.async {
                    self.sightings.append(decodedResponse)
                }
            }
        }.resume()
    }

    func fetchSightings() {
        guard let url = URL(string: "http://localhost:8080/sightings") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            if let decodedResponse = try? JSONDecoder().decode([Sighting].self, from: data) {
                DispatchQueue.main.async {
                    self.sightings = decodedResponse
                }
            }
        }.resume()
    }
}

struct Sighting: Codable, Identifiable {
    var id: Int?
    var species: String
    var description: String
    var latitude: Double
    var longitude: Double
}

struct MapView: View {
    @Binding var sightings: [Sighting]

    var body: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )), annotationItems: self.sightings) { sighting in
            MapMarker(coordinate: CLLocationCoordinate2D(
                latitude: sighting.latitude,
                longitude: sighting.longitude
            ), tint: .blue)
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location.coordinate
    }
}

#Preview {
    ContentView()
}
