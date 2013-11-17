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

    ZcPrimaryScreen
    {
        id : primaryScreen
    }


    ListModel
    {
        id : modelCE
    }


    Component.onCompleted:
    {

    }

    function modelToKey(row,column,who,when,state,fileName)
    {
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

        if (key !== "")
        {
            var items = key.split("|")
            who = items[0]
            when = items[1]
            state = items[2]
            fileName = items[3]
        }

        // je calcul mon état
        if (mainView.iAmFree && who === mainView.context.nickname)
        {
            mainView.iAmFree = false;
            mainView.myBusyPosition = pos;
        }
        else if (mainView.myBusyPosition === pos && state === "free")
        {
            mainView.iAmFree = true;
            mainView.myBusyPosition = "";
        }
        else if (mainView.myBusyPosition === pos && state === "done")
        {
            mainView.iAmFree = true;
            mainView.myBusyPosition = "";
        }


        console.log(">> KETTOMODEL " + who)
        modelCE.setProperty(index, "who", who)
        modelCE.setProperty(index, "when", when)
        modelCE.setProperty(index, "fileName", fileName)
        modelCE.setProperty(index, "state", state)
    }



    function fillModel()
    {
        for ( var i = 0; i < mainView.nbrRow ; i++)
        {
            for (var j = 0 ; j < mainView.nbrColum ; j++)
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

                if (mainView.iAmFree && who === mainView.context.nickname)
                {
                    mainView.iAmFree = false;
                    mainView.myBusyPosition = pos;
                }

                modelCE.append({ "row" : row, "column" : column , "pos" : pos  , "state" : state , "who" : who, "fileName"  : fileName, "when" : when});
            }
        }
    }


    SplashScreen
    {
        id : splashScreenId
        width : parent.width
        height: parent.height
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


    Label
    {
        Rectangle
        {
            color : "black"
            opacity : 0.5
            anchors.fill: parent
        }

        id : sliderValue
        width : 40
        height: 20
        clip : true

        color : "white"

        font.pixelSize: 14
        horizontalAlignment: Text.AlignHCenter

        text : (slider.value * 100) + " %"
    }

    Slider
    {
        id              : slider
        anchors.top     : sliderValue.bottom
        anchors.bottom  : parent.bottom
        anchors.left    : parent.left

        width : 40
        value : 0.5

        maximumValue: 2.0
        minimumValue: 0.1
        stepSize: 0.1

        orientation : Qt.Vertical
    }


    property int nbrColum : 10
    property int nbrRow : 5

    property string masterNickname : "???"

    property double realImageWidth : 5
    property double realImageHeight : 10

    property double currentImageWidth : primaryScreen.physicalDotsPerCmX(realImageWidth) * slider.value
    property double currentImageHeight : primaryScreen.physicalDotsPerCmY(realImageHeight) * slider.value

    property bool iAmFree : true
    property bool iAmTheMaster : false
    property string myBusyPosition : ""


    ScrollView
    {
        anchors.top : parent.top
        anchors.bottom : parent.bottom
        anchors.right : parent.right
        anchors.left : slider.right

        Item
        {

            anchors.top: parent.top
            anchors.right: parent.right
            clip : true
            width : mainView.nbrColum * currentImageWidth
            height : mainView.nbrRow * currentImageHeight

            GridView
            {
                anchors.fill: parent

                model : modelCE

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
                        }


                        states :
                            [
                            State
                            {
                                name   : "free"

                                StateChangeScript {
                                    script:
                                    {
                                        whoAndWhen.visible = true
                                        background.color = "lightGreen"
                                        image.visible = false
                                        whoLabel.text = ""
                                        whenLabel.text = ""
                                    }}
                            },
                            State
                            {
                                name   : "inprogress"

                                StateChangeScript {
                                    script:
                                    {
                                        whoAndWhen.visible = true
                                        background.color = "#c80216"
                                        image.visible = false
                                        console.log(">> WHO " + who)
                                        whoLabel.text = who
                                        var whenSplit = when.split("/")
                                        whenLabel.text = whenSplit[0] + "/" + whenSplit[1] + "/" + whenSplit[2]
                                    }}
                            }
                            ,
                            State
                            {
                                name   : "done"

                                StateChangeScript {
                                    script:
                                    {
                                        whoAndWhen.visible = false
                                        background.color = "#00000000"
                                        image.source = "";
                                        image.source = documentFolder.getUrl(model.fileName);
                                        image.visible = true
                                    }}
                            }

                        ]

                        state : model.state

                        clip : true
                        height:  mainView.currentImageHeight
                        width :  mainView.currentImageWidth

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
                                id : whoLabel
                                anchors.right: parent.right
                                anchors.left: parent.left
                                font.pixelSize: 20
                                horizontalAlignment: Text.AlignHCenter
                                height : 25
                            }

                            Label
                            {
                                id : whenLabel
                                anchors.right: parent.right
                                anchors.left: parent.left
                                font.pixelSize: 20
                                horizontalAlignment: Text.AlignHCenter
                                height : 25
                            }
                        }



                        CxButton
                        {
                            id : takeForMe
                            anchors.centerIn: parent
                            width : 92
                            height: 35
                            visible : delegateCadexquis.state === "free" && mainView.iAmFree

                            imageSource: "qrc:/Cadexquis/Resources/itakeit.png"

                            onClicked:
                            {
                                var date = new Date();
                                mainView.modelToKey(model.row,model.column,mainView.context.nickname,date.getDate() + "/" + date.getMonth() + "/" + date.getUTCFullYear(),"inprogress","");
                            }
                        }


                        Column
                        {
                            id : uploadRelease

                            width : 92
                            height: 75

                            anchors.centerIn: parent

                            visible : delegateCadexquis.state === "inprogress" && model.who === mainView.context.nickname


                            spacing: 5

                            CxButton
                            {
                                id : upload
                                width : parent.width
                                height: 35
                                imageSource: "qrc:/Cadexquis/Resources/upload.png"


                                onClicked:
                                {
                                    fileDialog.currentItem = delegateCadexquis
                                    fileDialog.open();

                                }
                            }

                            CxButton
                            {
                                id : release
                                width : parent.width
                                height: 35
                                imageSource: "qrc:/Cadexquis/Resources/release.png"


                                onClicked:
                                {
                                    mainView.modelToKey(model.row,model.column,"","","free","")
                                }
                            }
                        }
                    }

                }
            }
        }
    }


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
                    splashScreenId.height = 0;
                    splashScreenId.width = 0;
                    splashScreenId.visible = false;

                    mainView.fillModel();
                }
            }

            id          : ceDefinition
            name        : "CEDefinition"
            persistent  : true

            onItemChanged :
            {
                mainView.keyToModel(idItem,ceDefinition.getItem(idItem,""));

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
            mainView.nbrColum = parseInt(mainView.context.applicationConfiguration.getProperty("NumberOfColumn","2"));
            mainView.nbrRow = parseInt(mainView.context.applicationConfiguration.getProperty("NumberOfRow","2"));
            mainView.realImageWidth = parseFloat(mainView.context.applicationConfiguration.getProperty("PictureWidth","2"));
            mainView.realImageHeight = parseFloat(mainView.context.applicationConfiguration.getProperty("PictureHeight","2"));
            mainView.masterNickname = mainView.context.applicationConfiguration.getProperty("PictureHeight","???");


            if (mainView.masterNickname === mainView.context.nickname)
            {
                mainView.iAmTheMaster = true
            }

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
