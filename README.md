# Raiffeisen SBP SDK

СДК предоставляет функционал для перенаправления пользователя для оплаты по СБП.

### Установка

1.    Добавьте фреймворк в проект

Для подключения данного фреймворка в проект используется Swift Package Manager.

- В меню Xcode выбираем File -> Add Packages...
- Далее в открывшемся окне в поле поиска копируем ссылку на данный репозиторий (ссылка должна заканчиваться на .git)
- Устанавливаем Dependency Rule, например branch: main (в этом случае всегда будет подтягиваться состояние с ветки main)
- Устанавливаем Add to project. В этом поле нужно указать к какому проекту должен быть подключен фреймворк.
- Нажимаем кнопку Add Package. 

После этого фреймворк можно использовать. 

2.    Настройте конфигурацию info.plist:

Вам необходимо добавить ключи LSApplicationQueriesSchemes в ваш info.plist.

Это необходимо для того, чтобы метод UIApplication.shared.canOpenURL работал корректно.

Для того чтобы эти ключи подгружались во время сборки добавьте Run Script в таргете вашего проекта во вкладке Build Phases и пропишите следующий код:

```bash
plutil -remove LSApplicationQueriesSchemes @INFO_PLIST_FILE

plutil -insert LSApplicationQueriesSchemes -xml '<array/>' @INFO_PLIST_FILE

list=$(curl -s 'https://qr.nspk.ru/proxyapp/c2bmembers.json' | jq -r '.dictionary[].schema')

index=0

for value in $list;
do
    plutil -insert LSApplicationQueriesSchemes.$index -string $value @INFO_PLIST_FILE
    index=$((index+1))
done
```

Так же необходимо установить библиотеку jq для парсинга json в bash.

```bash
brew install jq
```

*Начиная с iOS 15, существует ограничение максимум на 50 ключей приложений в списке, поэтому будут учитываться только первый 50 ключей. Подробности смотрите [здесь](https://developer.apple.com/documentation/uikit/uiapplication/1622952-canopenurl#discussion).*



### Использование:

1.    Добавьте импорт фреймворка

2.    Проинициализируйте класс SBPRedirectView(), передав ссылку на оплату в формате: `https://qr.nspk.ru/AD100004BAL7227F9BNP6KNE007J9B3K?type=02&bank=100000000007&sum=1&cur=RUB&crc=AB75`
    и обработав результат.

3.    Вызовите метод show(), передав в параметрах UIViewController.

4.    В комплишне вызовите метод dismiss() в случаях, когда виджет нужно скрыть.

```swift
import UIKit
import sbp_framework

class ViewController: UIViewController {
    
    private var sbpModule: SBPRedirectModule?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func showSBPPopup(_ sender: Any) {
   
        sbpModule = SBPRedirectModule(link: link) { [weak self] result in
            switch result {
            case let .redirectToBank(scheme):
                print("redirected to bank: \(scheme)")
                self?.sbpModule?.dismiss()
            case let .redirectToDownloadBank(scheme):
                print("redirected to App Store to download bank: \(scheme)")
            case let .redirectToBankFailed(error):
                print(error)
            case .redirectToDefaultBank:
                print("redirect to default bank")
            case .dialogDismissed:
                print("dialog dissmissed")
            }
        }
        
        sbpModule?.show(on: self)
    }
}
```

### Сборка семпл проекта
Выполните команду pod install, находясь в директории example.

Откройте example/example.workspace и нажмите "Run".

Так же в корне проекта есть уже собраный файл sbp-sdk-ios-build.ipa.
