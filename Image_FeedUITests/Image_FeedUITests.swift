import XCTest

final class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {}

    func testAuth() throws {
        // 1. Найти и нажать кнопку "Authenticate"
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Кнопка Authenticate не найдена")
        authButton.tap()

        // 2. Найти WebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView не загрузился")

        // 3. Найти поле логина
        let loginTextField = webView.textFields.element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5), "Поле логина не найдено")
        loginTextField.tap()
        loginTextField.typeText("andreyboyarko@gmail.com")

        // 4. Найти поле пароля
        let passwordTextField = webView.secureTextFields.element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Поле пароля не найдено")
        passwordTextField.tap()
        passwordTextField.typeText("989874851")

        // 5. Нажать кнопку "Login"
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Кнопка Login не найдена")
        loginButton.tap()

        // 6. Проверить появление ленты
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Лента не загрузилась")
    }

    func testFeed() throws {
        let app = XCUIApplication()

        let feedTable = app.tables.firstMatch
        XCTAssertTrue(feedTable.waitForExistence(timeout: 5), "Feed table did not load")

        // Достаём первую ячейку и убеждаемся, что она существует
        let firstCell = feedTable.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First cell not found")

        // Если ячейка не видна, делаем свайп (можно удалить, если не требуется)
        firstCell.swipeUp()

        // Ждём появления кнопки лайка внутри первой ячейки
        let likeButton = firstCell.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5), "Like button not found")
        
        // Лайк / дизлайк
        likeButton.tap()
        likeButton.tap()

        // Тап по ячейке — открытие полноэкранного фото
        firstCell.tap()

        let imageView = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(imageView.waitForExistence(timeout: 5), "Full screen image not found")

        // Зум
        imageView.pinch(withScale: 3, velocity: 1)
        imageView.pinch(withScale: 0.5, velocity: -1)

        // Назад
        let backButton = app.buttons["backButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button not found")
        backButton.tap()

        // Проверка, что снова отобразилась таблица с лентой
        XCTAssertTrue(feedTable.waitForExistence(timeout: 5), "Did not return to feed")
    }

    func testProfile() throws {
        let app = XCUIApplication()
        
        // Если отображается кнопка "Authenticate", значит нужно авторизоваться
        if app.buttons["Authenticate"].exists {
            try testAuth() // Выполняем авторизацию
        }

        // Ждём таблицу с лентой
        let feedTable = app.tables.firstMatch
        XCTAssertTrue(feedTable.waitForExistence(timeout: 10), "Feed table did not load")

        // Переход на вкладку Профиля
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.exists, "Profile tab not found")
        profileTab.tap()

        // Проверка отображения данных профиля
        let usernameLabel = app.staticTexts["usernameLabel"]
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: 5), "Username label not found")

        // Логаут
        let logoutButton = app.buttons["exitButton"]
        XCTAssertTrue(logoutButton.exists, "Logout button not found")
        logoutButton.tap()

        // Подтверждение
        let confirmButton = app.alerts.buttons["Да"]
        if confirmButton.waitForExistence(timeout: 3) {
            confirmButton.tap()
        }

        // Проверка, что вернулись на экран авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Auth screen did not appear")
    }

}

