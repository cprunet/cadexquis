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

    state : "gridview"

    states :
        [
        State
        {
            name   : "gridview"

            StateChangeScript {
                script:
                {
                    gridView.visible = true;
                    detailProgressView.visible = false
                }}
        }
        ,
        State
        {
            name   : "detailprogressview"

            StateChangeScript {
                script:
                {
                    gridView.visible = false;
                    detailProgressView.visible = true
                }}
        }
    ]


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

        modelCE.setProperty(index, "who", who)
        modelCE.setProperty(index, "when", when)
        modelCE.setProperty(index, "fileName", fileName)
        modelCE.setProperty(index, "state", state)

        if (state == "done")
        {
            var isFinished = true;
            Tools.foreachInListModel(modelCE, function (x) { if (x.state !== "done") { isFinished = false}});
            mainView.isFinished = isFinished;
        }
    }



    function fillModel()
    {
        var finished = true;

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

                if (mainView.iAmFree && who === mainView.context.nickname && state === "inprogress")
                {
                    mainView.iAmFree = false;
                    mainView.myBusyPosition = pos;
                }

                if (state !== "done")
                {
                    finished = false;
                }


                modelCE.append({ "row" : row, "column" : column , "pos" : pos  , "state" : state , "who" : who, "fileName"  : fileName, "when" : when});
            }
        }

        mainView.isFinished = finished;
    }


    SplashScreen
    {
        id : splashScreenId
        width : parent.width
        height: parent.height
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

    property bool isFinished : false
    property bool iAmFree : true
    property bool iAmTheMaster : false
    property string myBusyPosition : ""


    ScrollView
    {
        id : gridView

        anchors.top : parent.top
        anchors.bottom : parent.bottom
        anchors.right : parent.right
        anchors.left : slider.right


        CadexisGrid
        {
            id : cadexisGrid

            anchors.top: parent.top
            anchors.left: parent.left

            clip : true

            width : mainView.nbrColum * currentImageWidth
            height : mainView.nbrRow * currentImageHeight

            model : modelCE

            onShowDetailProgressView:
            {
                mainView.state = "detailprogressview"

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

                if ( center !== null )
                {
                    cellPreview.centerImage.source = documentFolder.getUrl(center.fileName);
                }

                if ( up !== null )
                {
                    cellPreview.upImage.source = documentFolder.getUrl(up.fileName);
                }

                if ( down !== null)
                {
                    cellPreview.downImage.source = documentFolder.getUrl(down.fileName);
                }

                if ( left !== null)
                {
                    cellPreview.leftImage.source = documentFolder.getUrl(left.fileName);

                }

                if ( right !== null)
                {
                    cellPreview.rightImage.source = documentFolder.getUrl(right.fileName);

                }

            }

        }

    }




    ScrollView
    {

        id : detailProgressView

        width : cellPreview.width < parent.width ? cellPreview.width : parent.width
        height : cellPreview.height < parent.height ? cellPreview.height : parent.height


        visible : false

        anchors.centerIn: parent

        CellPreview
        {
            id : cellPreview

            anchors.top: parent.top
            anchors.left: parent.left

            height : currentImageHeight * 1.666
            width : currentImageWidth * 1.666
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

            }
            onItemDeleted :
            {
                //                if (Presenter.instance[idItem] === undefined ||
            }
        }



        onStarted :
        {
            mainView.nbrColum = parseInt(mainView.context.applicationConfiguration.getProperty("NumberOfColumn","2"));
            mainView.nbrRow = parseInt(mainView.context.applicationConfiguration.getProperty("NumberOfRow","2"));
            mainView.realImageWidth = parseFloat(mainView.context.applicationConfiguration.getProperty("PictureWidth","2"));
            mainView.realImageHeight = parseFloat(mainView.context.applicationConfiguration.getProperty("PictureHeight","2"));
            mainView.masterNickname = mainView.context.applicationConfiguration.getProperty("MasterNickname","???");


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
