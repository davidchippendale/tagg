Firecracker.register_particle('world-sunset', {

    extends: 'world-core'
    scripts: [
        '/assets/skyShader.js'
    ]

    create: () ->
        particles = []

        sky = new THREE.Sky();
        window.world.add( sky.mesh );
        particles.push(sky)

        ## Add Sun Helper
        sunSphere = new THREE.Mesh( new THREE.SphereGeometry( 20000, 30, 30 ),
        new THREE.MeshBasicMaterial({color: 0xffffff, wireframe: false }));
        sunSphere.position.y = -700000;
        sunSphere.visible = true;
        window.world.add( sunSphere );

        effectController  = {
            turbidity: 50,
            reileigh: 1,
            mieCoefficient: 0.005,
            mieDirectionalG: 0.8,
            luminance: .5,
            inclination: 0.49, ## // elevation / inclination
            azimuth: 0.25, ## // Facing front,                 
            sun: false
        }

        distance = 40000;

        uniforms = sky.uniforms;
        uniforms.turbidity.value = effectController.turbidity;
        uniforms.reileigh.value = effectController.reileigh;
        uniforms.luminance.value = effectController.luminance;
        uniforms.mieCoefficient.value = effectController.mieCoefficient;
        uniforms.mieDirectionalG.value = effectController.mieDirectionalG;

        theta = Math.PI * (effectController.inclination - 0.5);
        phi = 2 * Math.PI * (effectController.azimuth - 0.5);

        sunSphere.position.x = distance * Math.cos(phi);
        sunSphere.position.y = distance * Math.sin(phi) * Math.sin(theta); 
        sunSphere.position.z = distance * Math.sin(phi) * Math.cos(theta); 

        sunSphere.visible = effectController.sun;

        sky.uniforms.sunPosition.value.copy(sunSphere.position);

        return particles

})