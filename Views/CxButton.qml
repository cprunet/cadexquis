import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0

Button
{
    id : button
    height              : 50
    width               : height

    property string imageSource : ""

//    transform: Rotation { origin.x: button.width/2; origin.y: 0 ; origin.z: 0; axis { x: 1; y: 0; z: 0 } angle: button.pressed ? -20 : 0}


    style: ButtonStyle {
        background:
            Image
            {
                source :  control.imageSource
                anchors.fill: parent
            }
    }
}
