//
//  EditPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 29.11.2021.
//

import UIKit

class EditPlaceTableViewController: UITableViewController {
    
    var currentPlace: Place?
    // Инициализация экземпляра модели
    private var imageIsChanged = false

    var textChanged: ((String) -> Void)?
    
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeDescription: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        // Проверка наличия текста в placeName
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
        
        // Настройка textView
        placeDescription.isScrollEnabled = true
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexibleSpcae = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
        keyboardToolbar.items = [flexibleSpcae, doneButton]
        placeDescription.inputAccessoryView = keyboardToolbar
        UIView.setAnimationsEnabled(false)
    }
    
    @IBAction func сancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    @objc func doneButtonPressed(_ sender: UIBarButtonItem) {
        placeDescription.resignFirstResponder()
    }
    
    // Cохранение заполненных полей в свойства модели
    func savePlace() {
        let image = imageIsChanged ?placeImage.image : UIImage(named: "cmera.circle.yellow")
        let imageData = image?.pngData()
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             myDescription: placeDescription.text,
                             imageData: imageData)
        
        //Проверка - режим редактирования\новая запись
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.myDescription = newPlace.myDescription
                currentPlace?.imageData = newPlace.imageData
            }
        } else  {
            StorageManager.saveObject(newPlace)
        }
    }
    
    
    // Добавление информации из ячейки на экран редактирования записи
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigationBar()
            // Избавляет от бага, когда при редактировании изображение исчезает
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeDescription.text = currentPlace?.myDescription
        }
    }
    
    //MARK: NavigationBar
  
    private func setupNavigationBar() {
        // Убрана надпись Back, осталось только стрелка "назад"
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        }
        // Работа с экраном редактирования
        // На экране редактирования убрана кнопка cencel
        navigationItem.leftBarButtonItem = nil
        // Заголовок экрана редактирования - название заведения
        title = currentPlace?.name
        // Кнопка редактирования - всегда доступна
        saveButton.isEnabled = true
    }
 
  
    // MARK: Navigation
    // Передача информации о завидении при переходе на MapViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let identifier = segue.identifier,
            let mapVC = segue.destination as? MapViewController
        else { return }
        mapVC.incomeSegueIdentifire = identifier
        mapVC.mapViewControllerDelegate = self
      
        if identifier == "showPlace" {
            // Передаем значения на MapViewController
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text
            mapVC.place.myDescription = placeDescription.text
            mapVC.place.imageData = placeImage.image?.pngData()
        }
    }
}


// MARK: Text field delegate
extension EditPlaceTableViewController: UITextFieldDelegate {
    //  Клавиатура скрывается по нажатию
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // Кнопка сохранения - доступна\недоступна
    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

//MARK: Table view delegate

extension EditPlaceTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Загрузка фото для записи
        if indexPath.row == 0 {
            let cameraIcon = UIImage(systemName: "camera")
            let galeryIcon = UIImage(systemName: "photo.on.rectangle")
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            // Сделать новое фото
            let camera = UIAlertAction(title: "Камера", style: .default) { _Arg in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            // Загрузка фото из галереи
            let photo = UIAlertAction(title: "Загрузить фото", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(galeryIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cencel = UIAlertAction(title: "Отменить", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cencel)
            
            present(actionSheet, animated: true)
            
        } else {
            //Нажатие за приделами пераой ячейки с изображением скрывает клавиатуру
            view.endEditing(true)
        }
    }
}


// MARK: Work with image

extension EditPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            // Возможность редактирования изображения
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    // Присвоение записи изображения
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        imageIsChanged = true
        dismiss(animated: true)
    }
}


// MARK: MapDelegate

extension EditPlaceTableViewController: MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
}
