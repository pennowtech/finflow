# Copyright (c) 2025 Sukhdeep Singh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import sys
from PySide6.QtWidgets import QApplication
from PySide6.QtGui import QIcon
from PySide6.QtQml import QQmlApplicationEngine
from PySide6 import QtCharts

import resources.resources_rc

if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setWindowIcon(QIcon("finflow/resources/icons/app.png"))

    engine = QQmlApplicationEngine()
    engine.addImportPath("finflow/resources/assets/qml") 
    engine.load("finflow/app/views/qml/main.qml")

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
