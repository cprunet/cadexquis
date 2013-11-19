import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.0

import "../Tools/Tools.js" as Tools

import ZcClient 1.0

Item
{
    id : mainGridView

    clip : true
    width : 100
    height : 100

    property alias model : gridView.model

    signal showDetailProgressView(int row, int column);

    GridView
    {
        id : gridView

        anchors.fill: parent


        cellHeight: currentImageHeight
        cellWidth: currentImageWidth


        delegate : delegateId

        Component
        {
            id : delegateId
            Rectangle
            {
                id : delegateCadexquis

                function onResourceProgress(query,value)
                {
                    messageId.visible = true
                    message = ""

                    if (value === 100)
                    {
                        messageId.visible = false;
                        delegateCadexquis.message = ""
                    }
                    else
                    {
                        messageId.visible = true
                        delegateCadexquis.message = "Upload ...\n " + Math.round(value) + " %"
                    }

                }


                function onUploadCompleted(query)
                {
                    messageId.visible = false
                    delegateCadexquis.message.message = ""

                    query.progress.disconnect(onResourceProgress);
                    query.completed.disconnect(onUploadCompleted);

                    modelToKey(model.row,model.column,model.who,model.when,"done",model.fileName);
                }

                function importFile(fileName)
                {

                    var index =  Tools.getIndexInListModel(modelCE, function (x) { return model.pos === x.pos})

                    var query = zcStorageQueryStatusComponentId.createObject(mainView)
                    query.progress.connect(onResourceProgress);
                    query.completed.connect(onUploadCompleted);

                    var name = mainView.context.nickname + "_" + model.pos + ".png";

                    modelCE.setProperty(index, "fileName", name)

                    return documentFolder.uploadFile(name,fileName,query);
                }


                Rectangle
                {
                    id : background
                    anchors.fill: parent
                    opacity : 0.5
                }

                onStateChanged:
                {
                }


                states :
                    [
                    State
                    {
                        name   : "free"

                        StateChangeScript {
                            script:
                            {
                                background.color = "lightGreen"
                                //image.visible = false
                                //whoLabel.text = ""
                                //whenLabel.text = ""
                            }}
                    },
                    State
                    {
                        name   : "inprogress"

                        StateChangeScript {
                            script:
                            {
                                background.color = "#c80216"
                                //image.visible = false
//                                whoLabel.text = who
//                                var whenSplit = when.split("/")
//                                whenLabel.text = whenSplit[0] + "/" + whenSplit[1] + "/" + whenSplit[2]
                            }}
                    }
                    ,
                    State
                    {
                        name   : "done"

                        StateChangeScript {
                            script:
                            {
                                background.color = "#00000000"
                                image.source = "";
                                image.source = documentFolder.getUrl(model.fileName);
                            }}
                    }

                ]

                state : model.state

                clip : true
                height:  mainView.currentImageHeight
                width :  mainView.currentImageWidth

                color : (column + row) % 2 == 0 ? "grey" : "lightgrey"

                property alias message : messageTextId.text

                Image
                {
                    id : image
                    cache : false
                    anchors.fill : parent
                    width : 10
                    height : 10

                    visible : mainView.isFinished

                    onStatusChanged:
                    {
                        if (status != Image.Error )
                        {
                            message = Math.round(image.progress * 100)
                        }
                        else
                        {
                            message = "Error"
                        }
                    }

                    onProgressChanged:
                    {                   
                        if (image.progress !== 1)
                        {
                            messageId.visible = true
                        }
                        else
                        {
                            messageId.visible = false
                        }
                    }
                }


                Column
                {

                    id : whoAndWhen

                    width : parent.width
                    height : parent.height

                    anchors.top: parent.top

                    visible: !mainView.isFinished

                    spacing: 5

                    Label
                    {
                        id : whoLabel
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        height : 25
                        text : model.who
                    }

                    Label
                    {
                        id : whenLabel
                        anchors.right: parent.right
                        anchors.left: parent.left
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        height : 25
                        text : model.when
                        anchors.horizontalCenter: parent.horizontalCenter
                    }



                    CxButton
                    {
                        id : takeForMe
                        visible : delegateCadexquis.state === "free" && mainView.iAmFree

                        width : 92
                        height: 35
                        anchors.horizontalCenter: parent.horizontalCenter

                        imageSource: "qrc:/Cadexquis/Resources/itakeit.png"

                        onClicked:
                        {
                            var indexUp = -1
                            var indexDown = -1
                            var indexLeft = -1
                            var indexRight = -1

                            var posUp = (model.row - 1)  + "_" + model.column;
                            var posDown = (model.row + 1) + "_" + model.column;
                            var posLeft = model.row  + "_" + (model.column - 1);
                            var posRight = model.row  + "_" + (model.column + 1);

                            var up = Tools.findInListModel( modelCE , function (x) { return x.pos === posUp});
                            var down = Tools.findInListModel( modelCE , function (x) { return x.pos === posDown});
                            var left = Tools.findInListModel( modelCE , function (x) { return x.pos === posLeft});
                            var right = Tools.findInListModel( modelCE , function (x) { return x.pos === posRight});

                            if ( up !== null && up.state === "inprogress")
                            {
                                return;
                            }

                            if ( down !== null && down.state === "inprogress")
                            {
                                return;
                            }

                            if ( left !== null && left.state === "inprogress")
                            {
                                return;
                            }

                            if ( right !== null && right.state === "inprogress")
                            {
                                return;
                            }

                            var date = new Date();
                            mainView.modelToKey(model.row,model.column,mainView.context.nickname,date.getDate() + "/" + date.getMonth() + "/" + date.getUTCFullYear(),"inprogress","");
                        }
                    }

                    CxButton
                    {
                        id : upload
                        width : 92
                        height: 35
                        imageSource: "qrc:/Cadexquis/Resources/upload.png"
                        anchors.horizontalCenter: parent.horizontalCenter

                        visible : delegateCadexquis.state === "inprogress" && model.who === mainView.context.nickname

                        onClicked:
                        {
                            fileDialog.currentItem = delegateCadexquis
                            fileDialog.open();

                        }
                    }

                    CxButton
                    {
                        id : view
                        width : 92
                        height: 35
                        imageSource: "qrc:/Cadexquis/Resources/view.png"
                        anchors.horizontalCenter: parent.horizontalCenter

                        visible : delegateCadexquis.state === "inprogress" && model.who === mainView.context.nickname

                        onClicked:
                        {
                            mainGridView.showDetailProgressView(model.row,model.column);

                        }
                    }


                    CxButton
                    {
                        id : release
                        width : 92
                        height: 35
                        imageSource: "qrc:/Cadexquis/Resources/release.png"
                        anchors.horizontalCenter: parent.horizontalCenter

                        visible : delegateCadexquis.state !== "free" && mainView.iAmTheMaster

                        onClicked:
                        {
                            mainView.modelToKey(model.row,model.column,"","","free","")
                        }
                    }
                }


                Rectangle
                {

                    id    : messageId
                    color : "lightGrey"
                    anchors.fill: parent

                    visible : false

                    Text
                    {
                        id : messageTextId
                        anchors.centerIn : parent
                        color : "white"
                        font.pixelSize:   20
                    }

                }


            }

        }
    }
}
