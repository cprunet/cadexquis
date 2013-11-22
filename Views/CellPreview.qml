import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.0
import "../Tools/Tools.js" as Tools

import ZcClient 1.0

Rectangle
{
    id : viewId

    signal cancel()
    signal ok()


    property alias saveAsVisible :  saveAs.visible
    property alias okVisible :  ok.visible

    property alias centerImage : centerImageId
    property alias downImage : downId
    property alias upImage : upId
    property alias leftImage : leftId
    property alias rightImage : rightId

    function updateCellView(row , column)
    {
        var posUp = (row - 1)  + "_" + column;
        var posDown = (row + 1) + "_" + column;
        var posLeft = row  + "_" + (column - 1);
        var posRight = row  + "_" + (column + 1);
        var posCenter = row  + "_" + column;

        var up = Tools.findInListModel( modelCE , function (x) { return x.pos === posUp});
        var down = Tools.findInListModel( modelCE , function (x) { return x.pos === posDown});
        var left = Tools.findInListModel( modelCE , function (x) { return x.pos === posLeft});
        var right = Tools.findInListModel( modelCE , function (x) { return x.pos === posRight});
        var center = Tools.findInListModel( modelCE , function (x) { return x.pos === posCenter});

        centerImage.source = ""
        upImage.source = ""
        downImage.source = ""
        leftImage.source = ""
        rightImage.source = ""

        if ( center !== null )
        {
            centerImage.source = documentFolder.getUrl(center.fileName);
        }

        if ( up !== null )
        {
            upImage.source = documentFolder.getUrl(up.fileName);
        }

        if ( down !== null)
        {
            downImage.source = documentFolder.getUrl(down.fileName);
        }

        if ( left !== null)
        {
            leftImage.source = documentFolder.getUrl(left.fileName);
        }

        if ( right !== null)
        {
            rightImage.source = documentFolder.getUrl(right.fileName);
        }
    }

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
                id : saveAs

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
                id : ok

                width : 92
                height: 35


                imageSource: "qrc:/Cadexquis/Resources/ok.png"

                onClicked:
                {
                    viewId.ok();
                }
            }


            CxButton
            {
                width : 92
                height: 35


                imageSource: "qrc:/Cadexquis/Resources/back.png"

                onClicked:
                {
                    viewId.cancel();
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
        cache : false
    }

    Image
    {
        id : upId
        anchors.bottom: center.top
        anchors.left: center.left
        width : currentImageWidth
        cache : false
        height : currentImageHeight            }


    Image
    {
        id : leftId
        anchors.bottom: center.bottom
        anchors.right: center.left
        width : currentImageWidth
        height : currentImageHeight
        cache : false
    }

    Image
    {
        id : rightId
        anchors.bottom: center.bottom
        anchors.left: center.right
        width : currentImageWidth
        height : currentImageHeight
        cache : false
    }
}
