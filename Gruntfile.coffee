module.exports = ->


    ## grunt tasks are located in grunt_tasks/
    @loadTasks("grunt_tasks")


    @registerTask("compile", [
        "coffee:compileSource"
        "concat:libsAndSource"
        "copy:sourceToWWW"
        "copy:testsToWWW"
    ])


    @registerTask("release", [
        "clean:everything"
        "compile"
        "uglify:tagJS"
        "copy:minifiedToWWW"
    ])


    @registerTask("listen", [
        "clean:everything"
        "compile"
        "watch"
    ])
