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
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isShowingForm = false
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                MapView(sightings: self.$sightings)
                    .edgesIgnoringSafeArea(.all)

                if self.isShowingForm {
                    Text("Informe o avistamento")
                        .font(.title)
                        .padding()
                    Text("Seu relato será anônimo e compartilhado com autoridades para a preservação da vida marinha.")
                        .font(.subheadline)
                        .padding(.horizontal)
                    Form {
                        TextField("Espécie Marinha", text: self.$species)
                        TextField("Escreva o seu relato", text: self.$description)
                    }
                }

                if self.isShowingForm {
                    Button(action: {
                        guard let location = self.locationManager.lastKnownLocation else {
                            self.showingAlert = true
                            self.alertMessage = "Não foi possível obter a localização atual"
                            return
                        }
                        let sighting = Sighting(
                            id: nil,
                            species: self.species,
                            description: self.description,
                            latitude: location.latitude,
                            longitude: location.longitude
                        )
                        self.sightings.append(sighting)
                        self.showingAlert = true
                        self.alertMessage = "Avistamento cadastrado com sucesso"
                    }) {
                        Text("Cadastrar novo avistamento")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }

                Button(action: {
                    self.isShowingForm.toggle()
                }) {
                    Text(self.isShowingForm ? "Cancelar" : "Cadastrar novo avistamento")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(self.isShowingForm ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("MarineSight")
            .alert(isPresented: self.$showingAlert) {
                Alert(title: Text("Success"), message: Text(self.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct MapView: View {
    @Binding var sightings: [Sighting]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
            )), annotationItems: self.sightings) { sighting in
                MapMarker(coordinate: CLLocationCoordinate2D(
                    latitude: sighting.latitude,
                    longitude: sighting.longitude
                ), tint: .blue)
            }
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                Text("\(self.sightings.count) avistamentos")
                    .padding(12)
                    .background(Color.white.opacity(0.8))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .padding(8)
            }
        }
    }
}

struct Sighting: Codable, Identifiable {
    var id: Int?
    var species: String
    var description: String
    var latitude: Double
    var longitude: Double
}

final class LocationManager: NSObject, ObservableObject {
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    var manager = CLLocationManager()

    override init() {
        super.init()
        checkLocationAuthorization()
        manager.delegate = self
    }

    func checkLocationAuthorization() {
        manager.startUpdatingLocation()

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()

        case .restricted:
            print("Location restricted")

        case .denied:
            print("Location denied")

        case .authorizedAlways:
            print("Location authorizedAlways")

        case .authorizedWhenInUse:
            print("Location authorized when in use")
            if let location = manager.location {
                lastKnownLocation = location.coordinate
            } else {
                print("Unable to get current location")
            }

        @unknown default:
            print("Location service disabled")
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lastKnownLocation = location.coordinate
        }
    }
}

class LocationModel: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        locationManager.delegate = self
    }

    public func requestAuthorization(always: Bool = false) {
        if always {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension LocationModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}
