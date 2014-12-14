
class SimditorAutosave extends SimpleModule

  @pluginName: 'Autosave'

  opts:
    autosave: false

  _init: () ->
    @editor = @_module
    @opts.autosave = @opts.autosave || @editor.textarea.data('autosave')
    return unless @opts.autosave

    link = $( "<a/>", {href: location.href})
    path = "/" + link[0].pathname.replace( /\/$/g, "" ).replace( /^\//g, "" ) + "/"
    path = path + @opts.autosave + "/autosave/"

    @editor.on "valuechanged", =>
      @Storage.set path, @editor.getValue()

    @editor.el.closest('form').on 'ajax:success.simditor-' + @editor.id, (e) =>
      @Storage.remove path

    val = @Storage.get path
    return unless val

    currentVal = @editor.textarea.val()
    return if val is currentVal

    if @editor.textarea.is('[data-autosave-confirm]')
      if confirm '有未保存的内容，确定要回复么？'
        @editor.setValue val
      else
        @Storage.remove path
    else
      @editor.setValue val

  Storage:
    supported: () ->
      try
        localStorage.setItem('_storageSupported', 'yes')
        localStorage.removeItem('_storageSupported')
        return true
      catch error
        return false
    set: (key, val, session) ->
      if session is null
        session = false
      if !@.supported()
        return
      storage = if session then sessionStorage else localStorage
      storage.setItem(key, val)
    get: (key, session) ->
      if session is null
        session = false
      if !@.supported()
        return
      storage = if session then sessionStorage else localStorage
      storage[key]
    remove: (key, session) ->
      if session is null
        session = false
      if !@.supported()
        return
      storage = if session then sessionStorage else localStorage
      return storage.removeItem(key);

Simditor.connect SimditorAutosave

