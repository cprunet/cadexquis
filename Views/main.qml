import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.0

import "../Tools/Tools.js" as Tools
import "mainPresenter.js" as Presenter

import ZcClient 1.0

ZcAppView
{
    id : mainView

    anchors.fill : parent

    function closeTask()
    {
        mainView.close();
    }

    toolBarActions :
        [
        Action {
            id: closeAction
            shortcut: "Ctrl+X"
            iconSource: "qrc:/ZcPostIt/Resources/close.png"
            tooltip : "Close Aplication"
            onTriggered:
            {
                mainView.closeTask();
            }
        }
    ]


    //    Loader
    //    {
    //        id : loader
    //        anchors.fill: parent

    //    //    sourceComponent: configurationGrid
    //    }



    ListModel
    {
        id : modelCE
    }


    Component.onCompleted:
    {

    }

    function modelToKey(row,column,who,when,state,fileName)
    {
        console.log(">> modeltokey " + row + " " + column + " " +  who + " " + when + " " + state + " "  + fileName)
        var key = who + "|" + when + "|" + state  + "|" + fileName;
        ceDefinition.setItem(row + "_" + column , key   );

    }

    function keyToModel(pos,key)
    {
        var index =  Tools.getIndexInListModel(modelCE, function (x) { return pos === x.pos})

        var state = "free"
        var who = ""
        var when = ""
        var fileName = ""

        console.log(">> key " + key)

        if (key !== "")
        {
            var items = key.split("|")
            console.log(">> items[0] " + items[0])
            console.log(">> items[1] " + items[1])
            console.log(">> items[2] " + items[2])
            console.log(">> items[3] " + items[3])
            who = items[0]
            when = items[1]
            state = items[2]
            fileName = items[3]
        }



        modelCE.setProperty(index, "who", who)
        modelCE.setProperty(index, "when", when)
        modelCE.setProperty(index, "fileName", fileName)

        console.log(">> ket to model  " + index + " " + state)


        modelCE.setProperty(index, "state", state)
    }



    function fillModel()
    {
        for ( var i = 0; i < 5 ; i++)
        {
            for (var j = 0 ; j < 10 ; j++)
            {
                var row = i;
                var column = j;
                var pos = i + "_" + j;
                var item = ceDefinition.getItem(pos,"");
                var state = "free"
                var who = ""
                var when = ""
                var fileName = ""

                if (item !== "")
                {
                    var items = item.split("|")
                    who = items[0]
                    when = items[1]
                    state = items[2]
                    fileName = items[3]
                }


                console.log(">> STATE " + state)

                modelCE.append({ "row" : row, "column" : column , "pos" : pos  , "state" : state , "who" : who, "fileName"  : fileName, "when" : when});
            }
        }
    }


    FileDialog
    {
        id: fileDialog

        selectFolder : false
        nameFilters: ["All Files(*.*)"]

        property Item currentItem : null


        onAccepted:
        {
           currentItem.importFile(fileDialog.fileUrl);
           currentItem = null;
        }

        onRejected:
        {
            currentItem = null;
            cancel();
        }

    }

    ScrollView
    {
        anchors.fill  : parent

        GridLayout
        {

            anchors.top: parent.top
            anchors.right: parent.right
            clip : true

            columns : 10
            rows    : 5

            columnSpacing: 0
            rowSpacing: 0

            Repeater
            {
                id 						: bodiesRepeaterId

                model : modelCE
                Rectangle
                {
                    id : delegateCadexquis

                    function onResourceProgress(query,value)
                    {
                     //   resourceViewer.progress = value;
                    }

                    function onUploadCompleted(query)
                    {
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
                        console.log(">> ON STATE CHANGED |" + state + "|")
                    }


                    states :
                        [
                        State
                        {
                            name   : "free"

                            StateChangeScript {
                                script:
                                {
                                    upload.visible = false
                                    whoAndWhen.visible = true
                                    takeForMe.visible = true
                                    background.color = "green"
                                    image.visible = false

                                }}
                        },
                        State
                        {
                            name   : "inprogress"

                            StateChangeScript {
                                script:
                                {
                                    upload.visible = true
                                    whoAndWhen.visible = true
                                    takeForMe.visible = false
                                    background.color = "red"
                                    image.visible = false

                                }}
                        }
                        ,
                                                State
                                                {
                                                    name   : "done"

                                                    StateChangeScript {
                                                        script:
                                                        {
                                                            console.log(">> state " + model.state + " " +  documentFolder.getUrl(model.fileName))
                                                            upload.visible = false
                                                            whoAndWhen.visible = false
                                                            takeForMe.visible = false
                                                            background.color = "white"
                                                            image.source = "";
                                                            image.source = documentFolder.getUrl(model.fileName);
                                                            image.visible = true
                                                        }}
                                                }

                    ]

                    state : model.state

                    clip : true
                    height: 200
                    width : 100
                    color : (column + row) % 2 == 0 ? "grey" : "lightgrey"

                    Image
                    {
                        id : image
                        cache : false
                        anchors.fill : parent
                        width : 10
                        height : 10

                        visible : false
                    }


                    Column
                    {

                        id : whoAndWhen

                        width : parent.width
                        height : parent.height

                        anchors.centerIn: parent

                        Label
                        {
                            id : who
                            text : model.who
                        }

                        Label
                        {
                            id : when
                            text : model.when
                        }
                    }



                    Button
                    {
                        id : takeForMe
                        anchors.centerIn: parent
                        width : 100
                        height: 20
                        text  : "Take for me"
                        visible : false
                        onClicked:
                        {
                            var date = new Date();
                            mainView.modelToKey(model.row,model.column,mainView.context.nickname,date,"inprogress","");
                        }
                    }


                    Button
                    {
                        id : upload
                        anchors.centerIn: parent
                        width : 100
                        height: 20
                        text  : "upload"
                        visible : false
                        onClicked:
                        {
                            fileDialog.currentItem = delegateCadexquis
                            fileDialog.open();

                        }
                    }
                }

            }

            //            cellHeight: 100
            //            cellWidth: 50

            //            contentHeight: cellHeight * 10
            //            contentWidth :cellWidth * 10
            //            height : cellWidth * 10
            //            width  : cellWidth * 10

            //            model : modelCE
            //            delegate: gridViewDelegate
        }
    }

    //    SplashScreen
    //    {
    //        id : splashScreenId
    //        width : parent.width
    //        height: parent.height
    //    }


    Component
    {
        id : zcStorageQueryStatusComponentId

        ZcStorageQueryStatus
        {

        }

    }

    Component
    {
        id : zcResourceDescriptorId
        ZcResourceDescriptor
        {
        }
    }



    ZcCrowdActivity
    {
        id : activity



        ZcCrowdSharedResource
        {
            id   : documentFolder
            name : "Cadexquis"
        }

        ZcCrowdActivityItems
        {
            ZcQueryStatus
            {
                id : ceDefinitionQueryStatus

                onCompleted :
                {
                    mainView.fillModel();
                }
            }

            id          : ceDefinition
            name        : "CEDefinition"
            persistent  : true

            onItemChanged :
            {
                mainView.keyToModel(idItem,ceDefinition.getItem(idItem,""));

                console.log(">> ONEITEMCHANGED")
                //                console.log(">> " + idItem + " " + postItDefinition.getItem(idItem,""));

                //                mainView.createPostIt(idItem)
                //                var value = postItDefinition.getItem(idItem,"");
                //                Presenter.instance[idItem].text = value;
                //                Presenter.instance[idItem].idItem = idItem;

                //                if (Presenter.instance[idItem].text === "" ||
                //                        Presenter.instance[idItem].text === null)
                //                {
                //                    var nickName = idItem.split("|");
                //                    if (nickName.length > 0 && nickName[0] === mainView.context.nickname)
                //                    {
                //                        Presenter.instance[idItem].state = "edition"
                //                    }
                //                }
            }
            onItemDeleted :
            {
                //                if (Presenter.instance[idItem] === undefined ||
                //                        Presenter.instance[idItem] === null)
                //                    return;
                //                Presenter.instance[idItem].visible = false;
                //                Presenter.instance[idItem].parent === null;
                //                Presenter.instance[idItem] = null;
            }
        }



        onStarted :
        {
            ceDefinition.loadItems(ceDefinitionQueryStatus);
        }

    }

    onLoaded :
    {
        Presenter.initPresenter()
        activity.start();
    }

    onClosed :
    {
        activity.stop();
    }

}
