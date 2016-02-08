import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import "qrc:/core/src/qml/core"
import NoteEverywhere 1.0

Item {
    // Themed ToolBar
    property alias menuButton: menuButton

    ToolBar {
        id: toolBar
        z: 2
        RowLayout {
            anchors.fill: parent
            spacing: 0

            ToolButton {
                id: menuButton
                iconSource: PathResolver.iconFromAndroidAssets("ic_menu_white_48dp.png")
            }

            ToolButton {
                action: noteListActions.refreshAction
                onClicked: NoteEverywhere.searchNotes()
            }

            Item { Layout.fillWidth: true }

            ToolButton {
                iconSource: PathResolver.iconFromAndroidAssets("ic_search_white_48dp.png")
            }
        }

        style: ToolBarStyle {
            panel: Rectangle {
                color: "#4caf50"

                DropShadow {
                    anchors.fill: parent
                    verticalOffset: 5 * NoteEverywhere.ratio
                    radius: 8.0
                    samples: 16
                    color: "#80000000"
                    source: parent
                    transparentBorder: true
                    z: -1
                }
            }
        }
    }

    MessageDialog {
        id: deleteNoteDialog
        title: "Delete note"
        text: "Do you really want to delete this note?";
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            var id = NoteEverywhere.currentNote.id
            NoteEverywhere.sqlInterface.deleteNote(id)
            NoteEverywhere.model.removeNote(listView.currentIndex)
            listView.onCurrentIndexChanged()
        }
    }

    Dialog {
        id: renameNoteDialog
        title: "Rename note"
        standardButtons: StandardButton.Yes | StandardButton.No

        onVisibleChanged: {
            if (visible) {
                editNoteNameField.text = NoteEverywhere.currentNote.name
                editNoteNameField.forceActiveFocus()
                editNoteNameField.selectAll()
            }
            else {
                Qt.inputMethod.hide()
                editNoteNameField.deselect()
            }
        }

        onYes: {
            var currentNoteId = NoteEverywhere.currentNote.id
            NoteEverywhere.sqlInterface.updateNoteName(currentNoteId, editNoteNameField.text)
            NoteEverywhere.model.setNameAt(listView.currentIndex, editNoteNameField.text)
        }

        TextField { id: editNoteNameField; width: parent.width }
    }


    NoteListActions {
        id: noteListActions
        renameAction.iconSource: ""
        deleteAction.iconSource: ""
        refreshAction.iconSource: PathResolver.iconFromAndroidAssets("ic_refresh_white_48dp.png")
        refreshAction.text: ""
    }

    Menu {
        id: noteMenu

        MenuItem {
            text: "Rename"
            action: noteListActions.renameAction
            onTriggered: renameNoteDialog.open()
        }
        MenuItem {
            text: "Delete"
            onTriggered: deleteNoteDialog.open()
        }
        CategoryMenu {
            title: NoteEverywhere.categoryAsText(NoteEverywhere.currentNote.category) + "..."
            workCategoryButton.onTriggered: NoteEverywhere.changeNoteCategory(NoteEverywhere.currentNote, Ne.WORK)
            entertainmentCategoryButton.onTriggered: NoteEverywhere.changeNoteCategory(NoteEverywhere.currentNote, Ne.ENTERTAINMENT)
            hobbyCategoryButton.onTriggered: NoteEverywhere.changeNoteCategory(NoteEverywhere.currentNote, Ne.HOBBY)
            homeCategoryButton.onTriggered: NoteEverywhere.changeNoteCategory(NoteEverywhere.currentNote, Ne.HOME)
            noneCategoryButton.onTriggered: NoteEverywhere.changeNoteCategory(NoteEverywhere.currentNote, Ne.NONE)
        }
    }


    ListView {
        id: listView
        anchors.top: toolBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        model: NoteEverywhere.model
        Component.onCompleted: NoteEverywhere.populateModel()
        delegate: NoteDelegate {
            mouseArea.onPressed: listView.currentIndex = model.index
            mouseArea.onPressAndHold: noteMenu.popup()
            mouseArea.onClicked: listView.currentIndex = model.index

        }

        onCurrentIndexChanged: NoteEverywhere.currentNote = NoteEverywhere.model.getNote(currentIndex)
    }






    // Floating button
    Rectangle {
        id: floatingRect
        width: 100 * NoteEverywhere.ratio
        height: 100 * NoteEverywhere.ratio
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 32 * NoteEverywhere.ratio
        anchors.bottomMargin: 32 * NoteEverywhere.ratio
        color: "#4caf50"
        radius: 0.5 * width

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var rowId = NoteEverywhere.sqlInterface.addNote("New Note", "", NoteEverywhere.currentCategory)
                NoteEverywhere.model.addNote(rowId, "New Note", "", NoteEverywhere.currentCategory)
                listView.positionViewAtEnd()
                listView.currentIndex = NoteEverywhere.model.size - 1
            }
        }

        Image {
            id: name
            anchors.centerIn: parent
            width: 48 * NoteEverywhere.ratio
            height: 48 * NoteEverywhere.ratio
            source: PathResolver.iconFromAndroidAssets("ic_create_white_48dp.png")
        }
    }

    DropShadow {
        anchors.fill: floatingRect
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        samples: 16
        color: "#80000000"
        source: floatingRect
        transparentBorder: true
    }
}
