import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0

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

    function getIndexInListModel(listModel, findDelegate)
    {
        for (var i=0;i<listModel.count;i++)
        {
            if ( findDelegate(listModel.get(i)) )
                return i;
        }
        return -1;
    }


    function updateKey(row,column,key)
    {
        console.log(">> row " + row + " column " + column)
        var index =  getIndexInListModel(modelCE, function (x) { return x.row === row && x.column === column})

        modelCE.setProperty(index, "key", key)
    }

    function fillModel()
    {
        for ( var i = 0; i < 5 ; i++)
            for (var j = 0 ; j < 10 ; j++)
            {
                var row = "" + i;
                var column = "" + j;

                modelCE.append({ "row" : row, "column" : column , "key" : ceDefinition.getItem(i + "_" + j,"")})
            }
    }


    ScrollView
    {
        anchors.fill : parent


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
                    states :
                        [
                        State
                        {
                            name   : "free"

                            StateChangeScript {
                                script:
                                {
                                    takeForMe.visible = true
                                }}
                        },
                        State
                        {
                            name   : "inProgress"

                            StateChangeScript {
                                script:
                                {
                                    takeForMe.visible = false
                                }}
                        }

                    ]

                    state : model.key === "" ? "free" : "inProgress"

                    clip : true
                    height: 200
                    width : 100
                    color : (column + row) % 2 == 0 ? "black" : "white"

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
                            ceDefinition.setItem(model.row + "_" + model.column,mainView.context.nickname);

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


    ZcCrowdActivity
    {
        id : activity

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
                var split = idItem.split("_");
                mainView.updateKey(split[0],split[1],ceDefinition.getItem(idItem,""));

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
