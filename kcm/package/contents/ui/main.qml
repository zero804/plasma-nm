/*
    Copyright 2016-2018 Jan Grulich <jgrulich@redhat.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import "editor"

import QtQuick 2.6
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as QtControls

import org.kde.kcm 1.2
import org.kde.kirigami 2.3  as Kirigami // for Kirigami.Units
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

ScrollViewKCM {
    id: root

    ConfigModule.quickHelp: i18n("Connections")

    title: i18n("Edit your Network Connections")

    property bool currentConnectionExportable: false
    property string currentConnectionName
    property string currentConnectionPath

    property QtObject connectionSettingsObject: kcm.connectionSettings

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    SystemPalette {
        id: palette
        colorGroup: SystemPalette.Active
    }

    PlasmaNM.Handler {
        id: handler
    }

    PlasmaNM.KcmIdentityModel {
        id: connectionModel
    }

    PlasmaNM.EditorProxyModel {
        id: editorProxyModel

        sourceModel: connectionModel
    }

    header: Rectangle {
        color: Kirigami.Theme.backgroundColor

        width: root.width
        height: Math.round(Kirigami.Units.gridUnit * 2.5)

        RowLayout {
            id: searchLayout

            spacing: Kirigami.Units.smallSpacing
            anchors {
                fill: parent
                margins: Kirigami.Units.smallSpacing
            }

            QtControls.TextField {
                id: searchField

                Layout.minimumHeight: Layout.maximumHeight
                Layout.maximumHeight: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2
                Layout.fillWidth: true

                focus: true
                placeholderText: i18n("Type here to search connection...")

                onTextChanged: {
                    editorProxyModel.setFilterRegExp(text)
                }

                MouseArea {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: y
                    }

                    opacity: searchField.text.length > 0 ? 1 : 0
                    width: Kirigami.Units.iconSizes.small
                    height: width

                    onClicked: {
                        searchField.text = ""
                    }

                    Kirigami.Icon {
                        anchors.fill: parent
                        source: LayoutMirroring.enabled ? "edit-clear-rtl" : "edit-clear"
                    }

                    Behavior on opacity {
                        OpacityAnimator {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }

        Kirigami.Separator {
            visible: !connectionView.atYBeginning
            anchors {
                left: parent.left
                right: parent.right
                top: parent.bottom
            }
        }
    }

    view: ListView {
        id: connectionView
        clip: true
        model: editorProxyModel
        currentIndex: -1
        boundsBehavior: Flickable.StopAtBounds
        activeFocusOnTab: true
        keyNavigationWraps: true
        Accessible.role: Accessible.List
        Keys.onTabPressed: {
            if (applicationWindow().wideScreen && root.pageStack.depth > 1) {
                connectionEditor.focus = true;
            }
        }

        section {
            property: "KcmConnectionType"
            delegate: Kirigami.AbstractListItem {
                supportsMouseEvents: false
                background: Rectangle {
                    color: palette.window
                }
                QtControls.Label {
                    id: headerLabel
                    anchors.centerIn: parent
                    font.weight: Font.DemiBold
                    text: section
                }
            }
        }

        delegate: ConnectionItemDelegate {
            onAboutToChangeConnection: {
//                         // Shouldn't be problem to set this in advance
//                         root.currentConnectionExportable = exportable
//                         if (kcm.needsSave) {
//                             confirmSaveDialog.connectionName = name
//                             confirmSaveDialog.connectionPath = path
//                             confirmSaveDialog.open()
//                         } else {
                    root.currentConnectionName = name
                    root.currentConnectionPath = path

//                         }
            }

            onAboutToExportConnection: {
                requestExportConnection(path)
            }

            onAboutToRemoveConnection: {
                deleteConfirmationDialog.connectionName = name
                deleteConfirmationDialog.connectionPath = path
                deleteConfirmationDialog.open()
            }
        }
    }

    footer: Row {
        layoutDirection: Qt.RightToLeft
        spacing: Kirigami.Units.smallSpacing
        padding: Kirigami.Units.smallSpacing

        QtControls.Button {
            id: exportConnectionButton

            height: Kirigami.Units.iconSizes.medium
            width: Kirigami.Units.iconSizes.medium

            enabled: root.currentConnectionExportable
            icon.name: "document-export"

            QtControls.ToolTip.text: i18n("Export selected connection")
            QtControls.ToolTip.visible: exportConnectionButton.hovered

            onClicked: {
                kcm.requestExportConnection(root.currentConnectionPath)
            }
        }

        QtControls.Button {
            id: removeConnectionButton

            height: Kirigami.Units.iconSizes.medium
            width: Kirigami.Units.iconSizes.medium

            enabled: root.currentConnectionPath && root.currentConnectionPath.length
            icon.name: "list-remove"

            QtControls.ToolTip.text: i18n("Remove selected connection")
            QtControls.ToolTip.visible: removeConnectionButton.hovered

            onClicked: {
                deleteConfirmationDialog.connectionName = root.currentConnectionName
                deleteConfirmationDialog.connectionPath = root.currentConnectionPath
                deleteConfirmationDialog.open()
            }
        }

        QtControls.Button {
            id: addConnectionButton

            width: Kirigami.Units.iconSizes.medium
            height: Kirigami.Units.iconSizes.medium

            icon.name: "list-add"

            QtControls.ToolTip.text: i18n("Add new connection")
            QtControls.ToolTip.visible: addConnectionButton.hovered

            onClicked: {
                addNewConnectionDialog.open()
            }
        }
    }

    ConnectionEditor {
        id: connectionEditor
        opacity: applicationWindow().pageStack.currentIndex == 1
    }

    MessageDialog {
        id: deleteConfirmationDialog

        property string connectionName
        property string connectionPath

        icon: StandardIcon.Question
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        title: i18nc("@title:window", "Remove Connection")
        text: i18n("Do you want to remove the connection '%1'?", connectionName)

        onAccepted: {
            if (connectionPath == connectionView.currentConnectionPath) {
                // Deselect now non-existing connection
                deselectConnectionsInView()
            }
            handler.removeConnection(connectionPath)
        }
    }

    MessageDialog {
        id: confirmSaveDialog

        property string connectionName
        property string connectionPath

        icon: StandardIcon.Question
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        title: i18nc("@title:window", "Save Connection")
        text: i18n("Do you want to save changes made to the connection '%1'?", connectionView.currentConnectionName)

        onAccepted: {
            kcm.save()

            selectConnectionInView(connectionName, connectionPath)
        }
    }

    AddConnectionDialog {
        id: addNewConnectionDialog

        onRequestCreateConnection: {
            kcm.requestCreateConnection(type, vpnType, specificType, shared)
        }
    }

    onCurrentConnectionPathChanged: {
        if (currentConnectionPath) {
            if (applicationWindow().pageStack.depth < 2) {
                applicationWindow().pageStack.push(connectionEditor)
            } else {
                applicationWindow().pageStack.currentIndex = 1
            }
            kcm.selectConnection(root.currentConnectionPath)
        }
    }

    function loadConnectionSetting() {
        connectionEditor.loadConnectionSettings()
    }

    function deselectConnectionsInView() {
        connectionView.currentConnectionPath = ""
    }

    function selectConnectionInView(connectionName, connectionPath) {
        connectionView.currentConnectionName = connectionName
        connectionView.currentConnectionPath = connectionPath
    }
}