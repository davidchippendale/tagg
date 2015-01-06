
Firecracker.register_element('particle-core', {

    x_pos: 0
    y_pos: 0
    z_pos: 0

    width: 5
    height: 5
    depth: 5
    
    movex: 0
    movey: 0
    movez: 0

    rpmx: 0
    rpmy: 0
    rpmz: 0

    ready: () ->
        $.when(window.world_created).then(() =>
            @shape = @create()
            @_stack_element()

            window.particles.push(@)
            window.world.add(@shape)
        )

    create: () ->
        """Should be overwritten.

           Returns some parent of Object3d to be added to the world.
        """
        return new THREE.Object3D()

    _stack_element: () ->
        """Stack particles on top of each other.

           @todo: position elements according to siblings
        """
        @positioned = new $.Deferred()

        parent = @.parentElement
        if not parent?
            return

        $.when(parent.positioned).then(() =>
            ## position element on top of its parent
            parent_top = parent.y_pos + parseInt(parent.height) / 2
            if isNaN(parent_top) is false
                @y_pos = parent_top + @height / 2

            ## position element in the center of its parent
            if @x_pos is 0 and parent.x_pos?
                @x_pos = parent.x_pos

            ## position element according to its parent's depth
            if parent.z?
                @z_pos = parent.z_pos

            @shape.position.set(@x_pos, @y_pos, @z_pos)
            @positioned.resolve()
        )

    remove: () ->
        """Remove the object from the scene and DOM completely
        """
        window.world.remove(@shape)

        particle_index = window.particles.indexOf(@)
        if particle_index > -1
            window.particles.splice(particle_index, 1)

        $(@).remove()

    detached: () ->
        """Fired when DOM element is removed
        """
        @remove()

    update: () ->
        @_animate_shape()
        @animate_shape()

    _animate_shape: () ->
        """API that all objects should get access to
        """
        @shape.position.x += @movex
        @shape.position.y += @movey
        @shape.position.z += @movez

        @shape.rotation.x += (Math.PI / 60) * (@rpmx / 60)
        @shape.rotation.y += (Math.PI / 60) * (@rpmy / 60)
        @shape.rotation.z += (Math.PI / 60) * (@rpmz / 60)

    animate_shape: () ->
        return
})