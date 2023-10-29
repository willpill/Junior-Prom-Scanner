//
//  ContentView.swift
//  JPromScanner
//
//  Created by Yinwei Z on 10/28/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var cameraUpdateTrigger: Bool = false
    @State private var barcode: String = "Place Barcode in View to Scan"
    @ObservedObject var cameraController = CameraController()
    
    var body: some View {
        VStack {
            displayBarcodeImage()
            
            Spacer()
            
            VStack(alignment: .center) {
                CameraViewWrapper(cameraController: cameraController, updateTrigger: $cameraUpdateTrigger, barcode: $barcode)
                    .frame(maxHeight: 300)
                    .cornerRadius(25)
                
                Spacer().frame(height: 17)
                
                displayActions()
            }
            .animation(.easeInOut(duration: 0.3), value: barcode)
            
            Spacer()
            
            Text(barcode).font(.headline)
        }
        .padding(25)
        .preferredColorScheme(.dark)
        .onAppear(perform: resetBarcodeOnAppear)
        .onChange(of: cameraController.barcodeString, perform: handleBarcodeChange)
    }
    
    func displayBarcodeImage() -> some View {
        Group {
            Image(systemName: (barcode == "Place Barcode in View to Scan") ? "barcode.viewfinder" : "checkmark")
                .contentTransition(.symbolEffect(.replace))
                .font(.title)
            
        }
    }
    
    func displayActions() -> some View {
        Group {
            if barcode != "Place Barcode in View to Scan" {
                Button {
                    restartCameraSession()
                } label: {
                    HStack {
                        Text("Admit Now")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "person")
                    }
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(20)
                .controlSize(.large)

                Spacer().frame(height: 15)

                Button {
                    restartCameraSession()
                } label: {
                    HStack {
                        Text("Ignore")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "minus")
                    }
                }
                .buttonStyle(.bordered)
                .cornerRadius(20)
                .controlSize(.large)
            } else {
                EmptyView()
            }
        }
    }
    
    func restartCameraSession() {
        DispatchQueue.main.async {
            self.cameraController.captureSession.stopRunning()
            self.cameraController.resetBarcode()
            self.cameraUpdateTrigger.toggle()
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) {
                self.cameraController.captureSession.startRunning()
            }
        }
    }
    
    func resetBarcodeOnAppear() {
        cameraController.barcodeString = "Place Barcode in View to Scan"
    }
    
    func handleBarcodeChange(newBarcode: String?) {
        if let newBarcode = newBarcode {
            barcode = newBarcode
            if cameraController.captureSession?.isRunning == true {
                cameraController.captureSession.stopRunning()
            }
        }
    }
}

struct CameraViewWrapper: View {
    let cameraController: CameraController
    @Binding var updateTrigger: Bool
    @Binding var barcode: String

    var body: some View {
        ZStack {
            CameraView(cameraController: cameraController, updateTrigger: $updateTrigger)
            if barcode == "Place Barcode in View to Scan" {
                ScanningLineView()
            }
        }
    }
}

struct CameraView: UIViewRepresentable {
    let cameraController: CameraController
    @Binding var updateTrigger: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.global(qos: .userInitiated).async {
            self.cameraController.startCamera(view)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
