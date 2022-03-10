# MyPlaces

<b>Краткое описание: </b>
<br>Приложение <b>MyPlaces</b> - это своего рода дневник путешествий, оно позволяет добавлять и сохранять информацию о местах посещённых пользователем - локацию, описание, фотографию. </br>

## Используемые технологии: 
 
<br> 1. Проект полностью написан на UIKit</br> 
2. Реализована архитектура MVC с отельно вынесенными StorageManager и MapManager
<br> 3. Использованы Tab Bar Controller, Navigation Controller </br>
4. Использованы Table View и Collection View
<br> 5. Статические и кастомные ячейки, Contextual Action. </br>
6. Работа с MapKit, аннтотациями, геолокацией и запросом на использование геопозиции
<br> 7. Получение адреса по расположению маркера на карте </br>
8. Сохранение данных реализовано с использованием Realm 
<br> 9. Реализованы разные виды сортировки сортировка в том числе с помощью Segmented Control и Search Controler. </br>
10. Загрузка фотографий из галиреи или с использованием фотокамеры
<br> 11. Auto Layout, Flow Layout </br>
12. Работа с многопоточностью, асинхронная загрузка данных
<br> 13. Alert Controller </br>

### Что ещё планируется реализовать/проблемы с которыми столкнулась:</b>
1. Перевод кода на MVVM
2. Работа над дизайном 
3. На данный момент в AllPlacesVC загрузка и отображение аннотаций, а также масштабирование карты происходит в методе viewWillAppear, что является не самым элегантным решением. Конечно это позволяет при удалении или добавлении новых мест сразу же отображать их на карте, но в случае когда изменений не происходит ресурс устройства расходуетс зря
4. В планах добавить возможность делиться картой посещённых мест
5. Так же в более далёких планах сделать что-то вроде социальной сети, подключить базу данных и дать пользователям возможность смотреть публиковать карты своих мест для других

<img src="https://github.com/ValentinaLuchinovich/MyPlaces/blob/Screenshots/IMG_6574.PNG" width="400"/> <img src="https://github.com/ValentinaLuchinovich/MyPlaces/blob/Screenshots/IMG_6575.PNG" width="400"/>
<img src="https://github.com/ValentinaLuchinovich/MyPlaces/blob/Screenshots/IMG_6576.PNG" width="400"/> <img src="https://github.com/ValentinaLuchinovich/MyPlaces/blob/Screenshots/IMG_6580.PNG" width="400"/>
<img src="https://github.com/ValentinaLuchinovich/MyPlaces/blob/Screenshots/IMG_6578.PNG" width="400"/> <img src="https://github.com/ValentinaLuchinovich/MyPlaces/blob/Screenshots/IMG_6577.PNG" width="400"/> 



