import XCTest

final class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        
    }

    func testAuth() throws {
        // 1. Нажать кнопку "Authenticate"
        app.buttons["Authenticate"].tap()

        // 2. Найти WebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView не загрузился")

        // 3. Найти поле логина
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5), "Поле логина не найдено")

        // 4. Ввести логин
        loginTextField.tap()
        loginTextField.typeText("Login")

        // 5. Скрыть клавиатуру, если нужно
        webView.swipeUp()

        // 6. Найти поле пароля
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Поле пароля не найдено")

        // 7. Ввести пароль
        passwordTextField.tap()
        passwordTextField.typeText("Pasword")

        // 8. Скрыть клавиатуру, если нужно
        webView.swipeUp()

        // 9. Найти кнопку "Login" и нажать
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Кнопка Login не найдена")
        loginButton.tap()

        // 10. Проверить, что появилась лента (первый cell)
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Лента не загрузилась")
    }
    
    func testFeed() throws {
            // 1. Подождать загрузку экрана ленты
            let feedTable = app.tables.firstMatch
            XCTAssertTrue(feedTable.waitForExistence(timeout: 5), "Feed table did not load")

            // 2. Проскроллить вверх
            feedTable.swipeUp()

            // 3. Найти первую ячейку
            let firstCell = feedTable.cells.element(boundBy: 0)
            XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First cell not found")

            // 4. Найти кнопку лайка и поставить лайк
            let likeButton = firstCell.buttons["likeButton"]
            XCTAssertTrue(likeButton.exists, "Like button not found")
            likeButton.tap()

            // 5. Снять лайк
            likeButton.tap()

            // 6. Открыть картинку на весь экран
            firstCell.tap()

            // 7. Проверить, что открылся экран с картинкой
            let imageView = app.scrollViews.images.element(boundBy: 0)
            XCTAssertTrue(imageView.waitForExistence(timeout: 5), "Full screen image did not appear")

            // 8. Увеличить картинку
            imageView.pinch(withScale: 3, velocity: 1)

            // 9. Уменьшить картинку
            imageView.pinch(withScale: 0.5, velocity: -1)

            // 10. Вернуться назад
            let backButton = app.buttons["backButton"]
            XCTAssertTrue(backButton.exists, "Back button not found")
            backButton.tap()

            // Проверить, что вернулись в ленту
            XCTAssertTrue(feedTable.waitForExistence(timeout: 5), "Did not return to feed")
        }

        func testProfile() throws {
            // 1. Подождать загрузку экрана ленты
            let feedTable = app.tables.firstMatch
            XCTAssertTrue(feedTable.waitForExistence(timeout: 5), "Feed table did not load")

            // 2. Перейти на экран профиля (по тапу на Tab Bar)
            let profileTab = app.tabBars.buttons.element(boundBy: 1)
            XCTAssertTrue(profileTab.exists, "Profile tab not found")
            profileTab.tap()

            // 3. Проверить наличие данных профиля
            let usernameLabel = app.staticTexts["usernameLabel"]
            XCTAssertTrue(usernameLabel.waitForExistence(timeout: 5), "Username label not found")

            // 4. Нажать кнопку логаута
            let logoutButton = app.buttons["exitButton"]
            XCTAssertTrue(logoutButton.exists, "Logout button not found")
            logoutButton.tap()

            // 5. Подтвердить выход (если есть Alert)
            let confirmButton = app.alerts.buttons["Да"]
            if confirmButton.exists {
                confirmButton.tap()
            }

            // 6. Проверить, что открылся экран авторизации
            let authButton = app.buttons["Authenticate"]
            XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Auth screen did not appear")
        }

}
