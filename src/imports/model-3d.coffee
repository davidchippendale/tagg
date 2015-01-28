Firecracker.register_particle('model-3d', {

    scale: 1

    src: undefined

    create: () ->
        if not @src?
            console.log "define a src attribute pointing to your JSON obj file"
            return

        obj = Firecracker.ObjectUtils.load3DModel(@src, 0)
        
        obj.scale.x = @scale
        obj.scale.y = @scale
        obj.scale.z = @scale

        return obj

})