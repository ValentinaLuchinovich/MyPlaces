//
//  EditPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 29.11.2021.
//

import UIKit

class EditPlaceTableViewController: UITableViewController {
    
    var newPlace: Place?
    var imageIsChanged = false
    
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeDescription: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Делаем кнопку сохранения невидимой при первой загрузке экрана
        saveButton.isEnabled = false
        // Вызываем метод, который будет отслеживать есть ли в строке с именем текст
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    // Метод отвечает за сохранение заполненных полей в свойства модели
    func saveNewPlace() {
        var image: UIImage?
        // Если изображение было изменено, то меняем маленькую версию картинки
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = UIImage(systemName: "camera.circle")
        }
        newPlace = Place(name: placeName.text!,
                         location: placeLocation.text,
                         description: placeDescription.text,
                         image: image)
    }
 
    // При нажатии на кнопку отмены вызываем метод закрывающий экран и стерающий его из памяти
    @IBAction func сancelAction(_ sender: Any) {
        dismiss(animated: true)
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
