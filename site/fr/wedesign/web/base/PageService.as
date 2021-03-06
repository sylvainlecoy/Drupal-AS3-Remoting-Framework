package fr.wedesign.web.base
{
  import flash.display.Loader;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.net.URLRequest;
  import flash.utils.Dictionary;
  
  import fr.wedesign.web.core.IPage;
  import fr.wedesign.web.core.IPageService;
  import fr.wedesign.web.events.PageEvent;
  
  import org.robotlegs.mvcs.Actor;
  
  [Event(name="pageChanged",type="fr.wedesign.web.events.PageEvent")]
  [Event(name="pageNotFound",type="fr.wedesign.web.events.PageEvent")]
  
  public final class PageService extends Actor implements IPageService
  {
    private var basePath:String;
    private var loader:Loader = new Loader();
    private var loading:Boolean = false;
    private var pageMap:Dictionary = new Dictionary();
    
    public function PageService(basePath:String = "")
    {
      trace("Pof");
      this.basePath = basePath;
      this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, requestPageSuccess);
      this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, requestPageFault);
    }
    
    // Test with conccurent loading
    public function requestPage(uri:String):void
    {
      if (loading) {
        loader.close();
      }
      
      if (pageMap[uri] == null) {
        var url:String = basePath + "/" + uri + ".swf";
  //      var url:String = "http://" + domain + "/" + uri + ".swf";
        var request:URLRequest = new URLRequest(url);
        loader.name = uri;
        loader.load(request);
        loading = true;
      } else {
        dispatch(new PageEvent("pageChanged", pageMap[uri]));
      }
    }
    
    private function requestPageSuccess(e:Event):void
    {
      loading = false;
      pageMap[loader.name] = loader.contentLoaderInfo.content as IPage;
      dispatch(new PageEvent("pageChanged", pageMap[loader.name]));
    }
    
    private function requestPageFault(e:IOErrorEvent):void
    {
      loading = false;
      dispatch(new PageEvent("pageNotFound"));
      requestPage("404NotFound");
    }
  }
}