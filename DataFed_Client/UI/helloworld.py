# importing the required libraries 
from PyQt5.QtWidgets import *
import sys 

class Window(QMainWindow): 
	def __init__(self): 
		super().__init__() 

		# set the title 
		self.setWindowTitle("hellow world !") 

		# set the geometry 
		self.setGeometry(0, 0, 300, 300) 

		# create label widget 
		# to display content on screen 
		self.label = QLabel("Hello World !!", self) 

		# show all the widgets 
		self.show() 

# create pyqt5 app 
App = QApplication(sys.argv) 

# create the instance of our Window 
window = Window() 

# start the app 
sys.exit(App.exec()) 
