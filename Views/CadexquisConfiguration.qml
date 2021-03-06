import QtQuick 2.0
import QtQuick.Controls 1.0
import ZcClient 1.0

ZcAppConfigurationView
{
    width: 600
    height: 480

    id : mainView

    // Labels
    Column
    {
        id                  : columnLabelId
        width               : parent.width / 4
        anchors.top         : parent.top
        anchors.topMargin   : 60
        anchors.left        : parent.left
        spacing             : 5

        Label
        {
            font.pixelSize  : 24
            height:         30
            anchors.right   : columnLabelId.right
            color           : "white"
            text            : "Width picture"
        }

        Label
        {
            font.pixelSize  : 24
            height:         30
            anchors.right   : columnLabelId.right
            color           : "white"
            text            : "Height picture"
        }

        Label
        {
            font.pixelSize  : 24
            height:         30
            anchors.right   : columnLabelId.right
            color           : "white"
            text            : "Column number"
        }

        Label
        {
            font.pixelSize  : 24
            height:         30
            anchors.right   : columnLabelId.right
            color           : "white"
            text            : "Row number"
        }

        Label
        {
            font.pixelSize  : 24
            height:         30
            anchors.right   : columnLabelId.right
            color           : "white"
            text            : "Master nickname"
        }
    }

    Button
    {
        id                  : okId

        anchors.top         : columnLabelId.top
        anchors.topMargin   : 0
        anchors.left        : columnValuesId.right
        anchors.leftMargin  : 20

        text                : "ok"

        onClicked   :
        {
            mainView.dataFormConfiguration.setFieldValue("PictureWidth",imageWidth.text);
            mainView.dataFormConfiguration.setFieldValue("PictureHeight",imageHeight.text);
            mainView.dataFormConfiguration.setFieldValue("NumberOfColumn",columnNumber.text);
            mainView.dataFormConfiguration.setFieldValue("NumberOfRow",rowNumber.text);
            mainView.dataFormConfiguration.setFieldValue("MasterNickname",masterNickname.text);
            mainView.ok();
        }

    }

    // Edits
    Column
    {
        id                  : columnValuesId
        anchors.top         : columnLabelId.top
        anchors.left        : columnLabelId.right
        anchors.leftMargin  : 10
        width               : 240
        spacing             : 5


        TextField
        {
            id                  : imageWidth

            height:         30
            font.pixelSize  : 24
            width : 100
            anchors.right       : parent.right
            anchors.left        : parent.left
            focus            : true
        }

        TextField
        {
            id                  : imageHeight

            height:         30
            font.pixelSize  : 24
            anchors.right       : parent.right
            anchors.left        : parent.left
            focus            : true
        }

        TextField
        {
            id                  : rowNumber

            height:         30
            font.pixelSize  : 24
            anchors.right       : parent.right
            anchors.left        : parent.left
            focus            : true
        }

        TextField
        {
            id                  : columnNumber

            height:         30
            font.pixelSize  : 24
            anchors.right       : parent.right
            anchors.left        : parent.left
            focus            : true
        }

        TextField
        {
            id                  : masterNickname

            height:         30
            font.pixelSize  : 24
            anchors.right       : parent.right
            anchors.left        : parent.left
            focus            : true
        }

    }

    onLoaded :
    {
        imageWidth.text = mainView.dataFormConfiguration.getFieldValue("PictureWidth","")
        imageHeight.text = mainView.dataFormConfiguration.getFieldValue("PictureHeight","")
        columnNumber.text = mainView.dataFormConfiguration.getFieldValue("NumberOfColumn","")
        rowNumber.text = mainView.dataFormConfiguration.getFieldValue("NumberOfRow","")
        masterNickname.text = mainView.dataFormConfiguration.getFieldValue("MasterNickname","")
    }
}
