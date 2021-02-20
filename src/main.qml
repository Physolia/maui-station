import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import QtQml.Models 2.3
import Qt.labs.settings 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import org.maui.station 1.0 as Station

import "widgets"

Maui.ApplicationWindow
{
    id: root
    title: currentTab && currentTab.terminal ? currentTab.terminal.session.title : ""
    altHeader: Kirigami.Settings.isMobile

    page.title: root.title
    page.showTitle: true
    
    autoHideHeader: settings.focusMode
    
    property alias currentTab : _browserList.currentItem
    readonly property Maui.Terminal currentTerminal : currentTab.terminal

    onCurrentTabChanged:
    {
        _splitButton.currentIndex = currentTab && currentTab.count > 1 ? currentTab.orientation === Qt.Vertical ? 1 : (currentTab.orientation === Qt.Horizontal ? 0 : -1) : -1
    }

    onClosing:
    {
        if(currentTab.terminal.session.hasActiveProcess)
        {
            root.notify("face-ninja", "Process is running", "Are you sure you want to quit?", root.close())
            close.accepted = false
        }
    }

    Settings
    {
        id: settings
        category: "General"
        property string colorScheme: "DarkPastels"
        property bool focusMode : false
        property bool pathBar : true
        property int lineSpacing : 0
        property font font
    }


    TutorialDialog
    {
        id: _tutorialDialog
    }

    mainMenu: [
        Action
        {
            icon.name: "settings-configure"
            text: i18n("Settings")
            onTriggered: _settingsDialog.open()
        },

        Action
        {
            text: i18n("Tutorial")
            onTriggered: _tutorialDialog.open()
        }
    ]

    Maui.Terminal
    {
        id: _dummyTerminal
    }

    Maui.SettingsDialog
    {
        id: _settingsDialog

        Maui.SettingsSection
        {
            title: i18n("Interface")
            description: i18n("Configure the application components and behaviour.")
            alt: true

            Maui.SettingTemplate
            {
                label1.text: i18n("Focus Mode")
                label2.text: i18n("Hides the main header for a distraction free console experience")

                Switch
                {

                    checkable: true
                    checked: settings.focusMode
                    onToggled: settings.focusMode = !settings.focusMode
                }
            }
        }

        Maui.SettingsSection
        {
            title: i18n("Terminal")
            description: i18n("Configure the app UI and plugins.")
            alt: false
            lastOne: true

            Maui.SettingTemplate
            {
                label1.text: i18n("Color Scheme")
                label2.text: i18n("Change the color scheme of the terminal")

                ComboBox
                {
                    id: _colorSchemesCombobox
                    model: _dummyTerminal.kterminal.availableColorSchemes
                    //                currentIndex: _dummyTerminal.kterminal.availableColorSchemes.indexOf(root.colorScheme)
                    onActivated:
                    {
                        //                    settings.setValue("colorScheme", currentValue)
                        settings.colorScheme = _colorSchemesCombobox.currentValue
                    }
                }
            }
        }

        Maui.SettingsSection
        {
            title: i18n("Fonts")
            description: i18n("Configure the terminal font family and size")

            Maui.SettingTemplate
            {
                label1.text:  i18n("Family")

                ComboBox
                {
                    Layout.fillWidth: true
                    model: Qt.fontFamilies()
                    Component.onCompleted: currentIndex = find(settings.font.family, Qt.MatchExactly)
                    onActivated: settings.font.family = currentText
                }
            }

            Maui.SettingTemplate
            {
                label1.text:  i18n("Size")

                SpinBox
                {
                    from: 0; to : 500
                    value: settings.font.pointSize
                    onValueChanged: settings.font.pointSize = value
                }
            }

            Maui.SettingTemplate
            {
                label1.text:  i18n("Line Spacing")

                SpinBox
                {
                    from: 0; to : 500
                    value: settings.tabSpace
                    onValueChanged: settings.lineSpacing = value
                }
            }
        }
    }

    headBar.leftContent: [
        ToolButton
        {
            icon.name: "tab-new"
            onClicked: root.openTab("~")
        }]

    headBar.rightContent: [
        Maui.ToolActions
        {
            id: _splitButton
            expanded: isWide
            autoExclusive: true
            display: ToolButton.IconOnly

            currentIndex: -1
            cyclic: true

            Binding on currentIndex
            {
                when :root.currentTab && root.currentTab.count === 2
                value: root.currentTab.orientation === Qt.Horizontal ? 0 : 1
                restoreMode: RestoreBindingOrValue
            }

            Action
            {
                enabled: isWide
                icon.name: "view-split-left-right"
                text: i18n("Split horizontal")
                onTriggered: root.currentTab.split(Qt.Horizontal)
                checked:  root.currentTab && root.currentTab.orientation === Qt.Horizontal && root.currentTab.count > 1
            }

            Action
            {
                icon.name: "view-split-top-bottom"
                text: i18n("Split vertical")
                onTriggered: root.currentTab.split(Qt.Vertical)
                checked:  root.currentTab && root.currentTab.orientation === Qt.Vertical && root.currentTab.count > 1
            }
        }
    ]

    Maui.PieButton
    {
        visible: Maui.Handy.isTouch
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: height
        //        radius: Maui.Style.radiusV
        z: 999

        height: Maui.Style.toolBarHeight
        icon.name: "tools"
        icon.color: Kirigami.Theme.highlightedTextColor
        alignment: Qt.AlignLeft

        Action
        {
            icon.name: "edit-copy"
            onTriggered: currentTab.terminal.kterminal.copyClipboard()
        }

        Action
        {
            icon.name: "edit-paste"
            onTriggered: currentTab.terminal.kterminal.pasteClipboard()
        }

        Action
        {
            icon.name: "edit-find"
            onTriggered: currentTab.terminal.findBar.visible = !currentTab.terminal.findBar.visible
        }
    }

    //    footBar.visible: Maui.Handy.isTouch
    footBar.leftContent: [
        ToolButton
        {
            id: _shortcutsButton
            checkable: true
            icon.name: "configure-shortcuts"
            focusPolicy: Qt.NoFocus

            onClicked: console.log(currentTerminal.session.history)
        },

        Maui.ToolActions
        {
            id: _groupsBox
            visible: _shortcutsButton.checked
            autoExclusive: true
            expanded: true
            currentIndex: 4

            Action
            {
                text: i18n("Fn")
                onTriggered: _shortcutsButton.checked = false
            }

            Action
            {
                text: i18n("Nano")
                onTriggered: _shortcutsButton.checked = false
            }

            Action
            {
                text: i18n("Ctrl")
                onTriggered: _shortcutsButton.checked = false
            }

            Action
            {
                text: i18n("Nav")
                onTriggered: _shortcutsButton.checked = false
            }

            Action
            {
                text: i18n("Fav")
                onTriggered: _shortcutsButton.checked = false
            }
        },

        ToolSeparator{},

        Repeater
        {
            model: Station.KeysModel
            {
                id: _keysModel
                group: _groupsBox.currentIndex
            }

            Button
            {
                visible: !_shortcutsButton.checked

                id: button
                text: model.label
                icon.name: model.iconName

                onClicked: _keysModel.sendKey(index, currentTerminal.kterminal)

                activeFocusOnTab: false
                //FIXME: Qt needs more sophisticated input method protocol, this mousearea is to not give the button the focus on click (closing the keyboard)
                MouseArea {
                    anchors.fill: parent
                    onClicked: button.clicked()

                }
            }
        }
    ]

    ObjectModel { id: tabsObjectModel }

    ColumnLayout
    {
        id: _layout
        anchors.fill: parent
        spacing: 0

        Maui.TabBar
        {
            id: tabsBar
            visible: _browserList.count > 1
            Layout.fillWidth: true
            Layout.preferredHeight: tabsBar.implicitHeight
            position: TabBar.Header
            currentIndex : _browserList.currentIndex
            onNewTabClicked: openTab("$HOME")
            Repeater
            {
                id: _repeater
                model: tabsObjectModel.count

                Maui.TabButton
                {
                    id: _tabButton
                    implicitHeight: tabsBar.implicitHeight
                    implicitWidth: Math.max(parent.width / _repeater.count, 120)
                    checked: index === _browserList.currentIndex

                    text: tabsObjectModel.get(index).terminal.title

                    onClicked:
                    {
                        _browserList.currentIndex = index
                    }

                    onCloseClicked: root.closeTab(index)
                }
            }
        }

        Flickable
        {
            Layout.margins: 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView
            {
                id: _browserList
                anchors.fill: parent
                clip: true
                focus: true
                orientation: ListView.Horizontal
                model: tabsObjectModel
                snapMode: ListView.SnapOneItem
                spacing: 0
                interactive: Kirigami.Settings.hasTransientTouchInput && tabsObjectModel.count > 1
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 0
                highlightResizeDuration: 0
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: 0
                preferredHighlightEnd: width
                highlight: Item {}
                highlightMoveVelocity: -1
                highlightResizeVelocity: -1

                onMovementEnded: _browserList.currentIndex = indexAt(contentX, contentY)
                boundsBehavior: Flickable.StopAtBounds

                onCurrentItemChanged:
                {
                    //                       control.currentPath =  tabsObjectModel.get(currentIndex).path
                    //                       _viewTypeGroup.currentIndex = browserView.viewType
                    currentItem.forceActiveFocus()
                }
            }
        }
    }

    Component.onCompleted:
    {
        openTab("$HOME")
    }

    function openTab(path)
    {
        const component = Qt.createComponent("TerminalLayout.qml");
        if (component.status === Component.Ready)
        {
            const object = component.createObject(tabsObjectModel, {'path': path});
            tabsObjectModel.append(object)
            _browserList.currentIndex = tabsObjectModel.count - 1
        }
    }

    function closeTab(index)
    {
        tabsObjectModel.remove(index)
    }
}
