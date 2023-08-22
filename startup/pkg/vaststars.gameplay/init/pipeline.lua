local pipeline = require "register.pipeline"

pipeline "ecs"
    .stage "ecs_update"

pipeline "init"
    .stage "init"
pipeline "update"
    .stage "update"
    .pipeline "ecs_update"
pipeline "build"
    .stage "clean"
    .pipeline "ecs_update"
    .stage "build"
    .pipeline "ecs_update"
pipeline "backup"
    .stage "backup_start"
    .stage "backup"
    .stage "backup_finish"
pipeline "restore"
    .stage "restore"
    .stage "restore_finish"
