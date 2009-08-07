/*
Copyright (c) 2008 Joel May.  See:
    http://www.connectedpixel.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Note: this will likely be moved to FlexLib soon, after I clean up the code.

*/

package com.enilsson.elephanttrakker.views.renderers.chart
{
    import flash.events.EventDispatcher;
    
    import mx.collections.IList;
    import mx.events.CollectionEvent;
    
    // Wraps an ArrayCollection or XMLListCollection.  Creates a limited window
    // into the wrapped collection.

    [Inspectable(category="General", arrayType="Object")] // I don't know what this is for.
    [Bindable("listChanged")] 
    public class SubRangeArrayCollection extends EventDispatcher implements IList
    {
        private var inner:IList;    // Wrapped collection.
        private var len:int;        // Externally visible array length.
        private var iStart:int;        // Offset into the inner array for externally visible index 0.
        
        public function SubRangeArrayCollection(arr:IList, visibleLen:int, iStart:int=0)
        {
            this.inner = arr;        
            this.len = visibleLen;
            this.iStart = iStart;
            
            // Use weak ref.
            arr.addEventListener(CollectionEvent.COLLECTION_CHANGE, onInnerCollectionChange, false, 0, true);
        }     
        
        private function onInnerCollectionChange(ev:CollectionEvent):void
        {
            // Bubble it up.
            this.dispatchEvent(ev);
        }
        
        ////////////////////////////////////////
        public function set firstIndexOffset(i:int):void
        {
            iStart = i;    
            
            var ev:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
            ev.kind = "refresh"
            this.dispatchEvent(ev);
        }
        public function get firstIndexOffset():int
        {
            return iStart;
        }
        
        // The externally visible length of the data. 
        public function set maxLength(l:int):void
        {
            this.len = l;
            
            var ev:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
            ev.kind = "refresh"
            this.dispatchEvent(ev);
        }
        public function get maxLength():int
        {
            return this.len;
        }
        
        public function setRange(iFirstIndexOffset:int, nMaxLen:int):void
        {
            iStart = iFirstIndexOffset;    
            this.len = nMaxLen;
            var ev:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
            ev.kind = "refresh";
            this.dispatchEvent(ev);
        }
        
        ////////////////////////////////////////
        
        public function addItemAt(item:Object, index:int):void
        {
            index += iStart;
            inner.addItemAt(item,index);
        }
        
        public function get length():int
        {
            return Math.min(len,inner.length);
        }
        
        public function toArray():Array
        {
            var arr:Array = toArray();
            var subArray:Array = new Array();
            var n:int = this.length;
            
            for (var i:int = iStart ; i < n ; i++){
                subArray.push(iStart+i);        
            }
            return subArray;
        }
        
        public function getItemAt(index:int, prefetch:int=0.0):Object
        {
            return inner.getItemAt(iStart+index,prefetch);
        }
        
        // BUGBUG: what does this do?
        public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void
        {
            inner.itemUpdated(item,property,oldValue,newValue);
        }
        
        public function removeAll():void
        {
            // BUGBUG: should this remove only items between iStart and iStart+len??
            inner.removeAll();
        }
        
        public function getItemIndex(item:Object):int
        {
            var i:int = inner.getItemIndex(item);
            i -= iStart;
            if (i < 0) return -1;
            if (i >= len) return -1;
            return i;
        }
        
        public function setItemAt(item:Object, index:int):Object
        {
            return inner.setItemAt(item,iStart+index);
        }
        
        public function removeItemAt(index:int):Object
        {
            return inner.removeItemAt(iStart+index);
        }
        
        public function addItem(item:Object):void
        {
            inner.addItem(item);
        }
    }
}
