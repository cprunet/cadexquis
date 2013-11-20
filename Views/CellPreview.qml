import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.0

import ZcClient 1.0

Rectangle
{
    id : viewId

    FileDialog
    {
        id: fileDialogPreview

        selectFolder : false
        nameFilters: ["All Files(*.png)"]

        onAccepted:
        {
            var val3 =  mainView.mapToItem(null,detailProgressView.x,detailProgressView.y)
            mainView.grabWindow(fileDialogPreview.fileUrl,val3.x,val3.y,detailProgressView.width,detailProgressView.height);
        }

        onRejected:
        {
            cancel();
        }

        title : "Save image as ..."

    }

    color : "lightGray"
    clip : true

    property alias centerImage : centerImageId
    property alias downImage : downId
    property alias upImage : upId
    property alias leftImage : leftId
    property alias rightImage : rightId

    Rectangle
    {
        id : center
        color : "white"
        anchors.centerIn: parent
        height : currentImageHeight
        width : currentImageWidth

        border.color: "black"
        border.width: 1

        Image
        {
            id : centerImageId
            anchors.fill: center
        }

        Column
        {

            width : 92
            height : 70

            anchors.centerIn: parent

            spacing: 5

            CxButton
            {
                width : 92
                height: 35


                imageSource: "qrc:/Cadexquis/Resources/saveas.png"

                onClicked:
                {
                    //       mainView.state = "gridview"
                    fileDialogPreview.open()
                }
            }

            CxButton
            {
                width : 92
                height: 35


                imageSource: "qrc:/Cadexquis/Resources/back.png"

                onClicked:
                {
                    mainView.state = "gridview"
                }
            }
        }
    }



    Image
    {
        id : downId
        anchors.top: center.bottom
        anchors.left: center.left
        width : currentImageWidth
        height : currentImageHeight
    }

    Image
    {
        id : upId
        anchors.bottom: center.top
        anchors.left: center.left
        width : currentImageWidth
        height : currentImageHeight            }


    Image
    {
        id : leftId
        anchors.bottom: center.bottom
        anchors.right: center.left
        width : currentImageWidth
        height : currentImageHeight
    }

    Image
    {
        id : rightId
        anchors.bottom: center.bottom
        anchors.left: center.right
        width : currentImageWidth
        height : currentImageHeight
    }
}
