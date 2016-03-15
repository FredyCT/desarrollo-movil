//
//  ViewController.swift
//  Reproductor de Musica
//
//  Created by Fredy Cervantes Téllez on 11/03/16.
//  Copyright © 2016 CursoTecHardware. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIPickerViewAccessibilityDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var Opciones: UIPickerView!
    @IBOutlet weak var Portada: UIImageView!
    @IBOutlet weak var botonOrden: UISegmentedControl!
    @IBOutlet weak var botonReproduccion: UISegmentedControl!

    private var i_Reproductor: AVAudioPlayer!
    
    let i_Canciones = ["Abre tu corazón", "Afuera", "Alma gemela", "And I love her", "Behind the waterfall"]
    
    // MARK: Types
    
    enum Opcion: Int {
        case Cancion
        
        static var count: Int {
            return Opcion.Cancion.rawValue + 1
        }
    }
    
    var numeroCancion: Int = 0 {
        didSet {
            cambiaCancion()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configurePickerView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Configuration
    
    func configurePickerView() {
        // Show that a given row is selected. This is off by default.
        Opciones.showsSelectionIndicator = true
        
        // Set the default selected rows (the desired rows to initially select will vary from app to app).
        let selectedRows: [Opcion: Int] = [.Cancion: 0]
        
        for (l_Opciones, selectedRow) in selectedRows {
            /*
            Note that the delegate method on `UIPickerViewDelegate` is not triggered
            when manually calling `selectRow(_:inComponent:animated:)`. To do
            this, we fire off delegate method manually.
            */
            Opciones.selectRow(selectedRow, inComponent: l_Opciones.rawValue, animated: true)
            pickerView(Opciones, didSelectRow: selectedRow, inComponent: l_Opciones.rawValue)
        }
    }
    
    // MARK: Convenience
    
    func cambiaCancion() {
        let l_ArchivoImagen = NSBundle.mainBundle().pathForResource(i_Canciones[numeroCancion], ofType: "jpg")
        let li_Imagen = NSData.init(contentsOfFile: l_ArchivoImagen!)
        self.Portada.image = UIImage(data: li_Imagen!)
        
        let l_ArchivoCancion = NSBundle.mainBundle().URLForResource(i_Canciones[numeroCancion], withExtension: "mp3")
        
        do {
            try i_Reproductor = AVAudioPlayer(contentsOfURL: l_ArchivoCancion!)
            i_Reproductor.delegate = self
        } catch {
            print("Error al cargar la canción.")
        }
    }

    // MARK: UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return i_Canciones.count
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let title = i_Canciones[row]
        
        return title
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var l_Tocando:Bool = false
        
        switch Opcion(rawValue: component)! {
        case .Cancion:
            if (i_Reproductor != nil) { l_Tocando = i_Reproductor.playing }
            numeroCancion = row
            if l_Tocando { i_Reproductor.play() }
        }
    }
    
    // MARK: UIPickerViewAccessibilityDelegate
    
    func pickerView(pickerView: UIPickerView, accessibilityLabelForComponent component: Int) -> String? {
        switch Opcion(rawValue: component)! {
        case .Cancion:
            return NSLocalizedString("Canción seleccionada.", comment: String(numeroCancion))
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        var li_numeroCancion:Int = numeroCancion
        var li_cancionAleatoria:Int
        
        if botonOrden.selectedSegmentIndex == 0
        {
            ++li_numeroCancion
        } else {
            li_cancionAleatoria = Int.init(arc4random_uniform(UInt32.init(i_Canciones.count - 1)))
            
            if li_cancionAleatoria == numeroCancion
            {
                li_numeroCancion = numeroCancion + 1
            } else
            {
                li_numeroCancion = li_cancionAleatoria
            }
        }
        
        if li_numeroCancion == 5 { li_numeroCancion = 0 }
        
        let selectedRows: [Opcion: Int] = [.Cancion: li_numeroCancion]
        
        for (l_Opciones, selectedRow) in selectedRows {
            /*
            Note that the delegate method on `UIPickerViewDelegate` is not triggered
            when manually calling `selectRow(_:inComponent:animated:)`. To do
            this, we fire off delegate method manually.
            */
            Opciones.selectRow(selectedRow, inComponent: l_Opciones.rawValue, animated: true)
            pickerView(Opciones, didSelectRow: selectedRow, inComponent: l_Opciones.rawValue)
        }
        
        i_Reproductor.play()
    }
    
    @IBAction func reproduccionCancion(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if !i_Reproductor.playing
            {
                i_Reproductor.play()
            }
            break;
        case 1:
            if i_Reproductor.playing
            {
                i_Reproductor.pause()
            }
            break;
        case 2:
            if i_Reproductor.playing
            {
                i_Reproductor.stop()
                i_Reproductor.currentTime = 0.00
            }
            break;
        default:
            break;
        }
    }
    
    @IBAction func volumenCancion(sender: UISlider) {
        i_Reproductor.volume = sender.value
    }
}

