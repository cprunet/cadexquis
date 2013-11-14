var instance = new Object();

function initPresenter()
{   
    instance.activePostIt = null;

    instance.forEachInArray = function(array, delegate)
    {
        for (var i=0;i<array.length;i++)
        {
            delegate(array[i]);
        }
    }

    instance.setActivePostIt = function(postIt)
    {
        if (instance.activePostIt !== null)
        {
            instance.activePostIt.state = "readonly";
        }

        instance.activePostIt = postIt;
   }
}
