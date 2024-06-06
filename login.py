import sys
from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QLineEdit, QPushButton, QVBoxLayout, QMessageBox
from datafed import Client

class LoginWindow(QWidget):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("DataFed Login")
        self.setGeometry(100, 100, 300, 150)

        self.initUI()

    def initUI(self):
        layout = QVBoxLayout()

        self.username_label = QLabel("Username:")
        self.username_input = QLineEdit()
        layout.addWidget(self.username_label)
        layout.addWidget(self.username_input)

        self.password_label = QLabel("Password:")
        self.password_input = QLineEdit()
        self.password_input.setEchoMode(QLineEdit.Password)
        layout.addWidget(self.password_label)
        layout.addWidget(self.password_input)

        self.login_button = QPushButton("Login")
        self.login_button.clicked.connect(self.handle_login)
        layout.addWidget(self.login_button)

        self.setLayout(layout)

    def handle_login(self):
        username = self.username_input.text()
        password = self.password_input.text()

        if self.authenticate_user(username, password):
            QMessageBox.information(self, "Login Successful", "You have successfully logged in!")
        else:
            QMessageBox.warning(self, "Login Failed", "Invalid username or password. Please try again.")

    def authenticate_user(self, username, password):
        try:
            client = Client.Client()  # Initialize the DataFed client
            client.login(username, password)
            return True
        except Exception as e:
            print(f"Login failed: {e}")
            return False

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = LoginWindow()
    window.show()
    sys.exit(app.exec_())
