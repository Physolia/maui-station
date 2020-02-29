import QtQuick 2.9
import QtQuick.Controls 2.13
import org.kde.mauikit 1.0 as Maui

import org.kde.kirigami 2.4 as Kirigami

Maui.Terminal
{
    id: control
    property string path
    property int index
    property int orientation : _splitView.orientation

    function forceActiveFocus()
    {
        control.kterminal.forceActiveFocus()
    }

//   Component.onCompleted:
//   {
//       control.session.intialWorkingDirectory = control.path
//   }

   onClicked:
   {
       _splitView.currentIndex = control.index

   }

   SplitView.fillHeight: true
   SplitView.fillWidth: true
   SplitView.preferredHeight: _splitView.orientation === Qt.Vertical ? _splitView.height / (_splitView.count) :  _splitView.height
   SplitView.minimumHeight: _splitView.orientation === Qt.Vertical ?  200 : 0


   SplitView.preferredWidth: _splitView.orientation === Qt.Horizontal ? _splitView.width / (_splitView.count) : _splitView.width
   SplitView.minimumWidth: _splitView.orientation === Qt.Horizontal ? 300 :  0


    kterminal.colorScheme: "DarkPastels"
    onKeyPressed:
    {
        if ((event.key == Qt.Key_V) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
        {
            kterminal.pasteClipboard()
        }

        if ((event.key == Qt.Key_C) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
        {
            kterminal.copyClipboard()
        }

        if ((event.key == Qt.Key_F) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
        {
            footBar.visible = !footBar.visible
        }
    }
}
