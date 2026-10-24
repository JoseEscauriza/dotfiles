import QtQuick 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    anchors.fill: parent
    color: "black"

    /* ---------------- Palette / shared settings ---------------- */

    readonly property string fontFamily: "JetBrainsMono Nerd Font Mono"
    readonly property color cBg:     "#282828"
    readonly property color cBorder: "#504945"
    readonly property color cText:   "#ebdbb2"
    readonly property color cMuted:  "#a89984"
    readonly property color cAccent: "#d79921"
    readonly property color cError:  "#fb4934"

    /* ---------------- Session state ---------------- */

    // sddm.login() expects the session *index* in sessionModel as 3rd arg.
    // lastIndex = the session used on the previous login (SDDM remembers it).
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property string sessionName: ""
    property bool sessionMenuOpen: false

    // Hidden repeater: resolves the display name of the current index
    Repeater {
        model: sessionModel
        delegate: Item {
            Component.onCompleted: {
                if (index === root.sessionIndex)
                    root.sessionName = model.name
            }
        }
    }

    /* ---------------- Background ---------------- */

    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }

    /* ---------------- Center Content ---------------- */

    Column {
        id: centerColumn
        anchors.centerIn: parent
        spacing: 28
        width: 360

        Text {
            text: "Welcome"
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: root.fontFamily
            font.pixelSize: 42
            font.bold: true
            color: root.cText
        }

        Rectangle {
            width: parent.width
            height: 46
            radius: 6
            color: root.cBg
            border.color: errorText.visible ? root.cError : root.cBorder
            border.width: 1

            PasswordBox {
                id: passwordBox
                anchors.fill: parent
                anchors.margins: 10
                focus: true

                Keys.onReturnPressed: root.login()
                Keys.onEnterPressed: root.login()
            }
        }

        Text {
            id: errorText
            visible: false
            text: "Login failed, try again"
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: root.fontFamily
            font.pixelSize: 14
            color: root.cError
        }
    }

    function login() {
        errorText.visible = false
        sddm.login("jose", passwordBox.text, root.sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorText.visible = true
            passwordBox.text = ""
            passwordBox.forceActiveFocus()
        }
    }

    /* ---------------- Top Bar ---------------- */

    Item {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 40
        height: 40
        z: 100

        // ---- Session dropdown (left) ----
        Rectangle {
            id: sessionButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 220
            height: 36
            radius: 6
            color: root.cBg
            border.color: (root.sessionMenuOpen || sessionMouse.containsMouse) ? root.cAccent : root.cBorder
            border.width: 1

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: arrow.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: root.sessionName
                elide: Text.ElideRight
                font.family: root.fontFamily
                font.pixelSize: 14
                color: root.cText
            }

            Text {
                id: arrow
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: root.sessionMenuOpen ? "\uf0d8" : "\uf0d7"   // nerd font chevrons
                font.family: root.fontFamily
                font.pixelSize: 14
                color: root.cMuted
            }

            MouseArea {
                id: sessionMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.sessionMenuOpen = !root.sessionMenuOpen
            }

            // ---- Dropdown list ----
            Rectangle {
                id: sessionMenu
                visible: root.sessionMenuOpen
                anchors.top: parent.bottom
                anchors.topMargin: 6
                anchors.left: parent.left
                width: parent.width
                height: menuColumn.height + 8
                radius: 6
                color: root.cBg
                border.color: root.cBorder
                border.width: 1

                Column {
                    id: menuColumn
                    anchors.top: parent.top
                    anchors.topMargin: 4
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 4
                    spacing: 2

                    Repeater {
                        model: sessionModel
                        delegate: Rectangle {
                            width: menuColumn.width
                            height: 32
                            radius: 4
                            color: itemMouse.containsMouse ? root.cBorder : "transparent"

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.right: check.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: model.name
                                elide: Text.ElideRight
                                font.family: root.fontFamily
                                font.pixelSize: 14
                                color: index === root.sessionIndex ? root.cAccent : root.cText
                            }

                            Text {
                                id: check
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                visible: index === root.sessionIndex
                                text: "\uf00c"
                                font.family: root.fontFamily
                                font.pixelSize: 12
                                color: root.cAccent
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.sessionIndex = index
                                    root.sessionName = model.name
                                    root.sessionMenuOpen = false
                                    passwordBox.forceActiveFocus()
                                }
                            }
                        }
                    }
                }
            }
        }

        // ---- Hostname + clock (right) ----
        Column {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                id: clockText
                anchors.right: parent.right
                font.family: root.fontFamily
                font.pixelSize: 20
                font.bold: true
                color: root.cText
            }

            Text {
                id: dateText
                anchors.right: parent.right
                font.family: root.fontFamily
                font.pixelSize: 12
                color: root.cMuted
            }
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                var d = new Date()
                clockText.text = Qt.formatTime(d, "HH:mm")
                dateText.text = sddm.hostName + "  \u00b7  " + Qt.formatDate(d, "ddd, d MMM yyyy")
            }
        }
    }

    // Click-away area to close the dropdown (sits below the top bar, above content)
    MouseArea {
        anchors.fill: parent
        enabled: root.sessionMenuOpen
        z: 50
        onClicked: {
            root.sessionMenuOpen = false
            passwordBox.forceActiveFocus()
        }
    }

    /* ---------------- Power Controls ---------------- */

    Row {
        id: powerRow
        spacing: 32

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 40
        anchors.bottomMargin: 40

        // Shutdown
        Rectangle {
            width: 32
            height: 32
            color: "transparent"

            Image {
                id: shutdownIcon
                anchors.centerIn: parent
                width: 26
                height: 26
                source: "images/shutdown.svg"
                fillMode: Image.PreserveAspectFit
                opacity: shutdownMouse.containsMouse ? 0.7 : 1.0
            }

            MouseArea {
                id: shutdownMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff()
            }
        }

        // Restart
        Rectangle {
            width: 32
            height: 32
            color: "transparent"

            Image {
                id: restartIcon
                anchors.centerIn: parent
                width: 26
                height: 26
                source: "images/restart.svg"
                fillMode: Image.PreserveAspectFit
                opacity: restartMouse.containsMouse ? 0.7 : 1.0
            }

            MouseArea {
                id: restartMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.reboot()
            }
        }
    }
}
