TEMPLATE_KEY = 'overlayTemplate';
DATA_KEY = 'overlayData';
ANIMATION_DURATION = 200;

Session.setDefault(TEMPLATE_KEY, null);

@Overlay = {
  open: (template, data)->
    Session.set(TEMPLATE_KEY, template);
    unless thisdata?
      @_data = new ReactiveVar data
    else
      @_data.set(data)
 
  close: ->
    Session.set(TEMPLATE_KEY, null);
    @_data.set()
  
  isOpen: ->
    ! Session.equals(TEMPLATE_KEY, null);
  
  template: ->
    Session.get(TEMPLATE_KEY);
  
  data: ->
    unless @_data?
      @_data = new ReactiveVar()
    @_data.get()
  
}

Template.overlay.rendered = ->
  this.find('#overlay-hook')._uihooks = {
    insertElement: (node, next, done) ->
      $node = $(node);

      $node
        .hide()
        .insertBefore(next)
        .velocity('fadeIn', {
          duration: ANIMATION_DURATION
        });
    
    removeElement: (node, done) ->
      $node = $(node);

      $node
        .velocity("fadeOut", {
          duration: ANIMATION_DURATION,
          complete: ->$node.remove();
          
        });
    
  }


Template.overlay.helpers({
  template: ->
    return Overlay.template();
  
  data: ->
    return Overlay.data();
  
});

Template.overlay.events({
  'click .js-close-overlay': (event) ->
    event.preventDefault();
    Overlay.close()
  
});


