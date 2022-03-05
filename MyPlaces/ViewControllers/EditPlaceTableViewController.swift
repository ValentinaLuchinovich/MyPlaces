//
//  EditPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 29.11.2021.
//

import UIKit

class EditPlaceTableViewController: UITableViewController {
    
    // Создаем свойство хранящее в себе информацию внесенную в ячейку
    var currentPlace: Place?
    
    // Инициализируем экземпляр модели
    var imageIsChanged = false
    
    var textChanged: ((String) -> Void)?
    
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeDescription: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Делаем кнопку сохранения невидимой при первой загрузке экрана
        saveButton.isEnabled = false
        // Вызываем метод, который будет отслеживать есть ли в строке с именем текст
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        // Вызываем метод добавляющий информацию из ячейки на экран редактирования
        setupEditScreen()
        
        // Настройка textView
//        placeDescription.delegate = self
        placeDescription.isScrollEnabled = true
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexibleSpcae = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
        keyboardToolbar.items = [flexibleSpcae, doneButton]
        
        placeDescription.inputAccessoryView = keyboardToolbar
        
        UIView.setAnimationsEnabled(false)
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
    
    // Метод отвечает за сохранение заполненных полей в свойства модели
    func savePlace() {
        // Если изображение было изменено, то меняем маленькую версию картинки
        let image = imageIsChanged ?placeImage.image : UIImage(named: "cmera.circle.yellow")
     
        // Конвертируем изображение в тип Data, чтобы избавиться от несоответствия типов
        let imageData = image?.pngData()
        
        // Присваем значения всем свойствам экземпляра модели
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             myDescription: placeDescription.text,
                             imageData: imageData)
        
        //Проверяем находимя мы в режиме редактирования записи или же создания
        if currentPlace != nil {
            // Меняем измененное значение на новое
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.myDescription = newPlace.myDescription
                currentPlace?.imageData = newPlace.imageData
            }
        } else  {
        // Сохраняем новый объект в базе данных
        StorageManager.saveObject(newPlace)
        }
    }
    
    // Метод добавления информации из ячейки на экран редактирования записи
    private func setupEditScreen() {
        if currentPlace != nil {
            // Добавляем свойства для Navigation bar, которые должны срабатвать только при редактировании существующего объекта
            setupNavigationBar()
            // Избавляемся от бага, когда при редактировании изображение потом исчезает
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeDescription.text = currentPlace?.myDescription
        }
    }
    
    //Работа с Navigation bar
    private func setupNavigationBar() {
        // Убираем надпись Back на кнопке возврата на предыдущий экран и оставляем только стрелку
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        }
        // Убираем на экране редактирования кнопку cencel
        navigationItem.leftBarButtonItem = nil
        // Передаем в заголовок экрана редактирования название заведения
        title = currentPlace?.name
        // Делаем кнопку save на экране редактирования всегда доступной, так как ситуации когда нет названия при редавктировании существующей записи быть не может
        saveButton.isEnabled = true
        
        
    }
 
    // При нажатии на кнопку отмены вызываем метод закрывающий экран и стерающий его из памяти
    @IBAction func сancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: Navigation
    // Метод передает информацию о завидении при переходе на MapViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Извлекаем идентификатор сигвея
        guard
            let identifier = segue.identifier,
            let mapVC = segue.destination as? MapViewController
            else { return }
        mapVC.incomeSegueIdentifire = identifier
        
        // Создаем экзампляр класса MapViewController
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
    // Скрываем клавиатуру по нажатию на done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // Добавляем метод, делающую кнопку сохранения доступной или недоступной в зависимости от текста в строке названия места
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
    // скрываем клавиатуру при нажатии на экран за её пределами, но не на первую ячейку
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // Создаем константы для изображений камеры и галереи в алерт контроллере
            let cameraIcon = UIImage(systemName: "camera")
            let galeryIcon = UIImage(systemName: "photo.on.rectangle")
            
            // Создаем алерт контроллер, который будет появляться при нажатии на ячейку с фото
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            
            // Кнопка для создания нового фото
            let camera = UIAlertAction(title: "Камера", style: .default) { _Arg in
                // Вызываем метод позваляющий делать фото
                self.chooseImagePicker(source: .camera)
            }
            // Добавляем изображение камеры в алерт контроллер
            camera.setValue(cameraIcon, forKey: "image")
            // Размещаем заголовок меню по левому краю рядом с изображением
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            
            // Кнопка загрузки фото из галереи
            let photo = UIAlertAction(title: "Загрузить фото", style: .default) { _ in
                // Вызываем метод, позволяющий загрузить фото из галереи
                self.chooseImagePicker(source: .photoLibrary)
            }
            // Добавляем изображение галереи в алерт контроллер
            photo.setValue(galeryIcon, forKey: "image")
            // Размещаем заголовок меню по левому краю рядом с изображением
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            // Кнопка отменяющая вызов меню
            let cencel = UIAlertAction(title: "Отменить", style: .cancel)
            //Кнопка для загрузки изображения из библиотеки устройства
            
            // Добавляем кнопки с действиями в алерт контроллер
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cencel)
            
            // Вызываем алерт контроллер
            present(actionSheet, animated: true)
            
        } else {
            //Если нажатие за приделами пераой ячейки с изображением, то скрываем клавиатуру
            view.endEditing(true)
        }
    }
}

// MARK: Work with image
// Cоздаём отдельное расширение для работы с изображениями
extension EditPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        // проверяем доступен ли источник выбора изображения
        if UIImagePickerController.isSourceTypeAvailable(source) {
            // Даем пользователю возможность редактирования изображения
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            // Проверяем тип источника для выбранного изображения
            imagePicker.sourceType = source
            // Вызываем имидж пикер
            present(imagePicker, animated: true)
        }
    }
    
    // Присваеваем imageOfPlace выбранное изображение
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // В info выбираем тип контента, в данном случае это отредактированное (editingImage) пользователем изображение
        placeImage.image = info[.editedImage] as? UIImage
        // Возможность масштабировать изображение
        placeImage.contentMode = .scaleAspectFill
        // Оберезаем изображение по границе imageView
        placeImage.clipsToBounds = true
        imageIsChanged = true
        // Закрываем imagePicker Controller
        dismiss(animated: true)
    }
}

extension EditPlaceTableViewController: MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
}
