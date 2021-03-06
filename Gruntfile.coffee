module.exports = ->


    ## grunt tasks are located in grunt_tasks/
    @loadTasks("tasks")

    @registerTask("compile", [
        "coffee:compileSource",
        "concat:libsAndSource",
        "folder_list:testsJSON",
        "inject"
    ])

    @registerTask("release", [
        "clean:everything",
        "compile",
        "copy:debug",
        "uglify:taggJS",
        "uglify:sourceJS"
    ])

    @registerTask("listen", [
        "clean:everything",
        "compile",
        "watch"
    ])

    ## PRODUCTION TASKS

    @registerTask("inject", [
        "clean:weblib",
        "copy:dist",
        "copy:tests"
    ])
