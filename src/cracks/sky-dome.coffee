Firecracker.registerParticle('sky-dome', {

    src: undefined

    create: () ->
        if not @src?
            console.log 'define a src attribute for your skydome-3d obj'
            return
     
        skydome = Firecracker.ObjectUtils.skyDome(@src)
        skydome.rotation.y += 3*Math.PI / 2

        return skydome

})