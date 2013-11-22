import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.0
import "../Tools/Tools.js" as Tools

import ZcClient 1.0


Item
{

    id : uploadView
    width: 100
    height: 62

    property int row : 0
    property int column : 0
    property int index : -1

    property alias imageSourceSize : image.sourceSize


    signal cancel()

    function start()
    {
        image.scaleRectangle = 1

        state = "select"
        rectangle.x = 0
        rectangle.y = 0

        fileDialogUpload.open()
    }

    state : "select"

    states :
        [
        State
        {
            name   : "select"

            StateChangeScript {
                script:
                {
                    image.visible = true;
                    scrollCellPreview.visible = false
                }}
        },
        State
        {
            name   : "preview"

            StateChangeScript {
                script:
                {
                    image.visible = false;
                    scrollCellPreview.visible = true;
                }}
        }
    ]


    function updatePreview (name)
    {

        cellPreview.updateCellView(row,column)

       // var name = mainView.context.nickname + "_" + uploadView.row + "-" + uploadView.column + "_" + Date.now().toString() + ".png";
        cellPreview.centerImage.source = ""
        cellPreview.centerImage.source = documentFolder.getLocalUrl(name);
    }

    ScrollView
    {

        id : scrollCellPreview

        width : cellPreview.width < parent.width ? cellPreview.width : parent.width
        height : cellPreview.height < parent.height ? cellPreview.height : parent.height


        visible : false

        anchors.centerIn: parent

        CellPreview
        {
            id : cellPreview

            saveAsVisible: false
            okVisible: true

            anchors.top: parent.top
            anchors.left: parent.left

            height : currentImageHeight * 1.666
            width : currentImageWidth * 1.666
            onCancel: uploadView.state = "select"

            onOk :
            {
                importFile(cellPreview.centerImage.source)
            }
        }

    }


    function onResourceProgress(query,value)
    {
//        messageId.visible = true
//        message = ""

//        if (value === 100)
//        {
//            messageId.visible = false;
//            delegateCadexquis.message = ""
//        }
//        else
//        {
//            messageId.visible = true
//            delegateCadexquis.message = "Upload ...\n " + Math.round(value) + " %"
//        }

    }


    function onUploadCompleted(query)
    {

        query.progress.disconnect(onResourceProgress);
        query.completed.disconnect(onUploadCompleted);

        mainView.modelToKey(modelCE.get(uploadView.index).row,modelCE.get(index).column,modelCE.get(index).who,modelCE.get(index).when,"done",modelCE.get(index).fileName);

        mainView.state = "gridview"
    }


    function importFile(fileName)
    {

        var pos = row + "_" + column
        uploadView.index =  Tools.getIndexInListModel(modelCE, function (x) { return x.pos === pos})

        var query = zcStorageQueryStatusComponentId.createObject(uploadView)
        query.progress.connect(onResourceProgress);
        query.completed.connect(onUploadCompleted);

        var name = mainView.context.nickname + "_" + pos + "_" + Date.now().toString() + ".png";

        modelCE.setProperty(index, "fileName", name)

        return documentFolder.uploadFile(name,fileName,query);
    }

    Image
    {
        id : image

        width: 100
        height: 62
        anchors.fill: parent


        property double scaleRectangle : 1

        ZcImage
        {
            id      : resultImage
        }


        Rectangle
        {
            id : rectangle


            width : mainView.currentImageWidth * image.scaleRectangle
            height : mainView.currentImageHeight * image.scaleRectangle


            border.width: 1
            border.color: "red"

            color : "#00000000"


            MouseArea
            {
                id : mouseArea

                anchors.fill: parent

                drag.target     : rectangle
                drag.axis       : Drag.XAndYAxis
                drag.minimumX   : 0
                drag.minimumY   : 0
            }

            Rectangle
            {
                id : growRectangle

                x : 0
                y : 0

                color : "#00000000"
                visible : growMouseArea.drag.active ? true :  false
                width : grow.x
                height : scale * mainView.currentImageHeight

                property double scale : grow.x / mainView.currentImageWidth

                border.width : 2
                border.color : "blue"
            }


            Rectangle
            {
                id : grow

                radius : 10
                color : "#00000000"
                border.width    : 2
                border.color    : "blue"


                width           : 20
                height          : 20
                x               : rectangle.width - 10
                y               : rectangle.height / 2 - 10

                MouseArea
                {
                    id : growMouseArea

                    anchors.fill  : parent

                    drag.target     : grow
                    drag.axis       : Drag.XAxis
                    drag.minimumX   : 0
                    drag.minimumY   : 0

                    onReleased:
                    {
                        image.scaleRectangle = growRectangle.scale
                    }
                }
            }

            Column
            {
                width : 92
                height : 70

                anchors.centerIn: parent
                spacing: 5

                CxButton
                {
                    id : ok
                    width : 92
                    height: 35
                    imageSource: "qrc:/Cadexquis/Resources/ok.png"

                    onClicked:
                    {
                        resultImage.load(image.source);
                        var name = mainView.context.nickname + "_" + uploadView.row + "-" + uploadView.column +  "_" + Date.now().toString() + ".png";
                        var tmpScale = image.height /  image.sourceSize.height;
                        var copy = resultImage.copy(rectangle.x / tmpScale,
                                                    rectangle.y / tmpScale,
                                                    rectangle.width / tmpScale,
                                                    rectangle.height / tmpScale
                                                    )
                        copy.save(documentFolder.localPath + name)

                        uploadView.updatePreview(name);
                        uploadView.state = "preview"


                    }
                }

                CxButton
                {
                    id : cancel
                    width : 92
                    height: 35
                    imageSource: "qrc:/Cadexquis/Resources/cancel.png"

                    onClicked:
                    {
                        uploadView.cancel();
                    }
                }
            }
        }


        FileDialog
        {
            id: fileDialogUpload

            selectFolder : false
            nameFilters: ["All Files(*.*)"]


            onAccepted:
            {
                image.source = fileUrl
            }

            onRejected:
            {
                cancel();
            }

        }
    }

}
