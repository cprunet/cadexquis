.pragma library


function getIndexInListModel(listModel, findDelegate)
{
    for (var i=0;i<listModel.count;i++)
    {
        if ( findDelegate(listModel.get(i)) )
            return i;
    }
    return -1;
}

function foreachInListModel(listModel, delegate)
{
    for (var i=0;i<listModel.count;i++)
    {
        delegate(listModel.get(i));
    }
}
