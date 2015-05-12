class helix
helix = {}


helix.config = {}
helix.config.rootDir = "/helix/"


# helix._loadCount = 0
# helix.loadCount = {
#     inc: () ->
#         return window._loadCount++

#     dec: () ->
#         count = window._loadCount--
#         if count <= 1
#             window.loaded.resolve()
# }


helix.loadedScripts = {}
$('body').append('<div id="loadedScripts">')
helix.loadScript = (url) ->
    if not helix.loadedScripts[url]?
        helix.loadedScripts[url] = new $.Deferred()
        http = new XMLHttpRequest()
        http.open('HEAD', url, false)
        http.send()
        if http.status == 404
            helix.loadedScripts[url].reject()
        else
            script = document.createElement("script")
            script.async = "async"
            script.type = "text/javascript"
            script.src = url
            script.onload = script.onreadystatechange = (_, isAbort) =>
              if not script.readyState or /loaded|complete/.test(script.readyState)
                 if (isAbort)
                    helix.loadedScripts[url].reject()
                 else
                    helix.loadedScripts[url].resolve()

            script.onerror = () ->
                helix.loadedScripts[url].reject()

            $("#loadedScripts")[0].appendChild(script)
    
    return helix.loadedScripts[url]


helix.loadedBases = {}
helix.loadBase = (baseName) ->
    """attempts a load of the specified base

       ignores: native elements, 
                bases that have been loaded
    """
    if typeof baseName isnt "string"
        return ''
    else
        tagName = baseName.toLowerCase()

    """if this base hasn't been loaded, load it
    """
    if not helix.loadedBases[baseName]?
        helix.loadedBases[baseName] = new $.Deferred()

        if baseName is "helix-base"
            basePath = "base"
        else
            basePath = baseName.replace(/\-/g, '/')

        url = helix.config.rootDir + basePath + ".js"
        helix.loadScript(url)

    return helix.loadedBases[baseName]


helix.loadElement = (element) ->
    """accepts any generic element, and figures out if it can load an element
    """
    if not element?
        return ''

    tagName = element.tagName
    if not tagName?
        return ''

    tagName = tagName.toLowerCase()
    splitTag = tagName.split('-')
    if splitTag.length > 1
        return helix.loadBase(tagName)


helix.bases = {}
helix.defineBase = (tagName, definition) ->
    """if the base hase been defined, you can't redefine it
    """
    if helix.bases[tagName]?
        return

    """start gathering the depdencies of the base
    """
    baseDependencies = []

    """get the parent first as specified by 'extends' or intuited
    """
    baseParent = ''
    if definition.extends?
        baseParent = definition.extends
    else
        splitTag = tagName.split('-')
        baseName = splitTag.pop()
        if baseName is 'base'
            splitTag.pop()

        splitTag.push('base')

        if splitTag[0] is "base"
            baseParent = "helix-base"
        else
            baseParent = splitTag.join().replace(/\,/g, '-')

    if tagName isnt "helix-base"
        load = helix.loadBase(baseParent)

    baseDependencies.push(load)

    """load libraries associated with this family
    """
    libs = if definition.libs? then definition.libs else []
    for lib in libs 
        baseDependencies.push(helix.loadScript(lib))

    if not definition.bridges?
        definition.bridges = []

    ## declare element after depencies are loaded
    $.when.apply($, baseDependencies).then(() =>
        console.log 'registering ' + tagName
        parentConstructor = helix.bases["#{baseParent}"]
        
        if baseParent? and parentConstructor?
            elPrototype = Object.create(parentConstructor.prototype)
        else
            elPrototype = Object.create(HTMLElement.prototype)

        ## tease apart our custom functions/attributes from its declaration
        for key, value of definition
            if $.isFunction(value) # if key not in excludedKeys
                elPrototype[key] = value
            else if key in ['properties', 'template', 'class', 'bridges']
                if key is 'properties' and elPrototype.properties?
                    extendedProperties = $.extend({}, elPrototype.properties)

                    ## extend parent properties
                    for k, v of value
                        if v?
                            extendedProperties[k] = v

                    value = extendedProperties

                Object.defineProperty(elPrototype, key, {
                    value: value
                    writable: true
                })

        CustomElement = document.registerElement("#{tagName}", {
            prototype: elPrototype })

        helix.bases["#{tagName}"] = CustomElement
        helix.loadedBases["#{tagName}"].resolve()
    )


helix.activeBases = []


helix.start = () ->
    update = () ->
        if window.stop is true
            return

        requestAnimationFrame(update)

        for element in helix.activeBases
            element._update()

    update()



@helix = helix


"""kickoff
"""

$('*').each((index, el) =>
    helix.loadElement(el))

helix.start()